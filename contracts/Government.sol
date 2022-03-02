//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./library/Regulator.sol";

contract Government is Regulator{

    address public president;

    modifier onlyPresident(){
        require(_msgSender() == president, "You're not the president");
        _;
    }

    constructor(){
        president = _msgSender();
    }

    function _setPresident(address _newPresident) internal onlyRegulator {
        president = _newPresident;
    }
}