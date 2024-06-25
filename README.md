## Foundry

## BLUMA TOKEN 
**Deployer: 0x3fb7B6793bF753E74bf776ff386256a7FD9F7bee**
**Deployed to: 0x100cA68535e9f7ed9E665378df4914Fa9f81298c**
**Transaction hash: 0xee09f09fbadad64a2639f8a2959960597a6ae10e7f1d26f6f173275779c1ade2**

## BLUMA NFT 
**Deployer: 0x3fb7B6793bF753E74bf776ff386256a7FD9F7bee**
**Deployed to: 0x52A341CD2BcCa262BF99CAA96db3347DE0d8a45D**
**Transaction hash: 0xe79793c99e1a4c8914f3dd45ab1a7e9c77abe6117b80b5a5cc8bada9ac5294f9**

## BLUMA PROTOCOL
**Deployer: 0x3fb7B6793bF753E74bf776ff386256a7FD9F7bee**
**Deployed to: 0xF6FB09A796530F7E0Ba8c7289f27b5b5ed799A4b**
**Transaction hash: 0x7e00769473acb0472d59bf2b00f516d99738de69faebdd96b2d3b95bb0a86893**

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
