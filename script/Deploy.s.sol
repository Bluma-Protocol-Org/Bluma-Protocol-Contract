// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import {Script, console} from "forge-std/Script.sol";
import {BlumaProtocol} from "../src/BlumaProtocol.sol";
import {BlumaToken} from "../src/BlumaToken.sol";
import {BlumaNFT} from "../src/BlumaNfts.sol";
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

contract DeployScript is Script {
    BlumaProtocol blumaProtocol;
    ERC1967Proxy proxy;
    // BlumaToken blumaToken;
    // BlumaNFT blumaNft;

    function setUp() public {}

    function run() public {

        address blumaToken = 0xB3e20Ab089705dCBD9D6b9c28aE6b84b68b2Ee17;
        address blumaNft = 0xF9eFb8bf1296D0C04F1Ec638F7D0062529E3e2bC;

        vm.startBroadcast();

        // blumaToken = new BlumaToken();
        // blumaNft = new BlumaNFT();

        // Deploy the implementation contract
        BlumaProtocol implementation = new BlumaProtocol();

        // Deploy the proxy and initialize the contract through the proxy
        proxy = new ERC1967Proxy(
            address(implementation),
            abi.encodeWithSelector(implementation.initialize.selector, msg.sender,blumaToken, blumaNft)
        );

        // Log the addresses of the proxy and the implementation contract
        console.log("Proxy ADDRESS:", address(proxy));
        console.log("BLUMA PROTOCOL Implementation Address:", address(implementation));
        // console.log("BLUMA TOKEN Implementation Address:", address(blumaToken));
        // console.log("BLUMA NFT Implementation Address:", address(blumaNft));

        


        vm.stopBroadcast();
    }
}
// forge create --rpc-url https://rpctest.meter.io  --private-key ef257f59dc15ea8d0cfa7f5a177fb173b3125a3d79e6c13eb1e88831e40dc62c src/BlumaToken.sol:BlumaToken