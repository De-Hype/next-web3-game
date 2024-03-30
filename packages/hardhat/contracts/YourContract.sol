//SPDX-License-Identifier: MIT
// pragma solidity >=0.8.0 <0.9.0;

// Useful for debugging. Remove when deploying to a live network.
// import "hardhat/console.sol";

// Use openzeppelin to inherit battle-tested implementations (ERC20, ERC721, etc)
// import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * A smart contract that allows changing a state variable of the contract and tracking the changes
 * It also allows the owner to withdraw the Ether in the contract
 * @author BuidlGuidl
 */
// contract YourContract {
// 	// State Variables
// 	address public immutable owner;
// 	string public greeting = "Building Unstoppable Apps!!!";
// 	bool public premium = false;
// 	uint256 public totalCounter = 0;
// 	mapping(address => uint) public userGreetingCounter;

// 	// Events: a way to emit log statements from smart contract that can be listened to by external parties
// 	event GreetingChange(
// 		address indexed greetingSetter,
// 		string newGreeting,
// 		bool premium,
// 		uint256 value
// 	);

// 	// Constructor: Called once on contract deployment
// 	// Check packages/hardhat/deploy/00_deploy_your_contract.ts
// 	constructor(address _owner) {
// 		owner = _owner;
// 	}

// 	// Modifier: used to define a set of rules that must be met before or after a function is executed
// 	// Check the withdraw() function
// 	modifier isOwner() {
// 		// msg.sender: predefined variable that represents address of the account that called the current function
// 		require(msg.sender == owner, "Not the Owner");
// 		_;
// 	}

// 	/**
// 	 * Function that allows anyone to change the state variable "greeting" of the contract and increase the counters
// 	 *
// 	 * @param _newGreeting (string memory) - new greeting to save on the contract
// 	 */
// 	function setGreeting(string memory _newGreeting) public payable {
// 		// Print data to the hardhat chain console. Remove when deploying to a live network.
// 		console.log(
// 			"Setting new greeting '%s' from %s",
// 			_newGreeting,
// 			msg.sender
// 		);

// 		// Change state variables
// 		greeting = _newGreeting;
// 		totalCounter += 1;
// 		userGreetingCounter[msg.sender] += 1;

// 		// msg.value: built-in global variable that represents the amount of ether sent with the transaction
// 		if (msg.value > 0) {
// 			premium = true;
// 		} else {
// 			premium = false;
// 		}

// 		// emit: keyword used to trigger an event
// 		emit GreetingChange(msg.sender, _newGreeting, msg.value > 0, msg.value);
// 	}

// 	/**
// 	 * Function that allows the owner to withdraw all the Ether in the contract
// 	 * The function can only be called by the owner of the contract as defined by the isOwner modifier
// 	 */
// 	function withdraw() public isOwner {
// 		(bool success, ) = owner.call{ value: address(this).balance }("");
// 		require(success, "Failed to send Ether");
// 	}

// 	/**
// 	 * Function that allows the contract to receive ETH
// 	 */
// 	receive() external payable {}
// }

// pragma solidity ^0.8.16;

// import "@chainlink/contracts/src/v0.8/vrf/VRFConsumerBaseV2.sol";
// import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
// import "hardhat/console.sol";
// import "@chainlink/contracts/src/v0.8/automation/AutomationCompatible.sol";
// import "@openzeppelin/contracts/access/Ownable.sol";
// import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

// error Raffle__NotEnoughEth();
// error Raffle__TransferFailed();
// error Raffle__NotOpen();
// error Raffle__UpkeepNotNeeded(
// 	uint256 currentBalance,
// 	uint256 numPlayers,
// 	uint256 raffleState
// );

// contract Raffle is
// 	VRFConsumerBaseV2,
// 	AutomationCompatible,
// 	Ownable,
// 	ReentrancyGuard
// {
// 	/* state variables */
// 	uint256 public i_entranceFee;
// 	address payable[] public s_players;
// 	address payable public treasury;
// 	address[] public specialWallets;
// 	uint256 public treasuryAmount;
// 	mapping(address => bool) public hasUsedFreeEntry;
// 	address payable[] public s_recentWinners;
// 	uint256 pool = address(this).balance - treasuryAmount;

// 	mapping(address => uint256) public winnings;

// 	/** Lottey Variables */
// 	// address private s_recentWinner;
// 	enum RaffleState {
// 		OPEN,
// 		CALCULATING
// 	}
// 	RaffleState private s_raffleState;
// 	uint256 private s_lastTimeStamp;

// 	/* Chainlink VRF Variables */
// 	VRFCoordinatorV2Interface private immutable i_vrfCOORDINATOR;
// 	bytes32 private immutable i_gasLane;
// 	uint64 private immutable i_subscriptionId;
// 	uint16 private constant REQUEST_CONFIRMATIONS = 3;
// 	uint32 private immutable i_callbackGasLimit;
// 	uint32 private constant NUM_WORDS = 3;

