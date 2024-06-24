// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol"; // Ensure you have the correct path for Ownable
import "./Library/Error.sol"; // Ensure this file exists and is correctly implemented

contract BlumaToken is ERC20, Ownable {
    uint256 public constant MAX_TOTAL_SUPPLY = 100000 * 10000 ** 18; // Maximum total supply
    uint256 public totalMinted; // Tracks the total minted tokens
    uint256 public constant MINT_AMOUNT = 2000; // Max amount a user can mint
    mapping(address => bool) private _hasMinted;
    mapping(address => uint256) private _userBalance;




    constructor() ERC20("BlumaToken", "BLUM")Ownable(msg.sender) {
        _mint(msg.sender, MAX_TOTAL_SUPPLY); 
        totalMinted = MAX_TOTAL_SUPPLY; 
    }

    event TransferSuccessful(address indexed _user, uint256 indexed _amount);

    function mint(address _user, uint256 _amount) public {
        if(_hasMinted[_user]) revert USER_ALREADY_EXCEED_LIMIT();

        if(_userBalance[_user] + _amount > MINT_AMOUNT){
               _hasMinted[_user] = true;
            revert ExceedTotalAmountMinted();
         
        } 
        // if(totalMinted > MAX_TOTAL_SUPPLY) revert EXCEED_TOTAL_SUPPLY_CAP();

        _userBalance[_user] += _amount;
        totalMinted += _amount;
        _mint(_user, _amount);

        emit TransferSuccessful(_user, _amount);
    }



    function totalSupplys() external view returns (uint256) {
        return totalSupply();
    }

    function approval(address _spender, uint256 _value)  external returns (bool){
     return  approve(_spender, _value);
    }


    function remainingSupply() external view returns (uint256) {
        return MAX_TOTAL_SUPPLY - totalMinted;
    }

    function getUserBalance(address _user) external view returns (uint256) {
        return _userBalance[_user];
    }

    function adminMint(address to, uint256 amount) public onlyOwner {
        require(totalMinted + amount <= MAX_TOTAL_SUPPLY, "Exceeds total supply cap");

        totalMinted += amount;
        _mint(to, amount);
    }

    function hasMinted_(address _user) external view returns (bool) {
        return _hasMinted[_user];
    }
}
