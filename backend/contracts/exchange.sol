pragma experimental ABIEncoderV2;

import "./wallet.sol";

contract Exchange is Wallet {

    using SafeMath for uint;

    enum Orderdirection {BUY, SELL}

    struct Order {
        uint id;
        address trader;
        Orderdirection direction;
        bytes32 ticker;
        uint amount;
        uint price;
        uint priceDecimals;
        uint filled;
    }
    
    // Mapping Token => Buy or Sell => Orderbook
    mapping(bytes32 => mapping(uint => Order[])) public orderbook;

    uint public nextOrderId = 0;

    function getOrderBook(bytes32 ticker, Orderdirection direction) view public returns(Order[] memory) {
        return orderbook[ticker][uint(direction)];
    }

    function createLimitOrder(Orderdirection direction, bytes32 ticker, uint amount, uint price, uint priceDecimals) public {
        if(direction == Orderdirection.BUY && priceDecimals == 0) {
            require(balances[msg.sender][bytes32("ETH")] >= (amount.mul(price)));
        }
        else if(direction == Orderdirection.BUY && priceDecimals != 0) {
            require(balances[msg.sender][bytes32("ETH")] >= (amount.mul(price)).div(priceDecimals));
        }
        else if(direction == Orderdirection.SELL) {
            require(balances[msg.sender][ticker] >= amount);
        }

        Order[] storage orders = orderbook[ticker][uint(direction)];
        orders.push(Order(nextOrderId, msg.sender, direction, ticker, amount, price, priceDecimals, 0));
        
        //Bubble sort
        //uint i = orders.length > 0 ? orders.length - 1 : 0;
        
        if(direction == Orderdirection.BUY && orders.length > 1) {
            for(uint i = orders.length - 1; i > 0; i--) {
                if(orders[i].price > orders[i-1].price) {
                    Order memory ordertomove = orders[i];
                    orders[i] = orders[i-1];
                    orders[i-1] = ordertomove;
                }
            }
        }
        
        if(direction == Orderdirection.SELL && orders.length > 1) {
            for(uint i = orders.length - 1; i > 0; i--) {
                if(orders[i].price < orders[i-1].price) {
                    Order memory ordertomove = orders[i];
                    orders[i] = orders[i-1];
                    orders[i-1] = ordertomove;
                }
            }
        }
        
        nextOrderId ++;
    }

    function createMarketOrder(Orderdirection direction, bytes32 ticker, uint amount) public {
        if(direction == Orderdirection.SELL) {
            require(balances[msg.sender][ticker] >= amount, "Insufficient balance");
        }

        Order[] storage orders = orderbook[ticker][direction == Orderdirection.BUY ? 1 : 0];
        uint totalFilled;

        for(uint i = 0; i < orders.length && totalFilled < amount; i++) {
            uint leftToFill = amount.sub(totalFilled);
            uint availableToFill = orders[i].amount.sub(orders[i].filled);
            uint filled = 0;
            if(availableToFill > leftToFill) {
                filled = leftToFill;
            }
            else {
             filled = availableToFill;   
            }
            totalFilled = totalFilled.add(filled);
            orders[i].filled = orders[i].filled.add(filled);
            uint cost = orders[i].priceDecimals != 0 ? (filled.mul(orders[i].price)).div(orders[i].priceDecimals) : (filled.mul(orders[i].price));

            if(direction == Orderdirection.BUY && orders[i].priceDecimals != 0) {
                require(balances[msg.sender][bytes32("ETH")] >= (filled.mul(orders[i].price)).div(orders[i].priceDecimals));
                //Transfer ETH from Buyer to Seller
                balances[msg.sender][bytes32("ETH")] = balances[msg.sender][bytes32("ETH")].sub(cost);
                balances[orders[i].trader][bytes32("ETH")] = balances[orders[i].trader][bytes32("ETH")].add(cost); 
                //Transfer Tokens from Seller to Buyer
                balances[msg.sender][ticker] = balances[msg.sender][ticker].add(filled);
                balances[orders[i].trader][ticker] = balances[orders[i].trader][ticker].sub(filled); 
            }
            else if(direction == Orderdirection.BUY && orders[i].priceDecimals == 0) {
                require(balances[msg.sender][bytes32("ETH")] >= (filled.mul(orders[i].price)));
                //Transfer ETH from Buyer to Seller
                balances[msg.sender][bytes32("ETH")] = balances[msg.sender][bytes32("ETH")].sub(cost);
                balances[orders[i].trader][bytes32("ETH")] = balances[orders[i].trader][bytes32("ETH")].add(cost); 
                //Transfer Tokens from Seller to Buyer
                balances[msg.sender][ticker] = balances[msg.sender][ticker].add(filled);
                balances[orders[i].trader][ticker] = balances[orders[i].trader][ticker].sub(filled); 
            }
            else if (direction == Orderdirection.SELL) {
                //Transfer ETH from Buyer to Seller
                balances[orders[i].trader][bytes32("ETH")] = balances[orders[i].trader][bytes32("ETH")].sub(cost);
                balances[msg.sender][bytes32("ETH")] = balances[msg.sender][bytes32("ETH")].add(cost); 
                //Transfer Tokens from Seller to Buyer
                balances[orders[i].trader][ticker] = balances[orders[i].trader][ticker].add(filled);
                balances[msg.sender][ticker] = balances[msg.sender][ticker].sub(filled); 
            }
        }
        while(orders.length > 0 && orders[0].filled == orders[0].amount) {
            for(uint i = 0; i < orders.length - 1; i++) {
                orders[i] = orders[i+1];
            }
            orders.pop();
        }
    }
}