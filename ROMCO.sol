// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ROMCO is ERC20, Ownable {
    mapping(address => uint256) public lastClaimedTime;
    uint256 public rewardRate = 100; // 100 tokens rewarded per day per token held

    // Struct for proposals
    struct Proposal {
        string description;
        uint256 votesFor;
        uint256 votesAgainst;
        bool executed;
        mapping(address => bool) hasVoted;
    }
    Proposal[] public proposals;
    uint256 public proposalCount;

    constructor(uint256 initialSupply) ERC20("Royal Orchestra Meme Coin", "ROMCO") {
        _mint(msg.sender, initialSupply);
    }

    function claimRewards() public {
        uint256 timeHeld = block.timestamp - lastClaimedTime[msg.sender];
        require(timeHeld >= 1 days, "You can only claim rewards once per day");

        uint256 reward = balanceOf(msg.sender) * rewardRate * (timeHeld / 1 days);
        _mint(msg.sender, reward);

        lastClaimedTime[msg.sender] = block.timestamp;
    }

    function vote(uint256 proposalId, bool support) public {
        require(proposalId < proposalCount, "Proposal does not exist");
        require(!proposals[proposalId].hasVoted[msg.sender], "You have already voted");

        if (support) {
            proposals[proposalId].votesFor += balanceOf(msg.sender);
        } else {
            proposals[proposalId].votesAgainst += balanceOf(msg.sender);
        }

        proposals[proposalId].hasVoted[msg.sender] = true;
    }

    function createProposal(string memory description) public onlyOwner {
        proposals.push(Proposal({
            description: description,
            votesFor: 0,
            votesAgainst: 0,
            executed: false
        }));
        proposalCount++;
    }

    function executeProposal(uint256 proposalId) public onlyOwner {
        require(proposalId < proposalCount, "Proposal does not exist");
        require(!proposals[proposalId].executed, "Proposal already executed");
        require(proposals[proposalId].votesFor > proposals[proposalId].votesAgainst, "Proposal did not pass");

        // Execute proposal actions here

        proposals[proposalId].executed = true;
    }

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    function burn(uint256 amount) public {
        _burn(msg.sender, amount);
    }
}
