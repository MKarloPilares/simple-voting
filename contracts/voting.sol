// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

// Uncomment this line to use console.log
// import "hardhat/console.sol";

contract voting {
    struct Candidate {
        string name;
        uint voteCount;
    }

    event Start(address indexed starter, string announce);
    event Vote(address indexed voter, string announce);
    event Win(address indexed ender, string announce);

    address public owner;
    uint public votingEndTime;
    mapping(address => bool) public hasVoted;
    Candidate[] public candidates;
    bool public votingActive;

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can start the voting");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function startVote(string[] calldata candidateNames, uint durationSeconds) external onlyOwner {
        require(!votingActive, "Voting has already begun!");
        delete candidates;
        for (uint i = 0; i < candidateNames.length; i++){
            candidates.push(Candidate(candidateNames[i], 0));
        }

        votingEndTime = block.timestamp + durationSeconds;
        votingActive = true;

        emit Start(msg.sender, "Voting started!");
    }

    function vote(uint candidateIndex) external {
        require(block.timestamp < votingEndTime, "Voting is over!");

        if (block.timestamp >= votingEndTime) {
            votingActive = false;
        revert("Voting has ended");
        }

        require(!hasVoted[msg.sender], "You have already voted!");

        candidates[candidateIndex].voteCount++;
        hasVoted[msg.sender] = true;

        emit Vote(msg.sender, "Voting Complete!");
    }

    function getWinner() external view returns (string memory) {
        require(block.timestamp > votingEndTime, "Voting is still ongoing!");

        uint maxVotes = 0;
        uint winningIndex = 0;

        for(uint i = 0; i < candidates.length; i++){
            if(candidates[i].voteCount > maxVotes) {
                maxVotes = candidates[i].voteCount;
                winningIndex = i;
            }
        }

        return candidates[winningIndex].name;
    }

    function getCandidateCount() external view returns (uint candidateCount) {
        return candidates.length;
    }

    function getCandidate(uint candidateIndex) external view returns (Candidate memory candidate) {
        return candidates[candidateIndex];
    }
}
