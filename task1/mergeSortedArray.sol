// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MergeSortedArray {
    function merge(uint256[] memory arr1, uint256[] memory arr2) public pure returns (uint256[] memory) {
        uint256 length1 = arr1.length;
        uint256 length2 = arr2.length;

        uint256[] memory result = new uint256[](length1 + length2);
        uint256 index1 = 0;
        uint256 index2 = 0;
        uint256 resultIndex = 0;

        while (index1 < length1 && index2 < length2) {
            if (arr1[index1] <= arr2[index2]) {
                result[resultIndex] = arr1[index1];
                index1++;
            } else {
                result[resultIndex] = arr2[index2];
                index2++;
            }
            resultIndex++;
        } 

        while (index1 < length1) {
            result[resultIndex] = arr1[index1];
            index1++;
            resultIndex++;
        }
        while (index2 < length2) {
            result[resultIndex] = arr2[index2];
            index2++;
            resultIndex++;
        }
        return result;
    }
}