// 	/* events */
// 	event RaffleEnter(address indexed player);
// 	event RequestedRaffleWinnerFirst(uint256 indexed requestId);
// 	event RequestedRaffleWinnerSecond(uint256 indexed requestId);
// 	event RequestedRaffleWinnerThird(uint256 indexed requestId);
// 	event WinnerPicked(address indexed winner, uint256 prize, uint256 position);

// 	event TreasuryChanged(address indexed newTreasury);
// 	// Events for tracking refund status
// 	event RefundIssued(address to, uint256 amount);
// 	event RefundFailed(address to, uint256 amount);

// 	constructor(
// 		address VRFCoordinatorV2,
// 		uint256 entranceFee,
// 		bytes32 keyHash,
// 		uint64 subscriptionId,
// 		uint32 callBackGasLimit,
// 		address payable _treasury
// 	) VRFConsumerBaseV2(VRFCoordinatorV2) {
// 		i_entranceFee = entranceFee;
// 		i_vrfCOORDINATOR = VRFCoordinatorV2Interface(VRFCoordinatorV2);
// 		i_gasLane = keyHash;
// 		i_subscriptionId = subscriptionId;
// 		i_callbackGasLimit = callBackGasLimit;
// 		s_raffleState = RaffleState.OPEN;
// 		s_lastTimeStamp = block.timestamp;
// 		treasury = _treasury;
// 	}

// 	function enterRaffle() public payable {
// 		require(s_raffleState == RaffleState.OPEN, "Raffle__NotOpen");

// 		bool isSpecialWallet = false;
// 		for (uint256 i = 0; i < specialWallets.length; i++) {
// 			if (msg.sender == specialWallets[i]) {
// 				isSpecialWallet = true;
// 				break;
// 			}
// 		}

// 		// Check if the wallet is special and has already used its free entry
// 		if (isSpecialWallet && hasUsedFreeEntry[msg.sender]) {
// 			require(msg.value >= i_entranceFee, "Raffle__NotEnoughEth");
// 		} else if (!isSpecialWallet) {
// 			require(msg.value >= i_entranceFee, "Raffle__NotEnoughEth");
// 		}

// 		// Mark the free entry as used for special wallets entering for free
// 		if (isSpecialWallet && !hasUsedFreeEntry[msg.sender]) {
// 			hasUsedFreeEntry[msg.sender] = true;
// 		}

// 		s_players.push(payable(msg.sender));
// 		emit RaffleEnter(msg.sender);
// 	}

// 	/**
// 	 * @dev This is the function that the Chainlink Keeper nodes call
// 	 * they look for `upkeepNeeded` to return True.
// 	 * the following should be true for this to return true:
// 	 * 1. The time interval has passed between raffle runs.
// 	 * 2. The lottery is open.
// 	 * 3. The contract has ETH.
// 	 * 4. Implicity, your subscription is funded with LINK.
// 	 */
// 	/** CHAINLINK KEEPERS (AUTOMATION) */
// 	function checkUpkeep(
// 		bytes memory /* checkData*/
// 	)
// 		public
// 		view
// 		override
// 		returns (
// 			// external was changed to public so our own functions can call this function */
// 			bool upkeepNeeded,
// 			bytes memory /* performData*/
// 		)
// 	{
// 		bool isOpen = RaffleState.OPEN == s_raffleState;
// 		bool hasBalance = address(this).balance > 0;
// 		bool hasPlayers = s_players.length > 2;
// 		// bool timePassed = ((block.timestamp - s_lastTimeStamp) > i_interval);

// 		upkeepNeeded = (isOpen && hasBalance && hasPlayers);
// 		return (upkeepNeeded, "0x0");
// 	}

// 	/**
// 	 * @dev Once `checkUpkeep` is returning `true`, this function is called
// 	 * and it kicks off a Chainlink VRF call to get a random winner.
// 	 */
// 	function performUpkeep(bytes calldata /* performData */) external override {
// 		(bool upKeepNeeded, ) = checkUpkeep("");
// 		if (!upKeepNeeded) {
// 			revert Raffle__UpkeepNotNeeded(
// 				address(this).balance,
// 				s_players.length,
// 				uint256(s_raffleState)
// 			);
// 		}

// 		s_raffleState = RaffleState.CALCULATING;

// 		uint256 requestId = i_vrfCOORDINATOR.requestRandomWords(
// 			i_gasLane,
// 			i_subscriptionId,
// 			REQUEST_CONFIRMATIONS,
// 			i_callbackGasLimit,
// 			NUM_WORDS
// 		);
// 		emit RequestedRaffleWinnerFirst(requestId);
// 		emit RequestedRaffleWinnerSecond(requestId);
// 		emit RequestedRaffleWinnerThird(requestId);
// 	}

// 	/** CHAINLINK VRF */
// 	function fulfillRandomWords(
// 		uint256 /* requestId */,
// 		uint256[] memory randomWords
// 	) internal override {
// 		require(s_players.length >= 3, "Not enough players");
// 		delete s_recentWinners;

