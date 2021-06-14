const Token = artifacts.require("Token");
const Exchange = artifacts.require("Exchange");

module.exports = async function (deployer, network, accounts) {
  await deployer.deploy(Token);
  let exchange = await Exchange.deployed();
  let token = await Token.deployed();

  await token.approve(exchange.address, web3.utils.toWei(web3.utils.toBN(50000), "ether"));
  await exchange.addToken(web3.utils.fromUtf8(token.symbol()), token.address);
  await exchange.deposit(web3.utils.toWei(web3.utils.toBN(50000), "ether"), web3.utils.fromUtf8(token.symbol()));
};
