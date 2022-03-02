//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./PartiesFactory.sol";

contract PartiesHelper is PartiesFactory{

    function getPartyForUser() external view returns (Party memory){
        require(userPartiesCount[_msgSender()] > 0, "You do not belong to a party");
        uint partyId = addressToPartyID[_msgSender()];

        return partyById[partyId];
    }

    function getParty(uint id) external view returns (Party memory){
        return partyById[id];
    }

    function changePartyStatus(bool status) external onlyLeader{
        uint partyId = addressToPartyID[_msgSender()];
        require(partyById[partyId].active != status, "Party already has this status");       
        partyById[partyId].active = status;
    }

    function removePartyDescription() external onlyLeader{
        uint partyId = addressToPartyID[_msgSender()];
        partyById[partyId].description = '';
    }
    
    function addMemberToParty(address memberAddress, string memory name, string memory title) external onlyLeader _maxParties{
        require(isMember[memberAddress] == false, "Member is already in a party");
        uint partyId = addressToPartyID[_msgSender()];
        PartyMember memory memberToAdd = PartyMember(0, name, title, memberAddress);
        partyById[partyId].members.push(memberToAdd);
        addressToPartyID[memberAddress] = partyId;
        isMember[memberAddress] = true;
        userPartiesCount[memberAddress]++;
    }

    function removeMemberFromParty() external{
        require(isMember[_msgSender()], "Member is not in a party");
        uint partyId = addressToPartyID[_msgSender()];
        for(uint i = 0; i < partyById[partyId].members.length; i++){
            if(partyById[partyId].members[i].memberAddress == _msgSender()){
                delete partyById[partyId].members[i];
                delete addressToPartyID[_msgSender()];
                isMember[_msgSender()] = false;
                userPartiesCount[_msgSender()]--;
                break;
            }
        }
    }

    function addSupporter(uint partyId) external _partyExists(partyId) _maxParties {
        require(isSupporter[_msgSender()] == false, "You are already a supporter");
        isSupporter[_msgSender()] = true;
        addressToPartyID[_msgSender()] = partyId;
        userPartiesCount[_msgSender()]++;
    }
    
    function removeSupporter() external onlyLeader {
        uint partyId = addressToPartyID[_msgSender()];
        require(partyId < parties.length, "Party does not exist");
        require(isSupporter[_msgSender()], "You are not a supporter of this party");
        for(uint i = 0; i < partyById[partyId].supporters.length; i++){
            if(partyById[partyId].supporters[i] == _msgSender()){
                delete partyById[partyId].supporters[i];
                delete addressToPartyID[_msgSender()];
                isSupporter[_msgSender()] = false;
                userPartiesCount[_msgSender()]--;
                break;
            }
        }
    }
}