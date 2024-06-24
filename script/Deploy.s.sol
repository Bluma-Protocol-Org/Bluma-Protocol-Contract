// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

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

        address blumaToken = 0x0F3D0d9EFC475C71F734C1b0583568F06989F7D4;
        address blumaNft = 0x9fBBA19D265f852b8e2e292f89Bb3C8c33505213;

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
