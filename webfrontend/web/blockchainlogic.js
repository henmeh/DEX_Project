Moralis.initialize("your moralis server id")
Moralis.serverURL = "your moralis server";

async function init() {
    window.web3 = await Moralis.Web3.enable();
    window.ExchangeInstance = new web3.eth.Contract(exchangeAbi, addresses["exchange"]);
    window.TokenInstance = new web3.eth.Contract(tokenAbi, addresses["token"]);
}

init()

async function getTokens() {
    try {
        let tokens = await ExchangeInstance.methods.getTokenlist().call();
        let tokenList = [];
        for(var i=0; i < tokens.length; i++) {
            let token = web3.utils.toUtf8(tokens[i]);
            tokenList.push(token);
        }
        return tokenList;
    } catch (error) { console.log(error); }
}

async function getTokenDecimal(_ticker) {
    try {
        const params = { ticker: _ticker};
        const decimals = await Moralis.Cloud.run("getTokenOnExchange", params);
        return decimals;
    } catch (error) { console.log(error); }
}

async function createLimitOrder(_side, _ticker, _amount, _price) {
    try {
        //ask Moralis for decimals
        const params = { ticker: _ticker };
        const decimals = await Moralis.Cloud.run("getTokenOnExchange", params);
                
        //_side = 0 or 1
        // _ticker = String
        // _amount = String
        // _price = String

        //getting the decimals for price
        var priceDecimals;
        
        if (_price.indexOf(".") !== -1 && _price.indexOf("-") !== -1) {
            priceDecimals = _price.split("-")[1] || 0;
        } else if (_price.indexOf(".") !== -1) {
            priceDecimals = _price.split(".")[1].length || 0;
        } else {
            priceDecimals = _price.split("-")[1] || 0;
        }

        const _tradingAmount = parseFloat(_amount) * Math.pow(10, parseFloat(decimals));
        const _tradingPrice = parseFloat(_price) * Math.pow(10, priceDecimals);

        user = await Moralis.User.current();
        const userAddress = user.get("ethAddress");
        let limitOrder = await ExchangeInstance.methods.createLimitOrder(_side, web3.utils.fromUtf8(_ticker), _tradingAmount.toString(), _tradingPrice.toString(), Math.pow(10, priceDecimals).toString()).send({from: userAddress});
        return limitOrder["status"];
    } catch (error) { console.log(error); }
}

async function createMarketOrder(_side, _ticker, _amount) {
    try {
        //ask Moralis for decimals
        const params = { ticker: _ticker };
        const decimals = await Moralis.Cloud.run("getTokenOnExchange", params);
        //_side = 0 or 1
        // _ticker = String
        // _amount = String
        const _tradingAmount = parseFloat(_amount) * Math.pow(10, parseFloat(decimals)); 
        
        user = await Moralis.User.current();
        const userAddress = user.get("ethAddress");
        let marketOrder = await ExchangeInstance.methods.createMarketOrder(_side, web3.utils.fromUtf8(_ticker), _tradingAmount.toString()).send({from: userAddress});
        return marketOrder["status"];

    } catch (error) { console.log(error); }
}

async function getOrderBook(_ticker, _side) {
    try {
        //_side = 0 or 1
        // _ticker = String
        let orderBook = await ExchangeInstance.methods.getOrderBook(web3.utils.fromUtf8(_ticker), _side).call();
        return orderBook;
    } catch (error) { console.log(error); }
}

async function getExchangeBalance(_ticker) {
    try {
        user = await Moralis.User.current();
        const userAddress = user.get("ethAddress");
        let balance;
        if(_ticker == "Eth") {
            balance = await ExchangeInstance.methods.balances(userAddress, web3.utils.fromUtf8("ETH")).call();
        } else {
            balance = await ExchangeInstance.methods.balances(userAddress, web3.utils.fromUtf8(_ticker)).call();
        }
        return balance;
    } catch (error) { console.log(error); }
}

async function depositToken(_amount, _ticker) {
    try {
        //_amount = String
        // _ticker = String
        user = await Moralis.User.current();
        const userAddress = user.get("ethAddress");
        await TokenInstance.methods.approve(addresses["exchange"], _amount).send({from: userAddress});
        let deposit = await ExchangeInstance.methods.deposit(_amount, web3.utils.fromUtf8(_ticker)).send({from: userAddress});
        return deposit["status"];

    } catch (error) { console.log(error); }
}

async function withdrawToken(_amount, _ticker) {
    try {
        //_amount = String
        // _ticker = String
        user = await Moralis.User.current();
        const userAddress = user.get("ethAddress");
        let withdraw = await ExchangeInstance.methods.withdraw(_amount, web3.utils.fromUtf8(_ticker)).send({from: userAddress});
        return withdraw["status"];

    } catch (error) { console.log(error); }
}

async function depositEth(_amount) {
    try {
        //_amount = String
        user = await Moralis.User.current();
        const userAddress = user.get("ethAddress");
        let deposit = await ExchangeInstance.methods.depositEth().send({from: userAddress, value: web3.utils.toWei(_amount, "ether")});
        return deposit["status"];

    } catch (error) { console.log(error); }
}

async function withdrawEth(_amount) {
    try {
        //_amount = String
        user = await Moralis.User.current();
        const userAddress = user.get("ethAddress");
        let withdraw = await ExchangeInstance.methods.withdrawEth(web3.utils.toWei(_amount, "ether")).send({from: userAddress});
        return withdraw["status"];

    } catch (error) { console.log(error); }
}

async function addToken(_ticker, _address) {
    try {
        //_ticker = String
        //_address = String
        user = await Moralis.User.current();
        const userAddress = user.get("ethAddress");
        let add = await ExchangeInstance.methods.addToken(web3.utils.fromUtf8(_ticker), _address).send({from: userAddress});
        return add["status"];

    } catch (error) { console.log(error); }
}

async function loggedIn() {
    try {
        user = await Moralis.User.current();
        let name = user.get("username");
        let avatar = user.get("avatar");
        return [name, avatar];
    } catch (error) { console.log(error); }
}

async function login() {
    try {
        user = await Moralis.User.current();
        if (!user) {
            var user = await Moralis.Web3.authenticate();
        }
        let name = user.get("username");
        let avatar = user.get("avatar");
        return [name, avatar];
    } catch (error) { console.log(error); }
}

async function logout() {
    try {
        user = await Moralis.User.logOut();
        return (Moralis.User.current());
    } catch (error) { console.log(error); }
}

async function getTokenBalances() {
    let tokenBalances = [];
    user = await Moralis.User.current();
    const params = { address: user.attributes.ethAddress };
    const balances = await Moralis.Cloud.run("getTokenBalances", params);
    for (var i = 0; i < balances.length; i++) {
        let balance = JSON.stringify(balances[i]);
        tokenBalances.push(balance);
    }
    return tokenBalances;
}

async function getEthBalance() {
    user = await Moralis.User.current();
    const params = { address: user.attributes.ethAddress };
    const ethbalance = await Moralis.Cloud.run("getEthBalance", params);
    return ethbalance;
}

async function getMyTransactions() {
    const query = new Moralis.Query("EthTransactions");
    query.equalTo("from_address", ethereum.selectedAddress.toLowerCase());
    query.limit(10);
    query.descending("createdAt")
    const transactions = await query.find();
    return JSON.stringify(transactions);
}