//SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Test2 {
    using SafeMath for uint;
    ERC20 Token;
    struct Order{
        address Buyer;
        uint Amount;
        bool isClaimed;
        uint claimTime; 
    }

    mapping(uint=>Order) public orderBook;
    mapping(address=>Order[]) userData;
    uint tokenPrice = 1;
    uint orderId = 1;

    event OrderPlaced(uint OrderID, uint BuyTime);
    event OrderClaimed(uint OrderID, uint ClaimTime);
    constructor(address _tokenAddress) {
        Token = ERC20(_tokenAddress);
    }

    function buyTokens(uint _amount) public payable {
        require(msg.value==_amount.mul(tokenPrice),"Insufficiant Paid amount");
        orderBook[orderId] = Order(msg.sender,_amount,false,block.timestamp+3600);
        userData[msg.sender].push(Order(msg.sender,_amount,false,block.timestamp+3600));
        emit OrderPlaced(orderId,block.timestamp);
        orderId++;
    }

    function claim(uint _orderId) public {
        require(isClaimer(msg.sender, _orderId),"You are not the Buyer of this order");
        require(isClaimed(_orderId),"Tokens are already Claimed");
        require(isClaimable(_orderId),"You can't Claim Tokens Now");
        Token.transfer(orderBook[_orderId].Buyer,orderBook[_orderId].Amount);
        emit OrderClaimed(_orderId,block.timestamp);
    }

    function isClaimable(uint _orderId) public view returns(bool){
        if(orderBook[_orderId].claimTime <block.timestamp){
            return (true);
        }
        return (false);
    }

    function isClaimed(uint _orderId) public view returns(bool) {
        if(orderBook[_orderId].isClaimed){
            return false;
        }
        return true;
    }

    function isClaimer(address _user, uint _orderId) public view returns(bool) {
        if(orderBook[_orderId].Buyer==_user){
            return true;
        }
        return false;
    } 
    function getUserData(address _user) public view returns(Order[] memory){
        return userData[_user];
    }
}

