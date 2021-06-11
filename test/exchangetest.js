const Exchange = artifacts.require("Exchange")
const Token = artifacts.require("Token")
const truffleAssert = require("truffle-assertions");

contract("Exchange", accounts => {
    it("should throw an error if ETH balance is too low when creating BUY limit order", async () => {
        let exchange = await Exchange.deployed();
        let token = await Token.deployed();
        await truffleAssert.reverts(
            exchange.createLimitOrder(0, web3.utils.fromUtf8(token.symbol()), 10, 1)
        );
        exchange.depositEth({ value: 10 });
        await truffleAssert.passes(
            exchange.createLimitOrder(0, web3.utils.fromUtf8(token.symbol()), 10, 1)
        );
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
        await exchange.depositEth({ value: 3000 });
        await exchange.createLimitOrder(0, web3.utils.fromUtf8(token.symbol()), 1, 300);
        await exchange.createLimitOrder(0, web3.utils.fromUtf8(token.symbol()), 1, 100);
        await exchange.createLimitOrder(0, web3.utils.fromUtf8(token.symbol()), 1, 200);

        let orderbook = await exchange.getOrderBook(web3.utils.fromUtf8(token.symbol()), 0);
        if (orderbook.length > 0) {
            for (let i = 0; i < orderbook.length - 1; i++) {
                assert(orderbook[i].price >= orderbook[i + 1].price);
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
        if (orderbook.length > 0) {
            for (let i = 0; i < orderbook.length - 1; i++) {
                assert(orderbook[i].price <= orderbook[i + 1].price);
            }
        }
    })
})

contract("Exchange", accounts => {
    it("Should throw an error when creating a sell market order without adequate token balance", async () => {
        let exchange = await Exchange.deployed()
        let token = await Token.deployed()

        let balance = await exchange.balances(accounts[0], web3.utils.fromUtf8(token.symbol()))
        assert.equal( balance.toNumber(), 0, "Initial token balance is not 0" );
        
        await truffleAssert.reverts(
            exchange.createMarketOrder(1, web3.utils.fromUtf8(token.symbol()), 10)
        )
    })
    //Market orders can be submitted even if the order book is empty
    it("Market orders can be submitted even if the order book is empty", async () => {
        let exchange = await Exchange.deployed()
        let token = await Token.deployed()
        
        await exchange.depositEth({value: 50000});

        let orderbook = await exchange.getOrderBook(web3.utils.fromUtf8(token.symbol()), 0); //Get buy side orderbook
        assert(orderbook.length == 0, "Buy side Orderbook length is not 0");
        
        await truffleAssert.passes(
            exchange.createMarketOrder(0, web3.utils.fromUtf8(token.symbol()), 10)
        )
    })
    //Market orders should be filled until the order book is empty or the market order is 100% filled
    it("Market orders should not fill more limit orders than the market order amount", async () => {
        let exchange = await Exchange.deployed()
        let token = await Token.deployed()

        let orderbook = await exchange.getOrderBook(web3.utils.fromUtf8(token.symbol()), 1); //Get sell side orderbook
        assert(orderbook.length == 0, "Sell side Orderbook should be empty at start of test");

        await exchange.addToken(web3.utils.fromUtf8(token.symbol()), token.address)


        //Send token tokens to accounts 1, 2, 3 from account 0
        await token.transfer(accounts[1], 150)
        await token.transfer(accounts[2], 150)
        await token.transfer(accounts[3], 150)

        //Approve exchange for accounts 1, 2, 3
        await token.approve(exchange.address, 50, {from: accounts[1]});
        await token.approve(exchange.address, 50, {from: accounts[2]});
        await token.approve(exchange.address, 50, {from: accounts[3]});

        //Deposit token into exchange for accounts 1, 2, 3
        await exchange.deposit(50, web3.utils.fromUtf8(token.symbol()), {from: accounts[1]});
        await exchange.deposit(50, web3.utils.fromUtf8(token.symbol()), {from: accounts[2]});
        await exchange.deposit(50, web3.utils.fromUtf8(token.symbol()), {from: accounts[3]});

        //Fill up the sell order book
        await exchange.createLimitOrder(1, web3.utils.fromUtf8(token.symbol()), 5, 300, {from: accounts[1]})
        await exchange.createLimitOrder(1, web3.utils.fromUtf8(token.symbol()), 5, 400, {from: accounts[2]})
        await exchange.createLimitOrder(1, web3.utils.fromUtf8(token.symbol()), 5, 500, {from: accounts[3]})

        //Create market order that should fill 2/3 orders in the book
        await exchange.createMarketOrder(0, web3.utils.fromUtf8(token.symbol()), 10);

        orderbook = await exchange.getOrderBook(web3.utils.fromUtf8(token.symbol()), 1); //Get sell side orderbook
        assert(orderbook.length == 1, "Sell side Orderbook should only have 1 order left");
        assert(orderbook[0].filled == 0, "Sell side order should have 0 filled");

    })
    //Market orders should be filled until the order book is empty or the market order is 100% filled
    it("Market orders should be filled until the order book is empty", async () => {
        let exchange = await Exchange.deployed()
        let token = await Token.deployed()

        let orderbook = await exchange.getOrderBook(web3.utils.fromUtf8(token.symbol()), 1); //Get sell side orderbook
        assert(orderbook.length == 1, "Sell side Orderbook should have 1 order left");

        //Fill up the sell order book again
        await exchange.createLimitOrder(1, web3.utils.fromUtf8(token.symbol()), 5, 400, {from: accounts[1]})
        await exchange.createLimitOrder(1, web3.utils.fromUtf8(token.symbol()), 5, 500, {from: accounts[2]})

        //check buyer token balance before token purchase
        let balanceBefore = await exchange.balances(accounts[0], web3.utils.fromUtf8(token.symbol()))

        //Create market order that could fill more than the entire order book (15 token)
        await exchange.createMarketOrder(0, web3.utils.fromUtf8(token.symbol()), 50);

        //check buyer token balance after token purchase
        let balanceAfter = await exchange.balances(accounts[0], web3.utils.fromUtf8(token.symbol()))

        //Buyer should have 15 more token after, even though order was for 50. 
        assert.equal(balanceBefore.toNumber() + 15, balanceAfter.toNumber());
    })

    //The eth balance of the buyer should decrease with the filled amount
    it("The eth balance of the buyer should decrease with the filled amount", async () => {
        let exchange = await Exchange.deployed()
        let token = await Token.deployed()

        //Seller deposits token and creates a sell limit order for 1 token for 300 wei
        await token.approve(exchange.address, 500, {from: accounts[1]});
        await exchange.createLimitOrder(1, web3.utils.fromUtf8(token.symbol()), 1, 300, {from: accounts[1]})

        //Check buyer ETH balance before trade
        let balanceBefore = await exchange.balances(accounts[0], web3.utils.fromUtf8("ETH"));
        await exchange.createMarketOrder(0, web3.utils.fromUtf8(token.symbol()), 1);
        let balanceAfter = await exchange.balances(accounts[0], web3.utils.fromUtf8("ETH"));

        assert.equal(balanceBefore.toNumber() - 300, balanceAfter.toNumber());
    })

    //The token balances of the limit order sellers should decrease with the filled amounts.
    it("The token balances of the limit order sellers should decrease with the filled amounts.", async () => {
        let exchange = await Exchange.deployed()
        let token = await Token.deployed()

        let orderbook = await exchange.getOrderBook(web3.utils.fromUtf8(token.symbol()), 1); //Get sell side orderbook
        assert(orderbook.length == 0, "Sell side Orderbook should be empty at start of test");

        //Seller Account[2] deposits token
        await token.approve(exchange.address, 500, {from: accounts[2]});
        await exchange.deposit(100, web3.utils.fromUtf8(token.symbol()), {from: accounts[2]});

        await exchange.createLimitOrder(1, web3.utils.fromUtf8(token.symbol()), 1, 300, {from: accounts[1]})
        await exchange.createLimitOrder(1, web3.utils.fromUtf8(token.symbol()), 1, 400, {from: accounts[2]})

        //Check sellers token balances before trade
        let account1balanceBefore = await exchange.balances(accounts[1], web3.utils.fromUtf8(token.symbol()));
        let account2balanceBefore = await exchange.balances(accounts[2], web3.utils.fromUtf8(token.symbol()));

        //Account[0] created market order to buy up both sell orders
        await exchange.createMarketOrder(0, web3.utils.fromUtf8(token.symbol()), 2);

        //Check sellers token balances after trade
        let account1balanceAfter = await exchange.balances(accounts[1], web3.utils.fromUtf8(token.symbol()));
        let account2balanceAfter = await exchange.balances(accounts[2], web3.utils.fromUtf8(token.symbol()));

        assert.equal(account1balanceBefore.toNumber() - 1, account1balanceAfter.toNumber());
        assert.equal(account2balanceBefore.toNumber() - 1, account2balanceAfter.toNumber());
    })

    //Filled limit orders should be removed from the orderbook
    it("Filled limit orders should be removed from the orderbook", async () => {
        let exchange = await Exchange.deployed();
        let token = await Token.deployed();
        await exchange.addToken(web3.utils.fromUtf8(token.symbol()), token.address)

        //Seller deposits token and creates a sell limit order for 1 token for 300 wei
        await token.approve(exchange.address, 500);
        await exchange.deposit(50, web3.utils.fromUtf8(token.symbol()));
        
        await exchange.depositEth({value: 10000});

        let orderbook = await exchange.getOrderBook(web3.utils.fromUtf8(token.symbol()), 1); //Get sell side orderbook

        await exchange.createLimitOrder(1, web3.utils.fromUtf8(token.symbol()), 1, 300)
        await exchange.createMarketOrder(0, web3.utils.fromUtf8(token.symbol()), 1);

        orderbook = await exchange.getOrderBook(web3.utils.fromUtf8(token.symbol()), 1); //Get sell side orderbook
        assert(orderbook.length == 0, "Sell side Orderbook should be empty after trade");
    })

    //Partly filled limit orders should be modified to represent the filled/remaining amount
    it("Limit orders filled property should be set correctly after a trade", async () => {
        let exchange = await Exchange.deployed()
        let token = await Token.deployed()

        let orderbook = await exchange.getOrderBook(web3.utils.fromUtf8(token.symbol()), 1); //Get sell side orderbook
        assert(orderbook.length == 0, "Sell side Orderbook should be empty at start of test");

        await exchange.createLimitOrder(1, web3.utils.fromUtf8(token.symbol()), 5, 300, {from: accounts[1]})
        await exchange.createMarketOrder(0, web3.utils.fromUtf8(token.symbol()), 2);

        orderbook = await exchange.getOrderBook(web3.utils.fromUtf8(token.symbol()), 1); //Get sell side orderbook
        assert.equal(orderbook[0].filled, 2);
        assert.equal(orderbook[0].amount, 5);
    })
    //When creating a BUY market order, the buyer needs to have enough ETH for the trade
    it("Should throw an error when creating a buy market order without adequate ETH balance", async () => {
        let exchange = await Exchange.deployed()
        let token = await Token.deployed()
        
        let balance = await exchange.balances(accounts[4], web3.utils.fromUtf8("ETH"))
        assert.equal( balance.toNumber(), 0, "Initial ETH balance is not 0" );
        await exchange.createLimitOrder(1, web3.utils.fromUtf8(token.symbol()), 5, 300, {from: accounts[1]})

        await truffleAssert.reverts(
            exchange.createMarketOrder(0, web3.utils.fromUtf8(token.symbol()), 5, {from: accounts[4]})
        )
    })
})