// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract RomainToInt {
    mapping(bytes1 => uint256) romainValues;

    constructor() {
        romainValues["I"] = 1;
        romainValues["V"] = 5;
        romainValues["X"] = 10;
        romainValues["L"] = 50;
        romainValues["C"] = 100;
        romainValues["D"] = 500;
        romainValues["M"] = 1000;
    } 

    function romainToInt(string memory romainStr) public view returns (uint256) {
        bytes memory bytesStr = bytes(romainStr);

        uint256 preValue = 0;
        uint256 totalValue = 0;
        for (uint256 i = bytesStr.length; i > 0; i--) {
            uint256 currValue = romainValues[bytesStr[i - 1]];

            if (currValue < preValue) {
                totalValue -= currValue;
            } else {
                totalValue += currValue;
            }
            preValue = currValue;
        }
        return totalValue;
    }
}