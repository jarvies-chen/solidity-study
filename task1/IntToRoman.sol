// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract IntToRoman {
    
    uint256[13] values = [
        1000,
        900,
        500,
        400,
        100,
        90,
        50,
        40,
        10,
        9,
        5,
        4,
        1
    ];

    string[13] symbols = [
        "M",
        "CM",
        "D",
        "CD",
        "C",
        "XC",
        "L",
        "XL",
        "X",
        "IX",
        "V",
        "IV",
        "I"
    ]; 


    function intToRoman(uint256 number) public view returns (string memory) {
        string memory result = "";
        for (uint256 i = 0; i < values.length; i++) {
            while (number >= values[i]) {
                result = string(abi.encodePacked(result, symbols[i]));   
                number -= values[i]; 
            }
        }
        return result;
    }
}