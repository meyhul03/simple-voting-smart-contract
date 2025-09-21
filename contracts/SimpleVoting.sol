// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * title - SimpleVoting
 * notice - Minimal voting contract: admin registers voters, starts voting for a duration,
 * registered voters can vote once for Proposal A or B, anyone can read result after deadline.
 */

contract SimpleVoting {
    address public admin;
    uint256 public votingDeadline;

    mapping(address => bool) public isVoter;
    mapping(address => bool) public hasVoted;

    uint256 public votesA;
    uint256 public votesB;

    string public proposalA = "Proposal A";
    string public proposalB = "Proposal B";
// Events
    event VoterRegistered(address voter);
    event VotingStarted(uint256 deadline);
    event Voted(address voter, string option);

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin");
        _;
    }

    modifier onlyWhileOpen() {
        require(block.timestamp < votingDeadline, "Voting ended");
        _;
    }

    constructor() {
        admin = msg.sender;
    }
// Register a list of voters
    function registerVoters(address[] calldata _voters) external onlyAdmin {
        for (uint i = 0; i < _voters.length; i++) {
            require(_voters[i] != address(0), "Invalid address");
            require(!isVoter[_voters[i]], "Already registered");
            isVoter[_voters[i]] = true;
            emit VoterRegistered(_voters[i]);
        }
    }
// Start voting with a duration in seconds
    function startVoting(uint256 durationSeconds) external onlyAdmin {
        require(votingDeadline == 0, "Already started");
        require(durationSeconds > 0, "Invalid duration");
        votingDeadline = block.timestamp + durationSeconds;
        emit VotingStarted(votingDeadline);
    }
// Cast vote (0 = Proposal A, 1 = Proposal B)
    function vote(uint8 option) external onlyWhileOpen {
        require(isVoter[msg.sender], "Not registered");
        require(!hasVoted[msg.sender], "Already voted");
        require(option == 0 || option == 1, "Invalid option");

        hasVoted[msg.sender] = true;
        if (option == 0) {
            votesA++;
            emit Voted(msg.sender, proposalA);
        } else {
            votesB++;
            emit Voted(msg.sender, proposalB);
        }
    }
//Get result after deadline
    function getResult() external view returns (string memory winner) {
        require(block.timestamp >= votingDeadline, "Voting not ended yet");
        if (votesA > votesB) return proposalA;
        if (votesB > votesA) return proposalB;
        return "TIE";
    }
}

