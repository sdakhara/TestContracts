//SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract DemoToken is ERC20 {
    using SafeMath for uint;
    uint256 private totalSupply_;
    uint public totalClaim = 0;
    address[] initialAddress = [
        0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2,
        0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db,
        0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB,
        0x617F2E2fD72FD9D5503197092aC168c91465E7f2,
        0x17F6AD8Ef982297579C203069C1DbfFE4348c372
    ];
    mapping(address=>uint) public limit;    

    event ClaimedToken(address Address, uint Amount, uint Time);
    constructor(uint256 _totalSupply) ERC20("DemoToken", "DTK") {
        totalSupply_ = _totalSupply;
        _mint(address(this),totalSupply_.div(100).mul(50));
        for(uint8 i=0;i<5;i++){
            if(i<2){
            _mint(initialAddress[i],totalSupply_.div(100).mul(5));
            }else if(i<4){
            _mint(initialAddress[i],totalSupply_.div(100).mul(10));
            }else{
            _mint(initialAddress[i],totalSupply_.div(100).mul(20));
            }
            limit[initialAddress[i]] = totalSupply_.div(100).mul(10);
        }   
    }
    
    function decimals() public override pure returns(uint8) {
        return 6;
    }
    
    function totalSupply() public view  override returns (uint256) {
        return totalSupply_;
    }

    function claim(uint _amount) public {
        require(isWhitelistAddress(msg.sender),"You are not in whitelist");
        require(isClaimable(_amount,msg.sender),"You can't claim this much of token");
        super._transfer(address(this),msg.sender,_amount);
        limit[msg.sender] -= _amount; 
        totalClaim += _amount;
        emit ClaimedToken(msg.sender,_amount,block.timestamp);
    }

    function isWhitelistAddress(address _address) public view returns(bool) {
        for(uint8 i = 0; i<5;i++){
            if(initialAddress[i]==_address){
                return true;
            }
        }
        return false;
    }

    function isClaimable(uint _amount, address _address) public view returns(bool) {
        if(limit[_address]>=_amount){
            return true;
        }
        return false;
    }

    function availableTokens() public view returns(uint256) {
        return super.balanceOf(address(this));
    }

    function claimPerAccount(address _address) public view returns(uint256) {
        return totalSupply_.div(100).mul(10) - limit[_address];  
    }
}
