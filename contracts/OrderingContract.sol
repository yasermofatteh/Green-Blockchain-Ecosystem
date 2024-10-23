// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract OrderingContract {
    address public customer;
    address public retailer;
    uint256 public productPrice;
    uint256 public deliveryFee;
    bool public orderPlaced;

    // Events
    event OrderPlaced(address indexed customer, uint256 productPrice, uint256 deliveryFee);

    constructor(address _retailer, uint256 _productPrice, uint256 _deliveryFee) {
        retailer = _retailer;
        productPrice = _productPrice;
        deliveryFee = _deliveryFee;
        orderPlaced = false;
    }

    // Customer places the order and pays the total amount (product + delivery fee)
    function placeOrder() public payable {
        require(msg.value == productPrice + deliveryFee, "Incorrect payment amount.");
        require(!orderPlaced, "Order already placed.");

        customer = msg.sender;
        orderPlaced = true;
        
        // Transfer product price to the retailer
        payable(retailer).transfer(productPrice);

        emit OrderPlaced(customer, productPrice, deliveryFee);
    }

    // Function to lock the delivery fee in the contract until confirmation
    function getLockedDeliveryFee() public view returns (uint256) {
        return deliveryFee;
    }
}
