pragma solidity >=0.6.0 <=0.8.0;
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
    }
    
    // Mapping Token => Buy or Sell => Orderbook
    mapping(bytes32 => mapping(uint => Order[])) public orderbook;

    uint public nextOrderId = 0;

    function getOrderBook(bytes32 ticker, Orderdirection direction) view public returns(Order[] memory) {
        return orderbook[ticker][uint(direction)];
    }

    function createLimitOrder(Orderdirection direction, bytes32 ticker, uint amount, uint price) public {
        if(direction == Orderdirection.BUY) {
            require(balances[msg.sender]["ETH"] >= amount.mul(price));
        }
        else if(direction == Orderdirection.SELL) {
            require(balances[msg.sender][ticker] >= amount);
        }

        Order[] storage orders = orderBook[ticker][uint(direction)];
        orders.push(Order(nextOrderId, msg.sender, direction, ticker, amount, price));
        
        //Bubble sort
        if(direction == Orderdirection.BUY) {

        }
        
        if(direction == Orderdirection.SELL) {
            
        }
        
        nextOrderId ++;
    }
}