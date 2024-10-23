// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DeliveryContract {
    address public retailer;
    address public fleetCarrier;
    uint256 public deliveryFee;
    bool public deliveryOrdered;

    // Events
    event DeliveryOrdered(address indexed retailer, uint256 deliveryFee);

    constructor(address _retailer, uint256 _deliveryFee) {
        retailer = _retailer;
        deliveryFee = _deliveryFee;
        deliveryOrdered = false;
    }

    // Retailer orders delivery by paying the fee
    function orderDelivery(address _fleetCarrier) public payable {
        require(msg.sender == retailer, "Only the retailer can order delivery.");
        require(msg.value == deliveryFee, "Incorrect delivery fee.");
        require(!deliveryOrdered, "Delivery already ordered.");

        fleetCarrier = _fleetCarrier;
        deliveryOrdered = true;

        emit DeliveryOrdered(retailer, deliveryFee);
    }

    // Part of the fee is paid to the fleet carrier and the remaining stays locked
    function splitDeliveryFee() public {
        require(deliveryOrdered, "Delivery not ordered yet.");

        uint256 carrierShare = deliveryFee / 2;
        uint256 remaining = deliveryFee - carrierShare;

        payable(fleetCarrier).transfer(carrierShare);

        // Remaining tokens locked in the contract for final confirmation
    }
}
