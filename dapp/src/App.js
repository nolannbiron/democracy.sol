import './App.css';
import {Web3ReactProvider} from '@web3-react/core';
import Web3 from 'web3';
import {BrowserRouter, Route, Routes} from 'react-router-dom';
import { Home } from './pages/Home';

function App() {

  function getLibrary() {
    return new Web3(new Web3.providers.HttpProvider('http://localhost:8545'));
  }
  
  return (
    <Web3ReactProvider getLibrary={getLibrary}>
      <BrowserRouter>
        <Routes>
          <Route index element={<Home />} />                 
        </Routes>       
      </BrowserRouter>
    </Web3ReactProvider>
  );
  
}

export default App;
