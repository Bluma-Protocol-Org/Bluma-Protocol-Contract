## Foundry

## Deployer: 0x3fb7B6793bF753E74bf776ff386256a7FD9F7bee
## Deployed to: 0x95E984642BB5243d07d78fAAe482A954468e2762
## Transaction hash: 0xec5e5d4dda2cb335ff468c11fb33ac76c861c6be911dbd90b82213d6a8fe9722
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
