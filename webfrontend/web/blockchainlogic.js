Moralis.initialize("V1ViKys0NnZgMieLR6DFI1NL540dJ99FNAtPx1eR")
Moralis.serverURL = "https://sjusebrz6wqr.moralis.io:2053/server";

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

async function createLimitOrder(_side, _ticker, _amount, _price) {
    try {
        //_side = 0 or 1
        // _ticker = String
        // _amount = String
        // _price = String
        user = await Moralis.User.current();
        const userAddress = user.get("ethAddress");
        let limitOrder = await ExchangeInstance.methods.createLimitOrder(_side, web3.utils.fromUtf8(_ticker), web3.utils.toBN(_amount), web3.utils.toBN(_price)).send({from: userAddress});
    } catch (error) { console.log(error); }
}

async function createMarketOrder(_side, _ticker, _amount) {
    try {
        //_side = 0 or 1
        // _ticker = String
        // _amount = String
        user = await Moralis.User.current();
        const userAddress = user.get("ethAddress");
        let marketOrder = await ExchangeInstance.methods.createMarketOrder(_side, web3.utils.fromUtf8(_ticker), web3.utils.toBN(_amount)).send({from: userAddress});
    } catch (error) { console.log(error); }
}

async function getOrderBook(_ticker, _side) {
    try {
        //_side = 0 or 1
        // _ticker = String
        let orderBook = await ExchangeInstance.methods.getOrderBook(web3.utils.fromUtf8(_ticker), _side).call();
    } catch (error) { console.log(error); }
}

async function depositToken(_amount, _ticker) {
    try {
        //_amount = String
        // _ticker = String
        user = await Moralis.User.current();
        const userAddress = user.get("ethAddress");
        let approve = await TokenInstance.methods.approve(addresses["exchange"], web3.utils.toWei(web3.utils.toBN(_amount), "ether")).send({from: userAddress});
        let deposit = await ExchangeInstance.methods.deposit(web3.utils.toWei(web3.utils.toBN(_amount), "ether"), web3.utils.fromUtf8(_ticker)).send({from: userAddress});
    } catch (error) { console.log(error); }
}

async function withdrawToken(_amount, _ticker) {
    try {
        //_amount = String
        // _ticker = String
        user = await Moralis.User.current();
        const userAddress = user.get("ethAddress");
        let withdraw = await ExchangeInstance.methods.withdraw(web3.utils.toWei(web3.utils.toBN(_amount), "ether"), web3.utils.fromUtf8(_ticker)).send({from: userAddress});
    } catch (error) { console.log(error); }
}

async function depositEth(_amount) {
    try {
        //_amount = String
        user = await Moralis.User.current();
        const userAddress = user.get("ethAddress");
        let deposit = await ExchangeInstance.methods.depositEth().send({from: userAddress, value: web3.utils.toWei(web3.utils.toBN(_amount), "ether")});
    } catch (error) { console.log(error); }
}

async function withdrawEth(_amount) {
    try {
        //_amount = String
        user = await Moralis.User.current();
        const userAddress = user.get("ethAddress");
        let withdraw = await ExchangeInstance.methods.withdrawEth(web3.utils.toWei(web3.utils.toBN(_amount), "ether")).send({from: userAddress});
    } catch (error) { console.log(error); }
}

async function addToken(_ticker, _address) {
    try {
        //_ticker = String
        //_address = String
        user = await Moralis.User.current();
        const userAddress = user.get("ethAddress");
        let add = await ExchangeInstance.methods.addToken(web3.utils.fromUtf8(_ticker), _address).send({from: userAddress});
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