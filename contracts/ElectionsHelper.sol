// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./ElectionsFactory.sol";

contract ElectionsHelper is ElectionsFactory{

    struct Winner {
        string partyName;
        address leader;
        uint votes;
        uint electionDate;
    }

    Winner[] internal winners;

    modifier onlyVoter(){
        require(userVoted[_msgSender()] == false, "You already voted");
        _;
    }

    modifier _isVoteActive(){
        require(block.timestamp < ending, "Voting is not active");
        _;
    }

    function vote(uint partyId) external _isVoteActive  onlyVoter _partyExists(partyId) _isCandidate(partyId){
        partyVoteCount[partyId]++;
        votersCount++;
        voters.push(_msgSender());
        userVoted[_msgSender()] = true;

        emit VoteRegistered(partyById[partyId], block.timestamp);
    }

    function getVoteResults() external onlyRegulator _ended {
        uint winnerId = 0;
        uint maxVotes = 0;
        for(uint i = 0; i < parties.length; i++){
            if(partyVoteCount[i] > maxVotes){
                maxVotes = partyVoteCount[i];
                winnerId = i;
            }
        }
        winners.push(Winner(partyById[winnerId].name, partyById[winnerId].leader, partyVoteCount[winnerId], block.timestamp));
        _setPresident(partyById[winnerId].leader);
        _closeElection();
    }

    function lastWinner() external view returns (Winner memory){
        return winners[winners.length - 1];
    }

}