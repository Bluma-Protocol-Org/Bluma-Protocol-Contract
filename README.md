## Foundry

## BLUMA TOKEN : 0x0F3D0d9EFC475C71F734C1b0583568F06989F7D4
## BLUMA NFT : 0x9fBBA19D265f852b8e2e292f89Bb3C8c33505213

## Deployer: 0x3fb7B6793bF753E74bf776ff386256a7FD9F7bee
## Deployed to: 0x398e13451b28d8b87Dccd7c70D2a7B391A758023
## Transaction hash: 0xb58647ac24318e3c1e364cc2fd1d172e5246839feae970a796c02d67ba0720ef
Deployer: 0x3fb7B6793bF753E74bf776ff386256a7FD9F7bee
Deployed to: 
Transaction hash: 
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
