import React from "react";
import Web3 from "web3";
import { Contract } from "@ethersproject/contracts";

export const useContract = (contractAddress, abi) => {

    const [contract, setContract] = React.useState(null);
    
    React.useEffect(() => {
        const web3 = new Web3(new Web3.providers.HttpProvider('http://localhost:8545'));
        const contractInstance = new web3.eth.Contract(abi, contractAddress);
        setContract(contractInstance);
    }, [contractAddress, abi]);
    
    return contract;
}