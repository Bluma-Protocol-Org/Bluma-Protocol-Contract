// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.9;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import {Validator} from "../src/Library/Validator.sol";
import "./Library/Error.sol";
import "./interface/IERC20s.sol";
import "./interface/IERC721s.sol";


/// @title The Proxy Contract for the protocol
/// @notice This uses the EIP1822 UUPS standard from the OpenZeppelin library
/// @dev This contract manages events, tickets, users, event groups and chatting
contract BlumaProtocol is Initializable, OwnableUpgradeable, UUPSUpgradeable {

    ///////////////////////////
    ///                     ///
    /// STATE VARIABLES    ///
    ///                   ///
    ////////////////////////

    /// @notice Tracks the total number of events created
    uint32 private _totalEventsId;

    /// @notice Tracks the total number of tickets created
    uint32 private _ticketId;

    /// @notice Maps user addresses to User struct
    mapping(address => User) private user;

    /// @notice Maps event IDs to Event struct
    mapping(uint32 => Event) private events;

    /// @notice Maps user addresses to Ticket struct
    mapping(address => Ticket) private ticket;

    /// @notice Maps event group IDs to EventGroup struct
    mapping(uint32 => EventGroup) private rooms;

    /// @notice Tracks if a user has purchased a ticket for a specific event
    /// @dev First mapping is user address, second mapping is event ID, value is boolean
    mapping(address => mapping(uint32 => bool)) private hasPurchasedEvent;

    /// @notice Tracks if a user has joined a specific event group
    /// @dev First mapping is user address, second mapping is event group ID, value is boolean
    mapping(address user => mapping(uint32 => bool _groupId)) hasJoinedGroup;

    /// @notice List of all events
    Event[] private eventList;

    /// @notice List of all event groups
    EventGroup[] private roomList;

    /// @notice List of all tickets
    Ticket[] private tickets;

    /// @notice List of all users
    User[] private usersList;

    /// @notice ERC20 token used in the protocol
    IERC20s private blumaToken;

    /// @notice ERC721 token used in the protocol
    IERC721s private blumaNFT;



    ///////////////
    /// EVENTS ///
    /////////////

    event EventCreated(uint32 indexed _totalEventsId,uint32 indexed _seatNumber,uint32 indexed _capacity);
    event GroupCreated(uint32 indexed _roomId, string imageUrl, bytes32 _title);
    event GroupJoinedSuccessfully(address indexed _sender, uint32 indexed _eventId, uint256 indexed _joinedTimw);
    event RegistrationClose(uint256 indexed _currentTime, uint8 indexed _status);
    event TicketPurchased(address indexed buyer, uint32 indexed _eventId, uint32 numberOfTickets);
    event RefundIssued(address indexed buyer, uint32 indexed _ticketId, uint32 indexed _eventId, uint256 amount);
    event EventClosed(uint32 indexed _eventId, uint256 indexed _currentTime);
    event MessageSent(address indexed sender, uint32 indexed groupId, string text, uint256 timestamp);
    event AttendeesNFTMinted(address indexed owner, uint32 indexed eventId, uint32 numberOfTickets, uint256  indexed tokenId);




  

    /////////////////////
    ///     ENUMS    ///
    ////////////////////

    enum RegStatus {
        OPEN,
        CLOSE,
        PENDING
    }

    enum EventStatus {
        OPEN,
        CLOSE,
        PENDING
    }

    enum EventType {
        PAID,
        FREE
    }


    ////////////////////
    ///   Structs    ///
    ///////////////////
    struct User {
        string email;
        address userAddr;
        bool isRegistered;
        string avatar;
        uint256 balance;
    }

    struct Event {
        uint32 eventId;
        bytes32 title;
        string imageUrl;
        string location;
        string description;
        address creator;
        uint32 seats;
        uint32 capacity;
        uint256 regStartTime;
        uint256 regEndTime;
        RegStatus regStatus;
        EventStatus eventStatus;
        EventType eventType;
        string nftUrl;
        uint256 eventStartTime;
        uint256 eventEndTime;
        uint96 ticketPrice;
        uint256 totalSales;
        uint256 createdAt;
        bool isCreatorPaid;
        bool hasMinted;
    }

    struct EventGroup {
        uint32 eventId;
        bytes32 title;
        string imageUrl;
        string description;
        Member [] members;
        Message [] messages;
        
    }
    struct Member {
        address user;
        uint256 joinTime;
    }

    struct Ticket {
        uint32 ticketId;
        uint32 eventId;
        address owner;
        uint256 ticketCost;
        uint256 purchaseTime;
        uint32 numberOfTicket;
    }

    struct Message{
        address sender;
        string email;
        string text;
        uint256 timestamp;
    }

    //////////////////
    /// FUNCTIONS ///
    ////////////////

    /**
     * @dev Update the email of the user.
     * @param _email The new email of the user.
     * @param _avatar the image of the user 
     */
    function createAccount(string memory _email, address _addr, string memory _avatar) external {
        Validator._validateString(_email);
        Validator._validateString(_avatar);
        User storage _user = user[_addr];
        _user.email = _email;
        _user.isRegistered = true;
        _user.userAddr = _addr;
        _user.avatar = _avatar;
        usersList.push(_user);
    }

    /**
     * @dev Create a new event.
     * @param _title The title of the event.
     * @param _imageUrl The image URL of the event.
     * @param _description The description of the event.
     * @param _location thelocation of the event;
     * @param _capacity The capacity of the event.
     * @param _regStartTime The registration start time.
     * @param _regEndTime The registration end time.
     * @param _eventStartTime The event start time.
     * @param _eventEndTime The event end time.
     * @param _ticketPrice The price of a ticket.
     * @param _isEventPaid the event status if free_paid 
     * @param _nftUrl the nft cid for the event;
     */
    function createEvent(
        bytes32 _title,
        string calldata _imageUrl,
        string calldata _description,
        string calldata _location,
        uint32 _capacity,
        uint256 _regStartTime,
        uint256 _regEndTime,
        uint256 _eventStartTime,
        uint256 _eventEndTime,
        uint96 _ticketPrice,
        bool _isEventPaid,
        string calldata _nftUrl
    ) external {
        validateIsRegistered(msg.sender);

        Validator._validateBytes32(_title);
        Validator._validateString(_description);
        Validator._validateString(_nftUrl);
        Validator._validateString(_imageUrl);
        Validator._validateString(_location);
        Validator._validateNumbers(_regStartTime);
        Validator._validateNumbers(_regEndTime);
        Validator._validateNumbers(_eventStartTime);
        Validator._validateNumbers(_eventEndTime);
        Validator._validateNumbers(_ticketPrice);
        Validator._validateNumber(_capacity);
        Validator._validateTime(_eventStartTime, _eventEndTime);
        Validator._validateTime(_regStartTime, _regEndTime);
        _totalEventsId = _totalEventsId + 1;

        Event storage _event = events[_totalEventsId];

        if (currentTime() < _regStartTime) {
            _event.regStatus = RegStatus.PENDING;
        } else {
            _event.regStatus = RegStatus.OPEN;
        }

        if ( _isEventPaid == true) {
              _event.eventType =EventType.PAID;
              _event.ticketPrice = _ticketPrice;
        } else  {
              _event.ticketPrice = 0;
            _event.eventType =EventType.FREE;
            
        }

        _event.eventId = _totalEventsId;
        _event.title = _title;
        _event.imageUrl = _imageUrl;
        _event.description = _description;
        _event.creator = msg.sender;
        _event.location = _location;
        _event.capacity = _capacity;
        _event.regStartTime = _regStartTime;
        _event.regEndTime = _regEndTime;
        _event.eventStartTime = _eventStartTime;
        _event.eventEndTime = _eventEndTime;
        _event.eventStatus = EventStatus.PENDING;
        _event.createdAt = currentTime();
        _event.nftUrl = _nftUrl;

        //mint nfts to the event creator
        IERC721s(blumaNFT).safeMint(msg.sender, _nftUrl);
        
        _createGroup(_event.eventId);

        emit EventCreated(_totalEventsId, _event.seats, _capacity);
    }

    /**
     * @dev Create a group for the event.
     * @param _eventId The ID of the event.
     */
    function _createGroup(uint32 _eventId) internal {
        _validateId(_eventId);
        
    if (rooms[_eventId].eventId != 0) revert GROUP_ALREADY_EXISTS();
        Event storage _event = events[_eventId];
        

        EventGroup storage _eventRoom = rooms[_eventId];
        _eventRoom.eventId = _eventId;
        _eventRoom.title = _event.title;
        _eventRoom.imageUrl = _event.imageUrl;
        _eventRoom.description = _event.description;

          _eventRoom.members.push(Member({
            user: _event.creator,
            joinTime: currentTime()
        }));
           hasJoinedGroup[_event.creator][_eventId] = true;

        roomList.push(_eventRoom);
        emit GroupCreated(_eventId, _event.imageUrl, _event.title);
    }


    /**
     * @dev Join an event group.
     * @param _eventId The ID of the event.
     */
    function joinGroup(uint32 _eventId) external {
        _validateId(_eventId);
        EventGroup storage _eventRoom = rooms[_eventId];
        if(_eventRoom.eventId == 0) revert INVALID_ID();
        if(hasJoinedGroup[msg.sender][_eventId]) revert ALREADY_A_MEMBER();

          _eventRoom.members.push(Member({
            user: msg.sender,
            joinTime: currentTime()
        }));
        hasJoinedGroup[msg.sender][_eventId] = true;

        emit GroupJoinedSuccessfully(msg.sender, _eventId, currentTime());
    }


    /**
     * @dev Purchase tickets for an event.
     * @param _eventId The ID of the event.
     * @param _numberOfTickets The number of tickets to purchase.
     */
    function purchaseTicket(uint32 _eventId, uint32 _numberOfTickets) external {
        _validateId(_eventId);
        Event storage _event = events[_eventId];
        if (_event.regStatus != RegStatus.OPEN) revert REGISTRATION_NOT_OPEN();
            _event.seats = _event.seats + _numberOfTickets; 
        if ( _event.seats > _event.capacity) revert NOT_ENOUGH_AVAILABLE_SEAT();
        _ticketId =   _ticketId + 1;
        Ticket storage _ticket = ticket[msg.sender];

        uint256 _totalPrice = 0;
        if (_event.eventType == EventType.PAID) {
            _totalPrice = _numberOfTickets * _event.ticketPrice;
            if (blumaToken.balanceOf(msg.sender) < _totalPrice) revert INSUFFICIENT_BALANCE();
            if (blumaToken.allowance(msg.sender, address(this)) < _totalPrice) revert NO_ALLOWANCE();
            blumaToken.transferFrom(msg.sender, address(this), _totalPrice);
            _event.totalSales = _event.totalSales + _totalPrice;
            _ticket.ticketCost = _ticket.ticketCost + _totalPrice;
        }

        _ticket.ticketId = _ticketId;
        _ticket.owner = msg.sender;
        _ticket.purchaseTime = currentTime();
        _ticket.eventId = _eventId;
        _ticket.ticketCost = _ticket.ticketCost + _totalPrice;
        _ticket.numberOfTicket = _ticket.numberOfTicket + _numberOfTickets;
        tickets.push(_ticket);
        hasPurchasedEvent[msg.sender][_eventId] = true;
        emit TicketPurchased(msg.sender, _eventId, _numberOfTickets);
    }



    function groupChat(uint32 _groupId, string calldata _text) external {
        _validateId(_groupId);
        Validator._validateString(_text);

        // Ensure the sender is a member of the group
        EventGroup storage _group = rooms[_groupId];
        if(_group.eventId == 0) revert INVALID_ID();

        if(!hasJoinedGroup[msg.sender][_groupId]) revert INVALID_NOT_AUTHORIZED();

        // Add the message to the group's message list
        Message memory _message;
        _message.email = user[msg.sender].email;
        _message.sender = msg.sender;
        _message.text = _text;
        _message.timestamp = currentTime();
        _group.messages.push(_message);

        emit MessageSent(msg.sender, _groupId, _text, _message.timestamp);
    }

    /**
     * @dev Refund tickets for an event.
     * @param _eventId The ID of the event.
     * @param _numberOfTickets The number of tickets to refund.
     */
    function refundFee(uint32 _eventId,  uint32 _numberOfTickets) external {
        _validateId(_eventId);
        Event storage _event = events[_eventId];
        updateRegStatus(_eventId);

        Ticket storage _ticket = ticket[msg.sender];


        if(_event.eventType != EventType.PAID) revert NOT_PAID_EVENT();
        if(_event.regStatus != RegStatus.OPEN) revert REGISTRATION_CLOSE();
        if(_ticket.owner != msg.sender) revert NOT_OWNER();
        if(_ticket.eventId != _eventId) revert INVALID_EVENT_ID();
        if(_ticket.numberOfTicket < _numberOfTickets) revert INSUFFICIENT_TICKET_PURCHASED();

        uint256 _totalPrice = _numberOfTickets * _event.ticketPrice;
        _event.seats = _event.seats - _numberOfTickets;
        _event.totalSales =   _event.totalSales - _totalPrice;
        _ticket.numberOfTicket = _ticket.numberOfTicket -_numberOfTickets;
        if(_ticket.numberOfTicket == 0){
        hasPurchasedEvent[msg.sender][_eventId] = false;
        }
        blumaToken.transfer(msg.sender, _totalPrice);

        emit RefundIssued(msg.sender, _ticket.ticketId, _eventId, _totalPrice);
    }

      
    
/**
 * @dev Update registration status based on time.
 * @param _eventId The ID of the event.
 */
function updateRegStatus(uint32 _eventId) internal {
    _validateId(_eventId);
    Event storage _event = events[_eventId];

    if (currentTime() > _event.regEndTime) {
        if (_event.regStatus != RegStatus.CLOSE) {
            _event.regStatus = RegStatus.CLOSE;
            uint currentTime_ = currentTime();
            emit RegistrationClose(currentTime_, uint8(RegStatus.CLOSE));
        }
    }
}

    /**
     * @dev Update the status of the event based on the current time.
     * @param _eventId The ID of the event.
     */
    function updateEventStatus(uint32 _eventId) public {
        _validateId(_eventId);
        Event storage _event = events[_eventId];

        if (currentTime() >= _event.eventStartTime && currentTime() <= _event.eventEndTime) {
            _event.eventStatus = EventStatus.OPEN;
        } else if (currentTime() > _event.eventEndTime) {
            _event.eventStatus = EventStatus.CLOSE;
            emit EventClosed(_eventId, currentTime());
        }
    }

    /**
     * @dev Withdraw event fees by the event creator.
     * @param _eventId The ID of the event.
     */
    function withdrawEventFee(uint32 _eventId) external {
        _validateId(_eventId);
        Event storage _event = events[_eventId];
        User storage _user = user[msg.sender];
        
        updateEventStatus(_eventId); // Ensure the event status is updated based on the current time

        if (_event.eventStatus != EventStatus.CLOSE) revert EVENT_NOT_CLOSED();
        if (_event.creator != msg.sender) revert NOT_CREATOR();
        if (_event.isCreatorPaid) revert ALREADY_PAID();

        uint256 amount_ = _event.totalSales;
        _event.totalSales = 0;
        _event.isCreatorPaid = true;
        _user.balance =_user.balance + amount_;
        blumaToken.transfer(msg.sender, amount_);
    }


        /**
     * @notice Mints NFTs for all attendees of a specific event.
     * @param _eventId The ID of the event.
     * @dev This function can only be called after the registration period has ended and if the NFTs haven't been minted yet.
     * Emits a `AttendeesNFTMinted` event for each minted NFT.
     */
    function mintNFTsForAttendees(uint32 _eventId) external {
        Event storage _event = events[_eventId];
        if(_event.eventId == 0) revert INVALID_EVENT_ID();
        if(currentTime() < _event.regEndTime) revert REGISTRATION_NOT_CLOSED();
        if(_event.hasMinted) revert  NFT_ALREADY_MINTED();

        for (uint256 i = 0; i < tickets.length; i++) {
            if (tickets[i].eventId == _eventId && tickets[i].owner != address(0)) {
                uint256 tokenId = blumaNFT.getNextTokenId();
                blumaNFT.safeMint(tickets[i].owner, _event.nftUrl);
                emit AttendeesNFTMinted(tickets[i].owner, _eventId, tickets[i].numberOfTicket, tokenId);
            }
        }

        _event.hasMinted = true;
    }

   





    ///////////////////////
    /// VIEW FUNCTIONS ////
    //////////////////////

  /**
     * @dev Get the details of the user.
     * @return _user The details of the user.
     */
    function getUser(address _addr) external view returns (User memory _user) {
        _user = user[_addr];
    }

   /**
    *@notice get function dont consume gas so to make it east to fetch data
     * @dev Get the details of all events.
     * @return events_ The details of all events.
     */
    function getAllEvents() external view returns (Event[] memory) {
        Event[] memory events_ = new Event[](_totalEventsId);
        uint32 counter = 0;
        // Iterate over the possible event IDs
        for (uint32 i = 1; i <= _totalEventsId; i++) {
            if (events[i].eventId != 0) {    
                events_[counter] = events[i];
                counter++;
            }
        }
        // Create a new array with the exact size of existing events
        Event[] memory allEvents = new Event[](counter);
        // Copy the events to the new array
        for (uint32 j = 0; j < counter; j++) {
            allEvents[j] = events_[j];
        }
        
        return allEvents;
    }


    /**
     * @dev Get the details of a specific event.
     * @param _eventId The ID of the event.
     * @return events_ The details of the event.
     */
    function getEventById(uint32 _eventId) external view returns (Event memory events_) {
        _validateId(_eventId);
        events_ = events[_eventId];
    }


        /**
     * @notice Retrieves all NFT token IDs minted for a specific event.
     *@notice get function dont consume gas so to make it east to fetch data
     * @param _eventId The ID of the event.
     * @return An array of NFT token IDs.
     */
    function getEventNFTs(uint32 _eventId) external view returns (uint256[] memory) {
        uint256 count = 0;
        for (uint256 i = 0; i < tickets.length; i++) {
            if (tickets[i].eventId == _eventId) {
                count++;
            }
        }

        uint256[] memory result = new uint256[](count);
        uint256 index = 0;
        for (uint256 i = 0; i < tickets.length; i++) {
            if (tickets[i].eventId == _eventId) {
                uint256[] memory userTokens = blumaNFT.tokensOfOwner(tickets[i].owner);
                for (uint256 j = 0; j < userTokens.length; j++) {
                    result[index] = userTokens[j];
                    index++;
                }
            }
        }
        return result;
    }

    /**
     * @notice Retrieves all NFT token IDs owned by a specific user.
     * @param _user The address of the user.
     * @return An array of NFT token IDs owned by the user.
     */
    function getUserNFTs_(address _user) external view returns (uint256[] memory) {
        return blumaNFT.tokensOfOwner(_user);
    }


    /**
     * @dev Get the members of a specific event group.
     * @param _eventId The ID of the event.
     * @return _members The members of the event group.
     */
    function getGroupMembers(uint32 _eventId) external view returns (Member [] memory _members) {
        _validateId(_eventId);
        _members = rooms[_eventId].members;
    }

    function getAllEventGroups() external view returns(EventGroup [] memory group_){
        group_ = roomList;
    }

    function getEventGroup(uint32 _groupId) external view returns(EventGroup memory group_){
        group_ = rooms[_groupId];
    }


    /**
     * @dev Get the list of tickets purchased.
     * @return _tickets The list of tickets purchased.
     */
    function getAllTickets() external view returns (Ticket[] memory _tickets) {
        _tickets = tickets;
    }


    function getTicket(address _addr) external view returns(Ticket memory _ticket){
        _ticket = ticket[_addr];
    }

    function getAllGroupMessages(uint32 _groupId) external view returns (Message[] memory) {
        _validateId(_groupId);
        return rooms[_groupId].messages;
    }

    function getGroupMember(uint32 _groupId, uint _index) external view returns (Member memory) {
        _validateId(_groupId);
        EventGroup storage group = rooms[_groupId];

        if (_index >= group.members.length) revert INVALID_ID();
        
        return group.members[_index];
    }

    function getAllUser() external view returns (User [] memory) {
        return usersList;
    }

    function hasPurchasedTicket(address _user, uint32 _eventId) external view returns(bool){
        return hasPurchasedEvent[_user][_eventId];
    }

    /**
     * @dev Check if a user is registered.
     * @param _addr The address of the user.
     * @return True if the user is registered, false otherwise.
     */
    function isRegistered(address _addr) external view returns (bool) {
        return user[_addr].isRegistered;
    }

    /**
     * @dev Check the user balance.
     * @param _addr The address of the user.
     * @return bal_ if the user have any token
     */
    function checkUserBalance(address _addr) external view returns(uint256 bal_){
        bal_ = user[_addr].balance;
    } 

    function currentTime() internal view returns (uint256) {
        return (block.timestamp * 1000) + 1000;
    }

   /**
     * @dev Check the contract balance.
     * @return bal_ The contract balance.
     */
    function checkContractBalance() external view returns (uint256 bal_) {
        bal_ = blumaToken.balanceOf(address(this));
    }


    /**
     * @dev Validate the ID of an event.
     * @param _eventId The ID of the event.
     */
    function _validateId(uint32 _eventId) private view {
        if (_eventId > _totalEventsId) revert INVALID_ID();
    }
      function validateIsRegistered(address _user) private view{
          if(!user[_user].isRegistered) revert USER_NOT_REGISTERED();
    }

    /**
     * @dev Initialize the contract with the initial owner.
     * @param initialOwner The address of the initial owner.
     */
    function initialize(address initialOwner, address _blumaToken, address _blumaNFT) public initializer {
        __Ownable_init(initialOwner);
        __UUPSUpgradeable_init();
        blumaToken = IERC20s(_blumaToken);
        blumaNFT = IERC721s(_blumaNFT);
    }

    /**
     * @dev Authorize the upgrade of the contract.
     * @param newImplementation The address of the new implementation.
     */
    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}
}

