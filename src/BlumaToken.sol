// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol"; // Ensure you have the correct path for Ownable
import "./Library/Error.sol"; // Ensure this file exists and is correctly implemented

contract BlumaToken is ERC20, Ownable {

    uint256 public constant MAX_TOTAL_SUPPLY = 10000000000 * 10**18; // Adjust for decimals if necessary
    uint256 public totalMinted; // Tracks the total minted tokens
    uint256 public constant MINT_AMOUNT = 2000 * 10**18; // Adjust for decimals if necessary
    mapping(address => bool) private _hasMinted;
    mapping(address => uint256) private _userBalance;

    constructor() ERC20("BlumaToken", "BLUM") Ownable(msg.sender) {
        totalMinted = 0;
    }

    event TransferSuccessful(address indexed _user, uint256 indexed _amount);

    function mint(address _user, uint256 _amount) public {
        require(_amount <= MINT_AMOUNT, "Amount exceeds mint limit");
        require(!_hasMinted[_user], "User already minted maximum amount");

        uint256 _userAmount = _userBalance[_user] + _amount;

        if (_userAmount > MINT_AMOUNT) {
            revert USER_ALREADY_EXCEED_LIMIT();
        }

        if (totalMinted + _userAmount > MAX_TOTAL_SUPPLY) {
            revert EXCEED_TOTAL_AMOUNT_MINTED();
        }

        _userBalance[_user] = _userAmount;
        totalMinted += _userAmount;
        _mint(_user, _userAmount);

        if (_userAmount == MINT_AMOUNT) {
            _hasMinted[_user] = true;
        }

        emit TransferSuccessful(_user, _userAmount);
    }

    function totalSupplys() external view returns (uint256) {
        return totalSupply();
    }

    function approval(address _spender, uint256 _value) external returns (bool) {
        return approve(_spender, _value);
    }

    function remainingSupply() external view returns (uint256 balance_) {
        require(totalMinted <= MAX_TOTAL_SUPPLY, "Total minted exceeds max supply");
        return MAX_TOTAL_SUPPLY - totalMinted;
    }

    function getUserBalance(address _user) external view returns (uint256) {
        return _userBalance[_user];
    }

    function adminMint(address to, uint256 amount) public onlyOwner {
        uint256 _amount = totalMinted + amount;
        require(_amount <= MAX_TOTAL_SUPPLY, "Exceeds total supply cap");
        totalMinted += amount;
        _mint(to, amount);
    }

    function hasMinted_(address _user) external view returns (bool) {
        return _hasMinted[_user];
    }
}