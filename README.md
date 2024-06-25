## Foundry

## BLUMA TOKEN 
**Deployer: 0x3fb7B6793bF753E74bf776ff386256a7FD9F7bee**
**Deployed to: 0x849176B3cE99C6eac972d58268b760207b29dCb6**
**Transaction hash: 0x197ffd30d1051a52f022f55c3390174f0034cdfae80fb45120814709b9dcb437**

## BLUMA NFT 
**Deployer: 0x3fb7B6793bF753E74bf776ff386256a7FD9F7bee**
**Deployed to: 0x08be7d6322c193b9cE89965515E504E6c8E7Dac0**
**Transaction hash: 0x3aac31cd601c3e168362ec2e4a0f898c12f7642943d4fc8e5e52a46d6f20ac60**

## BLUMA PROTOCOL
**Deployer: 0x3fb7B6793bF753E74bf776ff386256a7FD9F7bee**
**Deployed to: 0x34601104f57189db99D75bd3C4D72f1AD1f52D22**
**Transaction hash: 0x0f852446ec0c56115d28be9e1387cc3cf0ea07ab2ff01e384a747e815891ec06**

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
