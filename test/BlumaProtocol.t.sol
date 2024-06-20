// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {BlumaProtocol} from "../src/BlumaProtocol.sol";
// import {IBlumaProtocol} from "../test/IBlumaProtocol.sol";

contract BlumaProtocolTest is Test {

    BlumaProtocol blumaProtocol;
    address owner = address(0xa);
    address B = address(0xb);
    address C = address(0xc);


    function setUp() public {
            owner = mkaddr("owner");
        // switchSigner(owner);
        B = mkaddr("B address");
        C = mkaddr("C address");


        blumaProtocol = new BlumaProtocol();
        blumaProtocol.initialize(owner);
    }

      function testCreateAccount() public {
        switchSigner(owner);
        blumaProtocol.createAccount("ebukizy1@gmail.com", owner, "image.png");
       
        assertEq(  blumaProtocol.getUser(owner).email, "ebukizy1@gmail.com");
    }


    function testCreateEvent() public{
        testCreateAccount();
        switchSigner(owner);
        bytes32 _title = 0x692077616e7420746f2062652067726561740000000000000000000000000000;
        string memory _imageUrl = "starknet.png";
        string memory _description = "the next generation of starknet event";
        string memory _location = "no 7 ojo alaba";
        uint32 _capacity = 50;

        // Set the times based on the current block timestamp
        uint256 _currentTime = currentTime();
        uint256 _regStartTime = _currentTime + 1 days; // Registration starts in 1 day
        uint256 _regEndTime = _currentTime + 7 days;   // Registration ends in 7 days
        uint256 _eventStartTime = _currentTime + 8 days; // Event starts in 8 days
        uint256 _eventEndTime = _currentTime + 9 days;   // Event ends in 9 days
        uint96 _ticketPrice = 100; // Example ticket price
        bool _eventStatus = true;


        // Create the event
        blumaProtocol.createEvent(
            _title,
            _imageUrl,
            _description,
            _location,
            _capacity,
            _regStartTime,
            _regEndTime,
            _eventStartTime,
            _eventEndTime,
            _ticketPrice,
            _eventStatus
        );

        uint256 eventCount_ =  blumaProtocol.getAllEvents().length;
        assertEq(eventCount_, 1);
        assertEq(blumaProtocol.getEventById(1).ticketPrice, 100);

        //note check group is created
        uint256 groupCount_ = blumaProtocol.getAllEventGroups().length;
        assertEq(groupCount_ , 1);
    }

    function testJoinGroup() public {
    
    }


     function currentTime() internal view returns (uint256) {
        return (block.timestamp * 1000) + 1000;
    }

   function mkaddr(string memory name) public returns (address) {
        address addr = address(
            uint160(uint256(keccak256(abi.encodePacked(name))))
        );
        vm.label(addr, name);
        return addr;
    }

    function switchSigner(address _newSigner) public {
        address foundrySigner = 0x1804c8AB1F12E6bbf3894d4083f33e07309d1f38;
        if (msg.sender == foundrySigner) {
            vm.startPrank(_newSigner);
        } else {
            vm.stopPrank();
            vm.startPrank(_newSigner);
        }
    }


}

