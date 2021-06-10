pragma solidity >=0.6.0 <=0.8.0;

import "../node_modules/@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../node_modules/@openzeppelin/contracts/utils/math/SafeMath.sol";
import "../node_modules/@openzeppelin/contracts/access/Ownable.sol";

contract Wallet is Ownable {

    using SafeMath for uint;

    struct Token {
        bytes32 ticker;
        address tokenAddress;
    }

    mapping(bytes32 => Token) public tokenMapping;
    bytes32[] public tokenList;
    
    // Mapping Useraddress => Tokenshortcode => balance 
    mapping(address => mapping (bytes32 => uint)) public balances;

    function addToken(bytes32 ticker, address tokenAddress) onlyOwner external {
        //require(tokenMapping[ticker].ticker == bytes32(0) && tokenMapping[ticker].tokenAddress == address(0), "token already exists");
        tokenMapping[ticker] = Token(ticker, tokenAddress);
        tokenList.push(ticker);
    }

    function deposit(uint amount, bytes32 ticker) external {
        require(tokenMapping[ticker].tokenAddress != address(0), "token is not added to wallet");

        IERC20(tokenMapping[ticker].tokenAddress).transferFrom(msg.sender, address(this), amount);

        balances[msg.sender][ticker] = balances[msg.sender][ticker].add(amount);        
    }

    function withdraw(uint amount, bytes32 ticker) external {
        require(tokenMapping[ticker].tokenAddress != address(0), "token is not added to wallet");
        require(balances[msg.sender][ticker] >= amount, "not enough funds to withdraw");
                
        balances[msg.sender][ticker] = balances[msg.sender][ticker].sub(amount);
        IERC20(tokenMapping[ticker].tokenAddress).transfer(msg.sender, amount);
    }

    function depositEth() payable external {
        balances[msg.sender][bytes32("ETH")] = balances[msg.sender][bytes32("ETH")].add(msg.value);
    }
    
    function withdrawEth(uint amount) external {
        require(balances[msg.sender][bytes32("ETH")] >= amount,'Insuffient balance'); 
        balances[msg.sender][bytes32("ETH")] = balances[msg.sender][bytes32("ETH")].sub(amount);
        msg.sender.call{value:amount}("");
    }
}