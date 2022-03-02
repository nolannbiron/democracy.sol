import React, {useEffect} from "react";
import { ABI, ADDRESS } from "../../constants/ABI";
import { useContract } from "../contract/useContract";
import {useWeb3React} from "@web3-react/core";

export const useParties = () => {

    const [parties, setParties] = React.useState([]);
    const Contract = useContract(ADDRESS, ABI);
    const {account} = useWeb3React();

    const getAllParties = async () => {
        const partiesCount = await Contract.methods.partiesCount().call();
        for (let i = 0; i < partiesCount; i++) {
            let party = await Contract.methods.idToParty(i).call().then((res) => res);
            setParties(prevParties => [...prevParties, party]);
        }
    }

    const createParty = async (name, symbol) => {
        await Contract.methods.createParty(name, symbol).send({from: account, value: 1*10**18});
        getAllParties();
    }

    const deleteParty = async () => {
        await Contract.methods.deleteParty(0).send({from: account});
        getAllParties();
    }

    const updateDescription = async (description) => {
        await Contract.methods.updatePartyDescription(description).send({from: account});
    }

    const updateSymbol = async (symbol) => {
        await Contract.methods.updatePartySymbol(symbol).send({from: account});
    }

    const updateName = async (name) => {
        await Contract.methods.updatePartyName(name).send({from: account});
    }

    const addSupporter = async(partyId) => {
        await Contract.methods.addSupporter(partyId).send({from: account});
    }

    const addMember = async(address) => {
        await Contract.methods.addMemberToParty(address).send({from: account});
    }

    const removeSupporter = async(partyId) => {
        await Contract.methods.removeSupporter(partyId).send({from: account});
    }    

    useEffect(() => {
        getAllParties();
        return () => {
            setParties([]);
        }
    }, []);

    return {parties, createParty, deleteParty, updateDescription, updateSymbol, updateName};
}