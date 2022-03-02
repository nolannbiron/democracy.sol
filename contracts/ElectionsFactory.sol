// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./PartiesFactory.sol";

contract ElectionsFactory is PartiesFactory{

    enum State {
        NotStarted,
        InProgress,
        Finished
    }

    event VoteRegistered(Party indexed party, uint time);

    uint internal constant COOLDOWN_TIME = 60 * 60 * 24 * 30; // 30 days
    uint internal constant VOTING_TIME = 10; //60 * 60 * 24 * 7; // 7 days
    uint internal readyTime = block.timestamp;
    uint internal ending;
    bool internal isActive = false;
    uint[] internal candidates;
    address[] internal voters;

    mapping(uint => uint) internal partyVoteCount;
    mapping(address => bool) internal userVoted;
    mapping(address => uint) internal userVote;
    mapping(uint => bool) internal candidatesExists;
    uint internal votersCount;

    constructor(){
        // startNewElection();
    }

    modifier _isReady(){
        require(block.timestamp >= readyTime, "Elections are not ready yet");
        _;
    }

    modifier _isElectionInactive(){
        require(isActive == false, "Elections are active");
        _;
    }

    modifier _ended(){
        require(block.timestamp >= ending, "Elections are not ended yet");
        _;
    }

    modifier _isCandidate(uint partyId){
        require(candidatesExists[partyId] == true, "Party is not registered");
        _;
    }

    function _triggerCooldown() internal {
        readyTime = block.timestamp + COOLDOWN_TIME;
    }

    function startNewElection() public _isReady _isElectionInactive onlyRegulator{
        ending = block.timestamp + VOTING_TIME;
        isActive = true;
        for(uint i = 0; i < partiesRegisteredCount; i++){
            if(partyById[i].registered){
                candidates.push(i);
                candidatesExists[i] = true;
            }
        }
    }

    function _closeElection() internal onlyRegulator{
        isActive = false;
        votersCount = 0;
        _resetPartyVoteCount();
        _resetUsersVotes();
        _triggerCooldown();
    }

    function _resetPartyVoteCount() private onlyRegulator {
        for (uint i=0; i < partiesRegisteredCount; i++){
            partyVoteCount[i] = 0;
        }
    }

    function _resetUsersVotes() private onlyRegulator {
        for (uint i=0; i < voters.length; i++){
            userVoted[voters[i]] = false;
        }
    }

    function registerPartyToElection() external onlyLeader _isReady payable{
        uint partyId = addressToPartyID[_msgSender()];
        require(partyById[partyId].registered == false, "Party is already active");
        partyById[partyId].registered = true;
        partiesRegisteredCount++;

        emit PartyRegisteredForElection(partyById[partyId].name, partyById[partyId].symbol, partyById[partyId].leader);
    }

    function retirePartyFromElection() external onlyLeader _ended{
        uint partyId = addressToPartyID[_msgSender()];
        require(partyById[partyId].registered == true, "Party is not active");
        partyById[partyId].registered = false;
        partiesRegisteredCount--;
    }
}