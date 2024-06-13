// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.9;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import {Validator} from "../src/Library/Validator.sol";
import "./Library/Error.sol";
import "./interface/IERC20.sol";

contract BlumaProtocol is Initializable, OwnableUpgradeable, UUPSUpgradeable {
    uint32 private _totalEventsId;
    uint32 private _ticketId;

    mapping(address => User) private user;
    mapping(uint32 => Event) private events;
    mapping(address => Ticket) private ticket;
    mapping(uint32=> EventGroup) private rooms;
    mapping(address => mapping(uint32 => bool)) private hasPurchasedEvent;

    Event[] private eventList;
    EventGroup[] private roomList;
    Ticket[] private tickets;

    IERC20 private MTRtoken;

    ///////////////
    /// EVENTS ///
    /////////////

    event EventCreated(uint32 indexed _totalEventsId,uint32 indexed _seatNumber,uint32 indexed _capacity);
    event GroupCreated(uint32 indexed _roomId, string imageUrl, bytes32 _title);
    event GroupJoinedSuccessfully(address indexed _sender, uint32 indexed _eventId);
    event RegistrationClose(uint256 indexed _currentTime, uint8 indexed _status);
    event TicketPurchased(address indexed buyer, uint32 indexed _eventId, uint32 numberOfTickets);
    event RefundIssued(address indexed buyer, uint32 indexed _ticketId, uint32 indexed _eventId, uint256 amount);
    event EventClosed(uint32 indexed _eventId, uint256 indexed _currentTime);


  

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
        uint256 eventStartTime;
        uint256 eventEndTime;
        uint96 ticketPrice;
        uint256 totalSales;
        uint256 createdAt;
        bool isCreatorPaid;
    }

    struct EventGroup {
        uint32 eventId;
        bytes32 title;
        string imageUrl;
        string description;
        address[] members;
    }

    struct Ticket {
        uint32 ticketId;
        uint32 eventId;
        address owner;
        uint256 ticketCost;
        uint256 purchaseTime;
        uint32 numberOfTicket;
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
    }

    /**
     * @dev Create a new event.
     * @param _title The title of the event.
     * @param _imageUrl The image URL of the event.
     * @param _description The description of the event.
     * @param _capacity The capacity of the event.
     * @param _regStartTime The registration start time.
     * @param _regEndTime The registration end time.
     * @param _eventStartTime The event start time.
     * @param _eventEndTime The event end time.
     * @param _ticketPrice The price of a ticket.
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
        uint96 _ticketPrice
    ) external {
        validateIsRegistered(msg.sender);

        Validator._validateBytes32(_title);
        Validator._validateString(_description);
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

        if (_ticketPrice == 0) {
            _event.ticketPrice = 0;
            _event.eventType =EventType.FREE;
        } else  {
              _event.eventType =EventType.PAID;
              _event.ticketPrice = _ticketPrice;
        }
        _event.eventId = _totalEventsId;
        _event.title = _title;
        _event.imageUrl = _imageUrl;
        _event.description = _description;
        _event.creator = msg.sender;
        _event.seats = _capacity;
        _event.location = _location;
        _event.capacity = _capacity;
        _event.regStartTime = _regStartTime;
        _event.regEndTime = _regEndTime;
        _event.eventStartTime = _eventStartTime;
        _event.eventEndTime = _eventEndTime;
        _event.eventStatus = EventStatus.PENDING;
        _event.createdAt = currentTime();
        eventList.push(_event);
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
        
        EventGroup memory _eventRoom;
        _eventRoom.eventId = _eventId;
        _eventRoom.title = _event.title;
        _eventRoom.imageUrl = _event.imageUrl;
        _eventRoom.description = _event.description;
        rooms[_eventId] = _eventRoom;
        roomList.push(_eventRoom);
        emit GroupCreated(_eventId, _event.imageUrl, _event.title);
    }

    /**
     * @dev Join an event group.
     * @param _eventId The ID of the event.
     */
    function joinGroup(uint32 _eventId) internal {
        _validateId(_eventId);
        if (!hasPurchasedEvent[msg.sender][_eventId]) revert INVALID_NOT_AUTHORIZED();
        EventGroup storage _eventRoom = rooms[_eventId];
        _eventRoom.members.push(msg.sender);
        emit GroupJoinedSuccessfully(msg.sender, _eventId);
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
        if (_event.seats + _numberOfTickets > _event.capacity) revert NOT_ENOUGH_AVAILABLE_SEAT();
        _ticketId =   _ticketId + 1;
        Ticket storage _ticket = ticket[msg.sender];

        uint256 _totalPrice = 0;
        if (_event.eventType == EventType.PAID) {
            _totalPrice = _numberOfTickets * _event.ticketPrice;
            if (MTRtoken.balanceOf(msg.sender) < _totalPrice) revert INSUFFICIENT_BALANCE();
            if (MTRtoken.allowance(msg.sender, address(this)) < _totalPrice) revert NO_ALLOWANCE();
            MTRtoken.transferFrom(msg.sender, address(this), _totalPrice);
            _event.totalSales = _event.totalSales + _totalPrice;
            _ticket.ticketCost = _ticket.ticketCost + _totalPrice;
        }

        _event.seats = _event.seats + _numberOfTickets;
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
        MTRtoken.transfer(msg.sender, _totalPrice);

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
        } else if (block.timestamp > _event.eventEndTime) {
            _event.eventStatus = EventStatus.CLOSE;
            emit EventClosed(_eventId, block.timestamp);
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
        MTRtoken.transfer(msg.sender, amount_);
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
     * @dev Get the details of all events.
     * @return events_ The details of all events.
     */
    function getAllEvents() external view returns (Event[] memory events_) {
        events_ = eventList;
    }

    /**
     * @dev Get the details of a specific event.
     * @param _eventId The ID of the event.
     * @return events_ The details of the event.
     */
    function getEvent(uint32 _eventId) external view returns (Event memory events_) {
        _validateId(_eventId);
        events_ = events[_eventId];
    }

    /**
     * @dev Get the members of a specific event group.
     * @param _eventId The ID of the event.
     * @return _members The members of the event group.
     */
    function getGroupMembers(uint32 _eventId) external view returns (address[] memory _members) {
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
        bal_ = MTRtoken.balanceOf(address(this));
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
    function initialize(address initialOwner) public initializer {
        __Ownable_init(initialOwner);
        __UUPSUpgradeable_init();
        MTRtoken = IERC20(0x4cb6cEf87d8cADf966B455E8BD58ffF32aBA49D1);
    }

    /**
     * @dev Authorize the upgrade of the contract.
     * @param newImplementation The address of the new implementation.
     */
    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}
}

