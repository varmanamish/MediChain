require("@nomicfoundation/hardhat-toolbox");

module.exports = {
  solidity: "0.8.20",

  networks: {
    ganache: {
      url: "http://127.0.0.1:7545",
      accounts: [
        "0x28bbe30f1832b0f0754e4005a456ce604df23be790473c9f313fc1b63a348cba",
        "0x911f157d57fdc49dbeb8e0cacb250843e6aa9519620cb9deb6598eb8d3f969c3",
        "0x4453d2f5af334dafb4645ba20500f1e492637081c6d7b5c96b7f08d087d0194f",
        "0xa36374628f42ff66a4037e6c623499a0c925a54c9ff9b7f5b052d5570838ea8a",
        "0x7a4346df6f2832d8e80c9900b01c5786daef09f44d0427574ccb76d414ddc4bd"
      ]
    }
  }
};
