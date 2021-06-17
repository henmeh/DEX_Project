Moralis.Cloud.define("getTransactions", function(request) {
	const address = request.params.address;
  	const query = new Parse.Query("EthTransactions");
	query.equalTo("to_address", address);
	query.descending("block_number");
	query.limit(10);
	return query.find();
});

Moralis.Cloud.define("getTokenBalances", async (request) => {
    const query = new Moralis.Query("EthTokenBalance");
    query.equalTo("address", request.params.address);
    const tokenbalance = await query.find();
    const results = [];
    if (!tokenbalance) return;
    for(let i = 0; i < tokenbalance.length; ++i) {
        if (tokenbalance[i].attributes["balance"] == "0") {
            tokenbalance[i].destroy();
        }
        results.push(tokenbalance[i]);
    }
   return results;
});

  Moralis.Cloud.define("getEthBalance", async (request) => {
    const query = new Moralis.Query("EthBalance");
    query.equalTo("address", request.params.address);
    const result = await query.first();
    const ethbalance = result.get("balance")
   return ethbalance;
  });

Moralis.Cloud.define("getTokenOnExchange", async (request) => {
	const query = new Moralis.Query("EthTokenBalance");
  	query.equalTo("address", "0x75fc08b6dae7619de7d6d480dd38ace2b3fc2732");
  	query.equalTo("symbol", request.params.ticker);
  	const result = await query.first();
  	const decimals = result.get("decimals");
  return decimals;
});
