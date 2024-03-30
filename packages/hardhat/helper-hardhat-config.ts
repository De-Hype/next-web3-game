interface networkConfigProps {
  [key: string]: {
    name: string;
    vrfCoordinatorv2?: string;
    keyHash: string;
    subscriptionId: string;
    callBackGasLimit: string;
    link_feed: string;
    interval?: string;
  };
}

/* https://docs.chain.link/vrf/v2/subscription/supported-networks */

export const networkConfig: networkConfigProps = {
  31337: {
    name: "hardhat",
    keyHash: "0x79d3d8832d904592c0bf9818b621522c988bb8b0c05cdc3b15aea1b6e8db0c15",
    callBackGasLimit: "500000",
    subscriptionId: "0",
    link_feed: "0x42585eD362B3f1BCa95c640FdFf35Ef899212734",
    vrfCoordinatorv2: "",
  },

  // 42161: {
  //   name: "arbitrumOne",
  //   vrfCoordinatorv2: "0x41034678D6C633D8a95c75e1138A360a28bA15d1",
  //   keyHash: "0x68d24f9a037a649944964c2a1ebd0b2918f4a243d2a99701cc22b548cf2daff0",
  //   callBackGasLimit: "2500000",
  //   subscriptionId: "91",
  //   link_feed: "0xb7c8Fb1dB45007F98A68Da0588e1AA524C317f27", // link/eth
  // },

  421614: {
    name: "arbitrumSepolia",
    vrfCoordinatorv2: "0x50d47e4142598E3411aA864e08a44284e471AC6f",
    keyHash: "0x027f94ff1465b3525f9fc03e9ff7d6d2c0953482246dd6ae07570c45d6631414",
    callBackGasLimit: "2500000",
    subscriptionId: "146",
    link_feed: "0x3ec8593F930EA45ea58c968260e6e9FF53FC934f", // link/eth
  },
};

export default networkConfig;
