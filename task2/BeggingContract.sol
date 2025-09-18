// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

contract BeggingContract is Ownable {
    
    mapping(address => uint256) public donations;

    uint256 public startTime;
    uint256 public endTime;

    event Donation(address indexed donor, uint256 amount);

    constructor() Ownable(msg.sender) {
        startTime = block.timestamp;
        endTime = startTime + 7 days;
    }

    function donate()  public payable {
        require(msg.value > 0, "Donation must be greater than 0");
        require(block.timestamp >=  startTime, "Donation not started yet");
        require(block.timestamp <= endTime, "Donation period has ended");

        donations[msg.sender] += msg.value;

        emit Donation(msg.sender, msg.value);
    }

    function withdraw() public onlyOwner {
        require(address(this).balance > 0, "No funds to withdraw");
        payable(owner()).transfer(address(this).balance);
    }

    function getDonation(address donor) public view returns (uint256) {
        return donations[donor];
    }
}