const Token = artifacts.require("Token");
const Exchange = artifacts.require("Exchange");

module.exports = async function (deployer, network, accounts) {
  await deployer.deploy(Token);
  let exchange = await Exchange.deployed();
  let token = await Token.deployed();

  //await token.approve(exchange.address, 500);
  //await exchange.addToken(web3.utils.fromUtf8(token.symbol()), token.address);
  //await exchange.deposit(500, web3.utils.fromUtf8(token.symbol()));
};
