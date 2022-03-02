// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./Government.sol";

abstract contract PartiesFactory is Government{

    ////////////////////////////////////////////////////////////
    // EVENTS //////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////

    event PartyCreated(uint indexed id, string name, string symbol, address leader);

    event PartyRegisteredForElection(string name, string symbol, address leader);

    ////////////////////////////////////////////////////////////
    // Structs /////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////

    struct Party{
        uint id;
        uint creationTime;
        string name;
        string symbol;
        string description;
        address leader;
        PartyMember[] members;
        address[] supporters;
        bool active;
        bool registered;
    }

    struct PartyMember{
        uint id;
        string name;
        string title;
        address memberAddress;
    }

    ////////////////////////////////////////////////////////////
    // Variables ///////////////////////////////////////////////
    ////////////////////////////////////////////////////////////

    uint[] internal partyIDs;
    Party[] internal parties;
    uint public partiesCount;
    uint internal partiesRegisteredCount;

    ////////////////////////////////////////////////////////////
    // Mappings ////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////

    mapping(uint => Party) public partyById;
    mapping(address => uint) internal addressToPartyID;
    mapping(address => uint) internal userPartiesCount;
    mapping(address => bool) internal isSupporter;
    mapping(address => bool) internal isMember;
    mapping(uint => bool) internal partyExists;
    ////////////////////////////////////////////////////////////
    // Modifiers ///////////////////////////////////////////////
    ////////////////////////////////////////////////////////////

    modifier onlyLeader(){
        uint partyID = addressToPartyID[_msgSender()];
        require(parties[partyID].leader == _msgSender());
        _;
    }

    modifier _partyExists(uint partyId){
        require(partyExists[partyId], "Party does not exist");
        _;
    }

    modifier _maxParties(){
        require(userPartiesCount[_msgSender()] == 0, "User is already in a party");
        _;
    }

    ////////////////////////////////////////////////////////////
    // Party functions /////////////////////////////////////////
    ////////////////////////////////////////////////////////////

    function _createParty(string memory _name, string memory _symbol, address _leader) private {
        bytes32 id = keccak256(abi.encodePacked(_name, _symbol, _leader));
        parties.push(Party(uint(id), block.timestamp, _name, _symbol, '', _leader, new PartyMember[](0), new address[](0), true, false));

        partyById[uint(id)] = parties[uint(id)];
        partyById[uint(id)].id = uint(id);
        addressToPartyID[_leader] = uint(id);
        userPartiesCount[_leader]++;
        partyExists[uint(id)] = true;
        partiesCount++;

        emit PartyCreated(uint(id), _name, _symbol, _leader);
    }

    function createParty(string memory name, string memory symbol, string memory description) external payable _maxParties{        
        require(msg.value == 1 ether);
        require(bytes(name).length > 0 && bytes(symbol).length > 0);
        _createParty(name, symbol, _msgSender());
        if(bytes(description).length > 0){
            updatePartyDescription(description);
        }
    }

    function deleteParty() external onlyLeader{
        uint partyId = addressToPartyID[_msgSender()];
        for (uint i = 0; i < parties.length; i++){
            if(partyIDs[i] == partyId){
                parties.pop();
                partyIDs.pop();
                partiesCount--;
                for(uint j = 0; j < partyById[partyId].members.length; j++){
                    delete addressToPartyID[partyById[partyId].members[j].memberAddress];
                    userPartiesCount[partyById[partyId].members[j].memberAddress]--;
                    isMember[partyById[partyId].members[j].memberAddress] = false;
                }
                for(uint k = 0; k < partyById[partyId].supporters.length; k++){
                    isSupporter[partyById[partyId].supporters[k]] = false;
                    delete addressToPartyID[partyById[partyId].supporters[k]];
                    userPartiesCount[partyById[partyId].supporters[k]]--;
                }
                delete partyById[partyId];
                break;
            }
        }
    }

    function updatePartyDescription(string memory description) public onlyLeader{
        uint partyId = addressToPartyID[_msgSender()];
        require(bytes(description).length > 0, "Description is empty");
        partyById[partyId].description = description;
    }  

    function updatePartySymbol(string memory symbol) public onlyLeader{
        uint partyId = addressToPartyID[_msgSender()];
        require(bytes(symbol).length > 0, "Symbol is empty");
        partyById[partyId].symbol = symbol;
    }

    function updatePartyName(string memory name) public onlyLeader{
        uint partyId = addressToPartyID[_msgSender()];
        require(bytes(name).length > 0, "Name is empty");
        partyById[partyId].name = name;
    }
}