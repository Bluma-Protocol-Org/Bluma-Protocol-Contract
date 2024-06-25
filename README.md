## Foundry

## BLUMA TOKEN 
**Deployer: 0x3fb7B6793bF753E74bf776ff386256a7FD9F7bee**
**Deployed to: 0x5Ec2237a02BDf97E9556dC8c2C7Da6E92eC4e4fe**
**Transaction hash: 0xaf24b19a6bed91c98f6ba999e551fb61c062668732e1bf185300bd8e7b32022b**

## BLUMA NFT 
**Deployer: 0x3fb7B6793bF753E74bf776ff386256a7FD9F7bee**
**Deployed to: 0xCD0d3Ec95a7Ab3649Cd70149f9a94cb20580b9a1**
**Transaction hash: 0x16dd5b5fa3d42d60e5549766150c635d834d91a13b7619aa96443794476de9e1**

## BLUMA PROTOCOL
**Deployer: 0x3fb7B6793bF753E74bf776ff386256a7FD9F7bee**
**Deployed to: 0x6073e26377EAcf141Ad6854e5B8C2c48Af847079**
**Transaction hash: 0x5c98efa0baa8068a13d0edd3e49e1c8b59e58ae28628d7740466835b23c5b3e6**

## RPC: https://rpctest.meter.io
## https://docs.meter.io/developer-documentation/introduction#testnet
## ChainID: 83

Foundry consists of:

-   **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
-   **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
-   **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
-   **Chisel**: Fast, utilitarian, and verbose solidity REPL.

## Documentation

https://book.getfoundry.sh/

## Usage

### Build


```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy

```shell
$ forge script script/Counter.s.sol:CounterScript --rpc-url <your_rpc_url> --private-key <your_private_key>
```

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```
