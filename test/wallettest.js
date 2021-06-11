const Exchange = artifacts.require("Exchange")
const Token = artifacts.require("Token")
const truffleAssert = require("truffle-assertions");

contract("Exchange", accounts => {
    it("should only be possible for owner to add tokens", async () => {
        let exchange = await Exchange.deployed();
        let token = await Token.deployed();
        await truffleAssert.passes(exchange.addToken(web3.utils.fromUtf8(token.symbol()), token.address, {from: accounts[0]}));
    })

    it("should not be possible for nonowner to add tokens", async () => {
        let exchange = await Exchange.deployed();
        let token = await Token.deployed();
        await truffleAssert.reverts(exchange.addToken(web3.utils.fromUtf8(token.symbol()), token.address, {from: accounts[1]}));
    })

    it("should handle deposits correctly", async () => {
        let exchange = await Exchange.deployed();
        let token = await Token.deployed();
        await token.approve(exchange.address, 500);
        await exchange.deposit(100, web3.utils.fromUtf8(token.symbol()));
        let balance = await exchange.balances(accounts[0], web3.utils.fromUtf8(token.symbol()));
        assert.equal(balance.toNumber(), 100);
    })

    it("should handle faulty withdraws correctly", async () => {
        let exchange = await Exchange.deployed();
        let token = await Token.deployed();
        await truffleAssert.reverts(exchange.withdraw(200, web3.utils.fromUtf8(token.symbol())));
    })

    it("should handle correct withdraws correctly", async () => {
        let exchange = await Exchange.deployed();
        let token = await Token.deployed();
        await truffleAssert.passes(exchange.withdraw(100, web3.utils.fromUtf8(token.symbol())));
    })
})