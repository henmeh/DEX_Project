const Exchange = artifacts.require("Exchange")
const Token = artifacts.require("Token")
const { reverts } = require("truffle-assertions");
const truffleAssert = require("truffle-assertions");

contract("Exchange", accounts => {
    it("should throw an error if ETH balance is too low when creating BUY limit order", async () => {
        let exchange = await Exchange.deployed()
        let token = await Token.deployed()
        await truffleAssert.reverts(
            exchange.createLimitOrder(0, web3.utils.fromUtf8(token.symbol()), 10, 1)
        )
        exchange.depositEth({value: 10})
        await truffleAssert.passes(
            exchange.createLimitOrder(0, web3.utils.fromUtf8(token.symbol()), 10, 1)
        )
    })

    it("should be possible to sell tokens with enough balance", async () => {
        let exchange = await Exchange.deployed();
        let token = await Token.deployed();

        await truffleAssert.reverts(exchange.createLimitOrder(1, web3.utils.fromUtf8(token.symbol()), 10, 1));

        await token.approve(exchange.address, 500);
        await exchange.addToken(web3.utils.fromUtf8(token.symbol()), token.address);
        await exchange.deposit(10, web3.utils.fromUtf8(token.symbol()));

        await truffleAssert.passes(exchange.createLimitOrder(1, web3.utils.fromUtf8(token.symbol()), 10, 1));
    })

    it("buy orderbook should be orderd from highest to lowest price", async () => {
        let exchange = await Exchange.deployed();
        let token = await Token.deployed();
        await token.approve(exchange.address, 500);
        await exchange.depositEth({value: 3000});
        await exchange.createLimitOrder(0, web3.utils.fromUtf8(token.symbol()), 1, 300);
        await exchange.createLimitOrder(0, web3.utils.fromUtf8(token.symbol()), 1, 100);
        await exchange.createLimitOrder(0, web3.utils.fromUtf8(token.symbol()), 1, 200);

        let orderbook = await exchange.getOrderBook(web3.utils.fromUtf8(token.symbol()), 0);
        assert(orderbook.length > 0);
        if(orderbook.length > 0) {        
            for(let i = 0; i < orderbook.length - 1; i++){
                assert(orderbook[i].price >= orderbokk[i+1].price);
            }
        }
    })

    it("sell orderbook should ordered from lowest to highest price", async () => {
        let exchange = await Exchange.deployed();
        let token = await Token.deployed();
        await token.approve(exchange.address, 500);
        await exchange.createLimitOrder(1, web3.utils.fromUtf8(token.symbol()), 1, 300);
        await exchange.createLimitOrder(1, web3.utils.fromUtf8(token.symbol()), 1, 100);
        await exchange.createLimitOrder(1, web3.utils.fromUtf8(token.symbol()), 1, 200);

        let orderbook = await exchange.getOrderBook(web3.utils.fromUtf8(token.symbol()), 1);
        assert(orderbook.length > 0);
        if(orderbook.length > 0) {
            for(let i = 0; i < orderbook.length - 1; i++){
                assert(orderbook[i].price <= orderbokk[i+1].price);
            }
        }
    })
})