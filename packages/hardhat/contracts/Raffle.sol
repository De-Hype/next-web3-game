// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "@chainlink/contracts/src/v0.8/vrf/VRFConsumerBaseV2.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "hardhat/console.sol";
import "@chainlink/contracts/src/v0.8/automation/AutomationCompatible.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

error Raffle__NotEnoughEth();
error Raffle__TransferFailed();
error Raffle__NotOpen();
error Raffle__UpkeepNotNeeded(
	uint256 currentBalance,
	uint256 numPlayers,
	uint256 raffleState
);

contract Raffle is
	VRFConsumerBaseV2,
	AutomationCompatible,
	Ownable,
	ReentrancyGuard
{
	/* state variables */
	uint256 public i_entranceFee;
	address payable[] public s_players;
	address payable public treasuryWallet;
	address[] public specialWallets;
	uint256 public treasuryFund;
	uint256 public reserveFunds;
	mapping(address => bool) public hasUsedFreeEntry;
	address payable[] public s_recentWinner;
	mapping(address => bool) public isPlayerEntered;

	mapping(address => uint256) public winnings;
	mapping(address => uint256) contributions;

	/** Lottey Variables */
	// address private s_recentWinner;
	enum RaffleState {
		OPEN,
		CALCULATING
	}
	RaffleState private s_raffleState;
	uint256 private s_lastTimeStamp;

	/* Chainlink VRF Variables */
	VRFCoordinatorV2Interface private immutable i_vrfCOORDINATOR;
	bytes32 private immutable i_gasLane;
	uint64 private immutable i_subscriptionId;
	uint16 private constant REQUEST_CONFIRMATIONS = 3;
	uint32 private immutable i_callbackGasLimit;
	uint32 private constant NUM_WORDS = 1;

	/* events */
	event RaffleEnter(address indexed player);
	event RequestedRaffleWinnerFirst(uint256 indexed requestId);
	event RequestedRaffleWinnerSecond(uint256 indexed requestId);
	event RequestedRaffleWinnerThird(uint256 indexed requestId);
	event WinnerPicked(address indexed winner, uint256 prize);

	event TreasuryChanged(address indexed newTreasury);
	// Events for tracking refund status
	event RefundIssued(address to, uint256 amount);
	event RefundFailed(address to, uint256 amount);

	constructor(
		address VRFCoordinatorV2,
		uint256 entranceFee,
		bytes32 keyHash,
		uint64 subscriptionId,
		uint32 callBackGasLimit,
		address payable _treasuryWallet
	) VRFConsumerBaseV2(VRFCoordinatorV2) {
		i_entranceFee = entranceFee;
		i_vrfCOORDINATOR = VRFCoordinatorV2Interface(VRFCoordinatorV2);
		i_gasLane = keyHash;
		i_subscriptionId = subscriptionId;
		i_callbackGasLimit = callBackGasLimit;
		s_raffleState = RaffleState.OPEN;
		s_lastTimeStamp = block.timestamp;
		treasuryWallet = _treasuryWallet;
	}

	// function enterRaffle() public payable {
	// 	require(s_raffleState == RaffleState.OPEN, "Raffle__NotOpen");

	// 	bool isSpecialWallet = false;
	// 	for (uint256 i = 0; i < specialWallets.length; i++) {
	// 		if (msg.sender == specialWallets[i]) {
	// 			isSpecialWallet = true;
	// 			break;
	// 		}
	// 	}

	// 	// Check if the wallet is special and has already used its free entry
	// 	if (isSpecialWallet && hasUsedFreeEntry[msg.sender]) {
	// 		require(msg.value >= i_entranceFee, "Raffle__NotEnoughEth");
	// 	} else if (!isSpecialWallet) {
	// 		require(msg.value >= i_entranceFee, "Raffle__NotEnoughEth");
	// 	}

	// 	// Mark the free entry as used for special wallets entering for free
	// 	if (isSpecialWallet && !hasUsedFreeEntry[msg.sender]) {
	// 		hasUsedFreeEntry[msg.sender] = true;
	// 	}

	// 	// Update the contributions mapping with the new contribution
	// 	contributions[msg.sender] += msg.value;

	// 	if (!isPlayerEntered[msg.sender]) {
	// 		s_players.push(payable(msg.sender));
	// 		isPlayerEntered[msg.sender] = true;
	// 	}

	// 	emit RaffleEnter(msg.sender);
	// }

	function enterRaffle() public payable {
		require(s_raffleState == RaffleState.OPEN, "Raffle__NotOpen");

		bool isSpecialWallet = false;

		for (uint256 i = 0; i < specialWallets.length; i++) {
			if (msg.sender == specialWallets[i]) {
				isSpecialWallet = true;
				break;
			}
		}

		if (isSpecialWallet) {
			// Check if the wallet is special and has already used its free entry
			if (hasUsedFreeEntry[msg.sender]) {
				require(msg.value >= i_entranceFee, "Raffle__NotEnoughEth");
				contributions[msg.sender] += msg.value;
			} else {
				// Special wallet entering for free for the first time
				require(
					reserveFunds >= i_entranceFee,
					"Reserve__InsufficientFunds"
				);
				reserveFunds -= i_entranceFee; // Deduct the entrance fee from the treasury
				contributions[msg.sender] += i_entranceFee; // Consider it as their contribution
				hasUsedFreeEntry[msg.sender] = true;
			}
		} else {
			// Not a special wallet
			require(msg.value >= i_entranceFee, "Raffle__NotEnoughEth");
			contributions[msg.sender] += msg.value;
		}

		if (!isPlayerEntered[msg.sender]) {
			s_players.push(payable(msg.sender));
			isPlayerEntered[msg.sender] = true;
		}

		emit RaffleEnter(msg.sender);
	}

	/**
	 * @dev This is the function that the Chainlink Keeper nodes call
	 * they look for `upkeepNeeded` to return True.
	 * the following should be true for this to return true:
	 * 1. The time interval has passed between raffle runs.
	 * 2. The lottery is open.
	 * 3. The contract has ETH.
	 * 4. Implicity, your subscription is funded with LINK.
	 */
	/** CHAINLINK KEEPERS (AUTOMATION) */
	function checkUpkeep(
		bytes memory /* checkData*/
	)
		public
		view
		override
		returns (
			// external was changed to public so our own functions can call this function */
			bool upkeepNeeded,
			bytes memory /* performData*/
		)
	{
		bool isOpen = RaffleState.OPEN == s_raffleState;
		bool hasBalance = address(this).balance > 0;
		bool hasPlayers = s_players.length >= 1;
		// bool timePassed = ((block.timestamp - s_lastTimeStamp) > i_interval);

		upkeepNeeded = (isOpen && hasBalance && hasPlayers);
		return (upkeepNeeded, "0x0");
	}

	/**
	 * @dev Once `checkUpkeep` is returning `true`, this function is called
	 * and it kicks off a Chainlink VRF call to get a random winner.
	 */
	function performUpkeep(bytes calldata /* performData */) external override {
		(bool upKeepNeeded, ) = checkUpkeep("");
		if (!upKeepNeeded) {
			revert Raffle__UpkeepNotNeeded(
				address(this).balance,
				s_players.length,
				uint256(s_raffleState)
			);
		}

		s_raffleState = RaffleState.CALCULATING;

		uint256 requestId = i_vrfCOORDINATOR.requestRandomWords(
			i_gasLane,
			i_subscriptionId,
			REQUEST_CONFIRMATIONS,
			i_callbackGasLimit,
			NUM_WORDS
		);
		emit RequestedRaffleWinnerFirst(requestId);
	}

	/** CHAINLINK VRF */
	function fulfillRandomWords(
		uint256 /* requestId */,
		uint256[] memory randomWords
	) internal override {
		delete s_recentWinner;
		require(s_players.length >= 1, "Not enough players");

		uint256 totalContributions = 0;
		for (uint256 i = 0; i < s_players.length; i++) {
			totalContributions += contributions[s_players[i]];
		}

		require(totalContributions > 0, "Total contributions must be positive");

		uint256 winningThreshold = randomWords[0] % totalContributions;
		uint256 cumulativeContribution = 0;
		address payable recentWinner = payable(address(0));

		for (uint256 i = 0; i < s_players.length; i++) {
			cumulativeContribution += contributions[s_players[i]];
			if (winningThreshold < cumulativeContribution) {
				recentWinner = s_players[i];
				break;
			}
		}

		uint256 pool = address(this).balance - treasuryFund;

		uint256 prizes = (pool * 75) / 100;
		treasuryFund = (pool * 20) / 100;
		reserveFunds = (pool * 5) / 100;

		winnings[recentWinner] = prizes;

		s_recentWinner.push(recentWinner);
		emit WinnerPicked(recentWinner, prizes);

		// Reset for next raffle
		for (uint256 i = 0; i < s_players.length; i++) {
			address player = s_players[i];
			contributions[player] = 0;
			isPlayerEntered[player] = false;
		}

		s_raffleState = RaffleState.OPEN;
		s_players = new address payable[](0);
		s_lastTimeStamp = block.timestamp;

		for (uint256 i = 0; i < specialWallets.length; i++) {
			hasUsedFreeEntry[specialWallets[i]] = false;
		}
	}

	function claimWinnings() external {
		uint256 winningAmount = winnings[msg.sender];
		require(winningAmount > 0, "No winnings to claim");

		// treasury
		uint256 amount = treasuryFund;
		require(amount > 0, "No winnings to claim");

		winnings[msg.sender] = 0;
		treasuryFund = 0;

		(bool success, ) = msg.sender.call{ value: winningAmount }("");
		(bool successTreasury, ) = msg.sender.call{ value: amount }("");
		require(success, "Failed to send winnings to user wallet");
		require(successTreasury, "Failed to send cut to treasury");
	}

	// function claimTreasury() external onlyOwner {
	// 	uint256 amount = treasuryFund;
	// 	require(amount > 0, "No winnings to claim");

	// 	treasuryFund = 0; // Prevent re-entrancy by setting to 0 before transfer
	// 	(bool success, ) = msg.sender.call{ value: amount }("");
	// 	require(success, "Failed to send winnings");
	// }

	function getContractBalance() public view returns (uint256) {
		return address(this).balance;
	}

	function getBalanceWithoutPlatformFund() public view returns (uint256) {
		return address(this).balance - treasuryFund - reserveFunds;
	}

	function getRaffleState() public view returns (RaffleState) {
		return s_raffleState;
	}

	function getSpecialWallets() public view returns (address[] memory) {
		return specialWallets;
	}

	function getEntranceFee() public view returns (uint256) {
		return i_entranceFee;
	}

	function getPlayer(uint256 index) public view returns (address) {
		return s_players[index];
	}

	function getAllPlayers() public view returns (address payable[] memory) {
		return s_players;
	}

	function getRecentWinners() public view returns (address payable[] memory) {
		return s_recentWinner;
	}

	function getReserveFunds() public view returns (uint256) {
		return reserveFunds;
	}

	function getLastTimeStamp() public view returns (uint256) {
		return s_lastTimeStamp;
	}

	function getNumberOfPlayers() public view returns (uint256) {
		return s_players.length;
	}

	function addSpecialWallet(address _wallet) external onlyOwner {
		specialWallets.push(_wallet);
	}

	function getPlayerContributionsPercentages()
		public
		view
		returns (address[] memory, uint256[] memory, uint256[] memory)
	{
		address[] memory players = new address[](s_players.length);
		uint256[] memory percentages = new uint256[](s_players.length);
		uint256[] memory contributionsArray = new uint256[](s_players.length);
		uint256 total = 0;

		// Calculate total contributions
		for (uint256 i = 0; i < s_players.length; i++) {
			total += contributions[s_players[i]];
		}

		// Calculate each player's percentage of total contributions and get their contribution
		for (uint256 i = 0; i < s_players.length; i++) {
			players[i] = s_players[i];
			contributionsArray[i] = contributions[s_players[i]]; // Store individual contributions
			if (total > 0) {
				percentages[i] = (contributions[s_players[i]] * 100) / total;
			} else {
				percentages[i] = 0;
			}
		}

		return (players, percentages, contributionsArray);
	}

	function removeSpecialWallet(address _wallet) external onlyOwner {
		for (uint256 i = 0; i < specialWallets.length; i++) {
			if (specialWallets[i] == _wallet) {
				specialWallets[i] = specialWallets[specialWallets.length - 1];
				specialWallets.pop();
				break;
			}
		}
	}

	// Function to update the entrance fee
	function setEntranceFee(uint256 _newEntranceFee) external onlyOwner {
		i_entranceFee = _newEntranceFee;
	}

	function setTreasury(address payable _newTreasury) public onlyOwner {
		require(
			_newTreasury != address(0),
			"New treasury cannot be the zero address"
		);
		treasuryWallet = _newTreasury;
		emit TreasuryChanged(_newTreasury);
	}

	function transferTreasuryFunds(address payable _to) public onlyOwner {
		require(_to != address(0), "Invalid address");
		require(treasuryFund > 0, "No treasury to transfer");

		uint256 amountToTransfer = treasuryFund;
		treasuryFund = 0; // Reset remains before transfer to prevent re-entrancy attack
		(bool success, ) = _to.call{ value: amountToTransfer }("");
		require(success, "Transfer failed");
	}

	// to be removed
	function transferReserve(address payable _to) public onlyOwner {
		require(_to != address(0), "Invalid address");
		uint256 amountToTransfer = reserveFunds;

		require(amountToTransfer >= 0, "No eth to transfer");
		reserveFunds = 0;
		(bool success, ) = _to.call{ value: amountToTransfer }("");
		require(success, "Transfer failed");
	}

	function transfer(address payable _to) public onlyOwner {
		require(_to != address(0), "Invalid address");
		uint256 amountToTransfer = address(this).balance;

		require(amountToTransfer >= 0, "No eth to transfer");
		reserveFunds = 0;

		(bool success, ) = _to.call{ value: amountToTransfer }("");
		require(success, "Transfer failed");
	}

	function refundAllParticipants() external onlyOwner nonReentrant {
		require(s_raffleState == RaffleState.CALCULATING);
		uint256 playerCount = s_players.length;

		for (uint256 i = 0; i < playerCount; i++) {
			address payable player = s_players[i];
			// Attempt to refund each player individually
			(bool success, ) = player.call{ value: i_entranceFee }("");
			if (success) {
				emit RefundIssued(player, i_entranceFee);
			} else {
				emit RefundFailed(player, i_entranceFee);
			}
		}
		s_raffleState = RaffleState.OPEN;
		delete s_players;
	}

	receive() external payable {}
}
