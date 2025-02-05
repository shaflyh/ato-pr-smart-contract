## 1. Installation

```shell
npm install
```

## 2. Edit your contract
Edit your smart contract according to your needs.

## 2. Create .env file
Create .env file in root folder. This file contain:

```shell
PUBLIC_KEY = "YOUR_PUBLIC_KEY" # Deployer wallet address
PRIVATE_KEY = "YOUR_PRIVATE_KEY"  # Deployer wallet private key
ALCHEMY_API_URL = "https://eth-rinkeby.alchemyapi.io/v2/....." # Get from alchemy
```

## 3. Edit hardhat.config.js and deploy.js
Add etherscan API in hardhat.config.js\
Change contract name in deploy.js

## 4. Compile and Deploy
```shell
#Compile to create ABI file in artifacts/contracts
npx hardhat compile

# Deploy to rinkeby testnet
npx hardhat run scripts/deploy.js --network rinkeby 

# Verify smart contract on etherscan
npx hardhat verify --network rinkeby CONTRACT_ADDRESS 

# If have arguments
npx hardhat verify --constructor-args scripts/arguments.js DEPLOYED_CONTRACT_ADDRESS

npx hardhat verify --network rinkeby 0x0b00D8489d3b6A2dEE93765E0fF2006e660D4CB9 "https://midnightbreeze.mypinata.cloud/ipfs/QmQgqB5hFVfVddk7BpA2vfW1MyaFhHrZpvjKyc3DKpM3iv/"

```

## Helpful links
[Hardhat](https://hardhat.org/getting-started/)\
[Opensea](https://docs.opensea.io/docs/getting-started-1)\
[Alchemy](https://docs.alchemy.com/alchemy/tutorials/how-to-create-an-nft)
