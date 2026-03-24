// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./RoleManager.sol";

contract SupplyChain {

    // Role registry managed by admin in RoleManager.
    RoleManager public roleManager;

    constructor(address _roleManagerAddress) {
        roleManager = RoleManager(_roleManagerAddress);
    }

    // Supply chain lifecycle for a batch.
    enum BatchState {
        CREATED,
        IN_DISTRIBUTION,
        IN_PHARMACY,
        SOLD
    }

    // Immutable audit entry for ownership transitions.
    struct OwnershipRecord {
        address owner;
        RoleManager.Role role;
        uint256 timestamp;
    }

    // On-chain essentials only; off-chain metadata referenced via hash.
    struct Batch {
        bytes32 batchId;
        address currentOwner;
        uint256 createdAt;
        bytes32 metadataHash;
        BatchState state;
        bool exists;
        OwnershipRecord[] history;
    }

    mapping(bytes32 => Batch) private batches;

    event BatchCreated(bytes32 indexed batchId, address indexed manufacturer, bytes32 metadataHash);
    event OwnershipTransferred(bytes32 indexed batchId, address indexed from, address indexed to);
    event BatchVerified(bytes32 indexed batchId, address indexed verifier, bool isValid);

    // Role-based access control.
    modifier onlyManufacturer() {
        require(roleManager.isManufacturer(msg.sender), "Not manufacturer");
        _;
    }

    // Ensures caller is current owner of the batch.
    modifier onlyCurrentOwner(bytes32 _batchId) {
        require(batches[_batchId].currentOwner == msg.sender, "Not current owner");
        _;
    }

    // Ensures a batch exists before access.
    modifier batchExists(bytes32 _batchId) {
        require(batches[_batchId].exists, "Batch does not exist");
        _;
    }

    // Manufacturer creates a batch with an off-chain metadata hash reference.
    function createBatch(bytes32 _batchId, bytes32 _metadataHash) public onlyManufacturer {
        require(_batchId != bytes32(0), "Invalid batchId");
        require(_metadataHash != bytes32(0), "Invalid metadata hash");
        require(!batches[_batchId].exists, "Batch already exists");

        Batch storage newBatch = batches[_batchId];
        newBatch.batchId = _batchId;
        newBatch.currentOwner = msg.sender;
        newBatch.createdAt = block.timestamp;
        newBatch.metadataHash = _metadataHash;
        newBatch.state = BatchState.CREATED;
        newBatch.exists = true;

        newBatch.history.push(
            OwnershipRecord({
                owner: msg.sender,
                role: roleManager.getRole(msg.sender),
                timestamp: block.timestamp
            })
        );

        emit BatchCreated(_batchId, msg.sender, _metadataHash);
    }

    // Transfer ownership along the allowed role sequence.
    function transferBatch(bytes32 _batchId, address _to)
        public
        batchExists(_batchId)
        onlyCurrentOwner(_batchId)
    {
        require(_to != address(0), "Invalid recipient");

        RoleManager.Role senderRole = roleManager.getRole(msg.sender);
        RoleManager.Role receiverRole = roleManager.getRole(_to);

        if (senderRole == RoleManager.Role.MANUFACTURER) {
            require(receiverRole == RoleManager.Role.DISTRIBUTOR, "Must transfer to distributor");
            batches[_batchId].state = BatchState.IN_DISTRIBUTION;
        } else if (senderRole == RoleManager.Role.DISTRIBUTOR) {
            require(receiverRole == RoleManager.Role.PHARMACY, "Must transfer to pharmacy");
            batches[_batchId].state = BatchState.IN_PHARMACY;
        } else if (senderRole == RoleManager.Role.PHARMACY) {
            batches[_batchId].state = BatchState.SOLD;
        } else {
            revert("Invalid role transfer");
        }

        address previousOwner = batches[_batchId].currentOwner;
        batches[_batchId].currentOwner = _to;

        batches[_batchId].history.push(
            OwnershipRecord({
                owner: _to,
                role: receiverRole,
                timestamp: block.timestamp
            })
        );

        emit OwnershipTransferred(_batchId, previousOwner, _to);
    }

    // Verifies authenticity by comparing the stored metadata hash.
    function verifyBatch(bytes32 _batchId, bytes32 _metadataHash)
        public
        batchExists(_batchId)
        returns (bool)
    {
        bool isValid = batches[_batchId].metadataHash == _metadataHash;
        emit BatchVerified(_batchId, msg.sender, isValid);
        return isValid;
    }

    // Read-only essentials for external systems.
    function getBatch(bytes32 _batchId)
        public
        view
        batchExists(_batchId)
        returns (
            bytes32 batchId,
            address currentOwner,
            uint256 createdAt,
            bytes32 metadataHash,
            BatchState state
        )
    {
        Batch storage b = batches[_batchId];
        return (b.batchId, b.currentOwner, b.createdAt, b.metadataHash, b.state);
    }

    // History helpers for traceability.
    function getOwnershipHistoryLength(bytes32 _batchId)
        public
        view
        batchExists(_batchId)
        returns (uint256)
    {
        return batches[_batchId].history.length;
    }

    function getOwnershipRecord(bytes32 _batchId, uint256 _index)
        public
        view
        batchExists(_batchId)
        returns (address owner, RoleManager.Role role, uint256 timestamp)
    {
        require(_index < batches[_batchId].history.length, "Index out of bounds");
        OwnershipRecord storage record = batches[_batchId].history[_index];
        return (record.owner, record.role, record.timestamp);
    }
}
