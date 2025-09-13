// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Voting {
    // 存储候选人的得票数
    mapping(address => uint256) public votes;

    // 存储所有候选人的地址
    address[] public candidates;

    function vote(address _candidate) public  {
        if (votes[_candidate] == 0) {
            candidates.push(_candidate);
        }
        votes[_candidate] += 1;
    }

    function getVotes(address _candidate) public view returns (uint256) {
        return votes[_candidate];
    }

    function resetVotes() public  {
        for (uint256 i = 0; i < candidates.length; i++) {
            votes[candidates[i]] = 0;
        }
    }
}