// 		uint256[] memory prizes = new uint256[](3);

// 		prizes[0] = (pool * 35) / 100;
// 		prizes[1] = (pool * 20) / 100;
// 		prizes[2] = (pool * 10) / 100;

// 		treasuryAmount = (pool * 35) / 100;

// 		for (uint i = 0; i < 3; i++) {
// 			// Find unique winner for each prize
// 			address payable winner;
// 			do {
// 				winner = s_players[randomWords[i] % s_players.length];
// 				// Increment random word index to ensure uniqueness if needed
// 				randomWords[i]++;
// 			} while (winnings[winner] != 0); // Check if this winner already won

// 			winnings[winner] = prizes[i];
// 			s_recentWinners.push(winner);
// 			emit WinnerPicked(winner, prizes[i], i + 1);
// 		}

// 		// (bool successTreasury, ) = treasury.call{ value: treasuryAmount }("");
// 		// require(successTreasury, "Transfer to treasury failed");

// 		// Reset for next raffle
// 		s_raffleState = RaffleState.OPEN;
// 		s_players = new address payable[](0);
// 		s_lastTimeStamp = block.timestamp;

// 		for (uint256 i = 0; i < specialWallets.length; i++) {
// 			hasUsedFreeEntry[specialWallets[i]] = false;
// 		}
// 	}

// 	function claimWinnings() external {
// 		uint256 amount = winnings[msg.sender];
// 		require(amount > 0, "No winnings to claim");

// 		winnings[msg.sender] = 0; // Prevent re-entrancy by setting to 0 before transfer
// 		(bool success, ) = msg.sender.call{ value: amount }("");
// 		require(success, "Failed to send winnings");
// 	}

// 	function getBalance() public view returns (uint256) {
// 		return address(this).balance;
// 	}

// 	function getRaffleState() public view returns (RaffleState) {
// 		return s_raffleState;
// 	}

// 	function getEntranceFee() public view returns (uint256) {
// 		return i_entranceFee;
// 	}

// 	function getPlayer(uint256 index) public view returns (address) {
// 		return s_players[index];
// 	}

// 	function getRecentWinners() public view returns (address payable[] memory) {
// 		return s_recentWinners;
// 	}

// 	function getLastTimeStamp() public view returns (uint256) {
// 		return s_lastTimeStamp;
// 	}

// 	function getNumberOfPlayers() public view returns (uint256) {
// 		return s_players.length;
// 	}

// 	function addSpecialWallet(address _wallet) external onlyOwner {
// 		specialWallets.push(_wallet);
// 	}

// 	function removeSpecialWallet(address _wallet) external onlyOwner {
// 		for (uint256 i = 0; i < specialWallets.length; i++) {
// 			if (specialWallets[i] == _wallet) {
// 				specialWallets[i] = specialWallets[specialWallets.length - 1];
// 				specialWallets.pop();
// 				break;
// 			}
// 		}
// 	}

// 	// Function to update the entrance fee
// 	function setEntranceFee(uint256 _newEntranceFee) external onlyOwner {
// 		i_entranceFee = _newEntranceFee;
// 	}

// 	function setTreasury(address payable _newTreasury) public onlyOwner {
// 		require(
// 			_newTreasury != address(0),
// 			"New treasury cannot be the zero address"
// 		);
// 		treasury = _newTreasury;
// 		emit TreasuryChanged(_newTreasury);
// 	}

// 	function transferTreasuryFunds(address payable _to) public onlyOwner {
// 		require(_to != address(0), "Invalid address");
// 		require(treasuryAmount > 0, "No treasury to transfer");

// 		uint256 amountToTransfer = treasuryAmount;
// 		treasuryAmount = 0; // Reset remains before transfer to prevent re-entrancy attack
// 		(bool success, ) = _to.call{ value: amountToTransfer }("");
// 		require(success, "Transfer failed");
// 	}

// 	function transfer(address payable _to) public onlyOwner {
// 		require(_to != address(0), "Invalid address");
// 		uint256 amountToTransfer = address(this).balance;

// 		require(amountToTransfer > 0, "No eth to transfer");

// 		(bool success, ) = _to.call{ value: amountToTransfer }("");
// 		require(success, "Transfer failed");
// 	}

// 	function refundAllParticipants() external onlyOwner nonReentrant {
// 		require(s_raffleState == RaffleState.CALCULATING);
// 		uint256 playerCount = s_players.length;

// 		for (uint256 i = 0; i < playerCount; i++) {
// 			address payable player = s_players[i];
// 			// Attempt to refund each player individually
// 			(bool success, ) = player.call{ value: i_entranceFee }("");
// 			if (success) {
// 				emit RefundIssued(player, i_entranceFee);
// 			} else {
// 				emit RefundFailed(player, i_entranceFee);
// 			}
// 		}
// 		s_raffleState = RaffleState.OPEN;
// 		delete s_players;
// 	}

// 	receive() external payable {}
// }
