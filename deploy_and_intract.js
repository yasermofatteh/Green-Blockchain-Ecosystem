const Web3 = require('web3');
const fs = require('fs');
const solc = require('solc');

// Connect to local Ethereum node
const web3 = new Web3('http://localhost:8545');

// Compile and Deploy Function
async function compileAndDeploy(contractFile, contractName, constructorArgs) {
    const accounts = await web3.eth.getAccounts();

    // Load and compile the contract
    const contractSource = fs.readFileSync(contractFile, 'utf8');
    const compiledContract = solc.compile(contractSource, 1).contracts[contractName];

    const contractABI = JSON.parse(compiledContract.interface);
    const contractBytecode = compiledContract.bytecode;

    const contract = new web3.eth.Contract(contractABI);

    // Deploy contract
    const newContractInstance = await contract.deploy({
        data: contractBytecode,
        arguments: constructorArgs
    }).send({
        from: accounts[0], // Deployer account
        gas: 1500000,
        gasPrice: '30000000000'
    });

    console.log(`${contractName} deployed at: ${newContractInstance.options.address}`);
    return { contractABI, contractAddress: newContractInstance.options.address };
}

// Deploy and interact with all contracts
async function deployContracts() {
    const accounts = await web3.eth.getAccounts();

    // Deploy OrderingContract
    const orderingResult = await compileAndDeploy(
        'OrderingContract.sol',
        ':OrderingContract',
        [accounts[1], 1000, 100] // retailer address, product price, delivery fee
    );

    // Interact with OrderingContract
    const orderingContract = new web3.eth.Contract(orderingResult.contractABI, orderingResult.contractAddress);

    await orderingContract.methods.placeOrder().send({
        from: accounts[2], // Customer address
        value: web3.utils.toWei('1', 'ether'), // Product price + delivery fee
        gas: 1500000
    });
    const lockedDeliveryFee = await orderingContract.methods.getLockedDeliveryFee().call();
    console.log("Locked Delivery Fee: ", lockedDeliveryFee);

    // Deploy OptimizationContract
    const optimizationResult = await compileAndDeploy(
        'OptimizationContract.sol',
        ':OptimizationContract',
        [accounts[1], 500, 250] // retailer address, optimization fee, proposal fee
    );

    // Interact with OptimizationContract
    const optimizationContract = new web3.eth.Contract(optimizationResult.contractABI, optimizationResult.contractAddress);

    await optimizationContract.methods.submitOptimizationRequest().send({
        from: accounts[1], // Retailer address
        value: web3.utils.toWei('0.5', 'ether'),
        gas: 1500000
    });
    await optimizationContract.methods.submitProposal(accounts[2]).send({
        from: accounts[2], // Miner address
        value: web3.utils.toWei('0.25', 'ether'),
        gas: 1500000
    });
    await optimizationContract.methods.splitFees().send({
        from: accounts[0],
        gas: 1500000
    });

    // Deploy DeliveryContract
    const deliveryResult = await compileAndDeploy(
        'DeliveryContract.sol',
        ':DeliveryContract',
        [accounts[1], 100] // retailer address, delivery fee
    );

    // Interact with DeliveryContract
    const deliveryContract = new web3.eth.Contract(deliveryResult.contractABI, deliveryResult.contractAddress);

    await deliveryContract.methods.orderDelivery(accounts[3]).send({
        from: accounts[1], // Retailer address
        value: web3.utils.toWei('0.1', 'ether'),
        gas: 1500000
    });
    await deliveryContract.methods.splitDeliveryFee().send({
        from: accounts[0],
        gas: 1500000
    });

    // Deploy ConfirmationContract
    const confirmationResult = await compileAndDeploy(
        'ConfirmationContract.sol',
        ':ConfirmationContract',
        [accounts[2], accounts[1], accounts[3]] // customer, retailer, fleet carrier
    );

    // Interact with ConfirmationContract
    const confirmationContract = new web3.eth.Contract(confirmationResult.contractABI, confirmationResult.contractAddress);

    await confirmationContract.methods.confirmDelivery().send({
        from: accounts[2], // Customer address
        gas: 1500000
    });

    // Handle a claim
    await confirmationContract.methods.submitClaim("Product damaged").send({
        from: accounts[2], // Customer address
        gas: 1500000
    });

    console.log("All contracts deployed and interacted successfully.");
}

// Execute deployment and interactions
deployContracts().catch(console.error);
