// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ReverseString {

    function reverseString(string memory str) public pure returns (string memory) {
        //字符串转bytes
        bytes memory strBytes = bytes(str);
        uint256 length = strBytes.length;

        if (length <= 1) {
            return str;
        }

        bytes memory revertedBytes = new bytes(length);
        for (uint256 i = 0; i < length; i++) {
            revertedBytes[i] = strBytes[length - 1 - i];
        }
        return string(revertedBytes);
    }
}

