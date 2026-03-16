// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract MultiSigWallet {
    //events
    event Deposited(address indexed sender, uint value, uint balance);
    event Submitted(address indexed owner, uint indexed txId, address indexed to, uint value);
    event Approved(address indexed owner, uint indexed txId);
    event Revoked(address indexed owner, uint indexed txId);
    event Executed(uint indexed txId);
    event Cancelled(uint indexed txId);

    // Transaction struct
    struct Transaction {
        address to;
        uint value;
        bytes data;
        bool executed;
        bool cancelled;
        uint256 approvalCount;
        uint256 createdAt;
    }

    //State vaiables
    address[] public owners;
    mapping(address => bool) public isOwner;
    uint public required;

    Transaction[] public transactions;
    mapping(uint => mapping(address => bool)) public approved;

    uint public constant TX_EXPIRY = 7 days;

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;
    uint256 private _status;

    //Modifiers
    modifier onlyOwner() { _onlyOwner(); _; }
    modifier txExists(uint _txId) { _txExists(_txId); _; }
    modifier notExecuted(uint _txId) { _notExecuted(_txId); _; }
    modifier notApproved(uint _txId) { _notApproved(_txId); _; }
    modifier notCancelled(uint _txId) { _notCancelled(_txId); _; }
    modifier notExpired(uint _txId) { _notExpired(_txId); _; }
    modifier nonReentrant() { _nonReentrantBefore(); _; _nonReentrantAfter(); }

    function _onlyOwner() internal view {
        require(isOwner[msg.sender], "not owner");
    }

    function _txExists(uint _txId) internal view {
        require(_txId < transactions.length, "tx does not exist");
    }

    function _notExecuted(uint _txId) internal view {
        require(!transactions[_txId].executed, "tx already executed");
    }

    function _notApproved(uint _txId) internal view {
        require(!approved[_txId][msg.sender], "tx already approved");
    }

    function _notCancelled(uint _txId) internal view {
        require(!transactions[_txId].cancelled, "tx cancelled");
    }

    function _notExpired(uint _txId) internal view {
        require(block.timestamp <= transactions[_txId].createdAt + TX_EXPIRY, "tx expired");
    }

    function _nonReentrantBefore() internal {
        require(_status != _ENTERED, "reentrant call");
        _status = _ENTERED;
    }

    function _nonReentrantAfter() internal {
        _status = _NOT_ENTERED;
    }

    // internal execution logic
    function _executeTransaction(uint _txId) internal nonReentrant {
        require(transactions[_txId].approvalCount >= required, "not enough approvals");

        Transaction storage _tx = transactions[_txId];

        _tx.executed = true;

        (bool success, ) = _tx.to.call{value: _tx.value}(_tx.data);
        require(success, "tx failed");

        emit Executed(_txId);
    }
    
    //Constuctor
    constructor(address[] memory _owners, uint _required) {
        _status = _NOT_ENTERED;

        require(_owners.length > 0, "owners required");
        require(_required > 0 && _required <= _owners.length, "invalid required numbers of owners");

        for(uint i = 0; i < _owners.length; i++) {
            address owner = _owners[i];

            require(owner != address(0), "invalid owner");
            require(!isOwner[owner], "owner not unique");

            isOwner[owner] = true;
            owners.push(owner);
        }

        required = _required;
    }

    //Functions
    receive() external payable {
        emit Deposited(msg.sender, msg.value, address(this).balance);
    }

    function getOwnerCount() external view returns (uint256) {
        return owners.length;
    }

    function submitTransaction(address _to, uint _value, bytes calldata _data) external onlyOwner returns(uint txId) {
        txId = transactions.length;

        transactions.push(Transaction({
            to: _to,
            value: _value,
            data: _data,
            executed: false,
            cancelled: false,
            approvalCount: 0,
            createdAt: block.timestamp
        }));

        emit Submitted(msg.sender, txId, _to, _value);
    }

    function approveTransaction(uint _txId) external onlyOwner txExists(_txId) notExecuted(_txId) notApproved(_txId) notCancelled(_txId) notExpired(_txId) {
        approved[_txId][msg.sender] = true;
        transactions[_txId].approvalCount++;

        emit Approved(msg.sender, _txId);
    }

    function revokeApproval(uint _txId) external onlyOwner txExists(_txId) notExecuted(_txId) notCancelled(_txId) {
        require(approved[_txId][msg.sender], "tx not approved");

        approved[_txId][msg.sender] = false;
        transactions[_txId].approvalCount--;

        emit Revoked(msg.sender, _txId);
    }

    function cancelTransaction(uint _txId) external onlyOwner txExists(_txId) notExecuted(_txId) notCancelled(_txId) {
        Transaction storage _tx = transactions[_txId];

        _tx.cancelled = true;

        emit Cancelled(_txId);
    }

    function executeTransaction(uint _txId) external onlyOwner txExists(_txId) notExecuted(_txId) notCancelled(_txId) notExpired(_txId) {
        _executeTransaction(_txId);
    }

    function getTransaction(uint _txId) external view txExists(_txId) returns(address to, uint value, bytes memory data, bool executed, bool cancelled, uint approvalCount, uint createdAt) {
        Transaction storage _tx = transactions[_txId];

        return (
            _tx.to,
            _tx.value,
            _tx.data,
            _tx.executed,
            _tx.cancelled,
            _tx.approvalCount,
            _tx.createdAt
        );
    }

    function getApprovals(uint _txId) external view txExists(_txId) returns (address[] memory) {
        address[] memory approvers = new address[](transactions[_txId].approvalCount);
        uint count = 0;

        for(uint i = 0; i < owners.length; i++){
            if(approved[_txId][owners[i]]){
                approvers[count] = owners[i];
                count++;
            }
        }

        return approvers;
    }
    
}