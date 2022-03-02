import React, { useEffect } from 'react';
import { useParties } from '../hooks/parties/useParties';

export const Home = () => {

    const {parties} = useParties();

    return (
        <div>
            <h1>Home</h1>

            {parties.length > 0 && parties.map((party, index) => {
                return (
                    <div key={index}>
                        <h2>{party.name}</h2>
                        <p>{party.symbol}</p>
                    </div>
                )
            })}
        </div>
    );
};