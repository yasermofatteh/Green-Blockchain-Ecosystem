// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract OptimizationContract {
    address public retailer;
    address public miner;
    uint256 public optimizationFee;
    uint256 public proposalFee;
    bool public requestSubmitted;
    bool public proposalSubmitted;

    // Events
    event OptimizationRequested(address indexed retailer, uint256 optimizationFee);
    event ProposalSubmitted(address indexed miner, uint256 proposalFee);

    constructor(address _retailer, uint256 _optimizationFee, uint256 _proposalFee) {
        retailer = _retailer;
        optimizationFee = _optimizationFee;
        proposalFee = _proposalFee;
        requestSubmitted = false;
        proposalSubmitted = false;
    }

    // Retailer submits an optimization request
    function submitOptimizationRequest() public payable {
        require(msg.sender == retailer, "Only the retailer can submit.");
        require(msg.value == optimizationFee, "Incorrect optimization fee.");
        require(!requestSubmitted, "Request already submitted.");

        requestSubmitted = true;
        emit OptimizationRequested(retailer, optimizationFee);
    }

    // Miner submits a proposal for last-mile delivery optimization
    function submitProposal(address _miner) public payable {
        require(requestSubmitted, "Request not submitted.");
        require(!proposalSubmitted, "Proposal already submitted.");
        require(msg.value == proposalFee, "Incorrect proposal fee.");

        miner = _miner;
        proposalSubmitted = true;

        emit ProposalSubmitted(miner, proposalFee);
    }

    // Tokens to be split between retailer and miner after optimization
    function splitFees() public {
        require(proposalSubmitted, "Proposal not yet submitted.");

        uint256 minerShare = optimizationFee / 2;
        uint256 retailerShare = optimizationFee / 4;
        uint256 remaining = optimizationFee - minerShare - retailerShare;

        payable(miner).transfer(minerShare);
        payable(retailer).transfer(retailerShare);

        // Remaining tokens will stay locked for future phases
    }
}
