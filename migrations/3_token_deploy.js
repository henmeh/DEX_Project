const Token = artifacts.require("Token");
const Wallet = artifacts.require("Wallet");

module.exports = async function (deployer, network, accounts) {
  deployer.deploy(Token);
  let wallet = await Wallet.deployed();
  let token = await Token.deployed();

  await token.approve(wallet.address, 500);
  await wallet.addToken(web3.utils.fromUtf8(token.symbol()), token.address);
  await wallet.deposit(500, web3.utils.fromUtf8(token.symbol()));
};
