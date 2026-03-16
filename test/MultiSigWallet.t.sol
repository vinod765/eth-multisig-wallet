// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {MultiSigWallet} from "../src/MultiSigWallet.sol";

contract MultiSigWalletTest is Test {
    MultiSigWallet public wallet;

    address public owner1 = makeAddr("owner1");
    address public owner2 = makeAddr("owner2");
    address public owner3 = makeAddr("owner3");
    address public nonOwner = makeAddr("nonOwner");
    address public recipient = makeAddr("recipient");

    address[] public owners;
    uint public constant REQUIRED = 2;

    event Submitted(address indexed owner, uint indexed txId, address indexed to, uint value);
    event Approved(address indexed owner, uint indexed txId);
    event Revoked(address indexed owner, uint indexed txId);
    event Executed(uint indexed txId);
    event Cancelled(uint indexed txId);
    event Deposited(address indexed sender, uint value, uint balance);

    function setUp() public {
        owners.push(owner1);
        owners.push(owner2);
        owners.push(owner3);
        wallet = new MultiSigWallet(owners, REQUIRED);
    }

    // Constructor tests
    //1
    function test_ConstructorSetsOwners() public view {
        assertEq(wallet.getOwnerCount(), 3);
        assertTrue(wallet.isOwner(owner1));
        assertTrue(wallet.isOwner(owner2));
        assertTrue(wallet.isOwner(owner3));
    }

    //2
    function test_ConstructorSetsRequired() public view {
        assertEq(wallet.required(), REQUIRED);
    }

    //3
    function test_ConstructorRevertsIfNoOwners() public {
        address[] memory empty = new address[](0);
        vm.expectRevert("owners required");
        new MultiSigWallet(empty, 1);
    }

    //4
    function test_ConstructorRevertsIfRequiredIsZero() public {
        vm.expectRevert("invalid required numbers of owners");
        new MultiSigWallet(owners, 0);
    }

    //5
    function test_ConstructorRevertsIfRequiredExceedsOwners() public {
        vm.expectRevert("invalid required numbers of owners");
        new MultiSigWallet(owners, 4);
    }

    //6
    function test_ConstructorRevertsOnZeroAddress() public {
        owners[0] = address(0);
        vm.expectRevert("invalid owner");
        new MultiSigWallet(owners, REQUIRED);
    }

    //7
    function test_ConstructorRevertsOnDuplicateOwner() public {
        owners[1] = owner1;
        vm.expectRevert("owner not unique");
        new MultiSigWallet(owners, REQUIRED);
    }

    // submitTransaction tests
    //8
    function test_OwnerCanSubmitTransaction() public {
        vm.prank(owner1);
        uint txId = wallet.submitTransaction(recipient, 1 ether, "");
        assertEq(txId, 0);

        (address to, uint value,, bool executed, bool cancelled, uint approvalCount,) = wallet.getTransaction(0);
        assertEq(to, recipient);
        assertEq(value, 1 ether);
        assertEq(executed, false);
        assertEq(cancelled, false);
        assertEq(approvalCount, 0);
    }

    //9
    function test_NonOwnerCannotSubmit() public {
        vm.prank(nonOwner);
        vm.expectRevert("not owner");
        wallet.submitTransaction(recipient, 1 ether, "");
    }

    //10
    function test_SubmitEmitsEvent() public {
        vm.prank(owner1);
        vm.expectEmit(true, true, true, true, address(wallet));
        emit Submitted(owner1, 0, recipient, 1 ether);
        wallet.submitTransaction(recipient, 1 ether, "");
    }

    // approveTransaction tests
    //11
    function test_OwnerCanApprove() public {
        vm.prank(owner1);
        wallet.submitTransaction(recipient, 1 ether, "");

        vm.prank(owner1);
        wallet.approveTransaction(0);

        (,,,,,uint approvalCount,) = wallet.getTransaction(0);
        assertEq(approvalCount, 1);
    }

    //12
    function test_NonOwnerCannotApprove() public {
        vm.prank(owner1);
        wallet.submitTransaction(recipient, 1 ether, "");

        vm.prank(nonOwner);
        vm.expectRevert("not owner");
        wallet.approveTransaction(0);
    }

    //13
    function test_OwnerCannotApproveTwice() public {
        vm.prank(owner1);
        wallet.submitTransaction(recipient, 1 ether, "");

        vm.prank(owner1);
        wallet.approveTransaction(0);

        vm.prank(owner1);
        vm.expectRevert("tx already approved");
        wallet.approveTransaction(0);
    }

    //14
    function test_CannotApproveNonExistentTx() public {
        vm.prank(owner1);
        vm.expectRevert("tx does not exist");
        wallet.approveTransaction(99);
    }

    //15
    function test_CannotApproveExecutedTx() public {
        vm.deal(address(wallet), 2 ether);

        vm.prank(owner1);
        wallet.submitTransaction(recipient, 1 ether, "");

        vm.prank(owner1);
        wallet.approveTransaction(0);

        vm.prank(owner2);
        wallet.approveTransaction(0);

        vm.prank(owner2);
        wallet.executeTransaction(0);

        vm.prank(owner1);
        vm.expectRevert("tx already executed");
        wallet.approveTransaction(0);
    }

    //16
    function test_ApprovedEmitsEvent() public {
        vm.prank(owner1);
        wallet.submitTransaction(recipient, 1 ether, "");

        vm.prank(owner1);
        vm.expectEmit(true, true, false, false);
        emit Approved(owner1, 0);
        wallet.approveTransaction(0);
    }

    // revokeApproval tests
    //17
    function test_OwnerCanRevokeApproval() public {
        vm.prank(owner1);
        wallet.submitTransaction(recipient, 1 ether, "");

        vm.prank(owner1);
        wallet.approveTransaction(0);

        vm.prank(owner1);
        wallet.revokeApproval(0);

        (,,,,,uint approvalCount,) = wallet.getTransaction(0);
        assertEq(approvalCount, 0);
    }

    //18
    function test_CannotRevokeIfNotApproved() public {
        vm.prank(owner1);
        wallet.submitTransaction(recipient, 1 ether, "");

        vm.prank(owner1);
        vm.expectRevert("tx not approved");
        wallet.revokeApproval(0);
    }

    //19
    function test_CannotRevokeExecutedTx() public {
        vm.deal(address(wallet), 2 ether);

        vm.prank(owner1);
        wallet.submitTransaction(recipient, 1 ether, "");

        vm.prank(owner1);
        wallet.approveTransaction(0);

        vm.prank(owner2);
        wallet.approveTransaction(0);

        vm.prank(owner1);
        wallet.executeTransaction(0);

        vm.prank(owner1);
        vm.expectRevert("tx already executed");
        wallet.revokeApproval(0);
    }

    //20
    function test_RevokeEmitsEvent() public {
        vm.prank(owner1);
        wallet.submitTransaction(recipient, 1 ether, "");

        vm.prank(owner1);
        wallet.approveTransaction(0);

        vm.prank(owner1);
        vm.expectEmit(true, true, false, false, address(wallet));
        emit Revoked(owner1, 0);
        wallet.revokeApproval(0);
    }

    // executeTransaction tests
    //21
    function test_ExecuteHappyPath() public {
        vm.deal(address(wallet), 2 ether);

        vm.prank(owner1);
        wallet.submitTransaction(recipient, 1 ether, "");

        vm.prank(owner1);
        wallet.approveTransaction(0);

        vm.prank(owner2);
        wallet.approveTransaction(0);

        vm.prank(owner1);
        wallet.executeTransaction(0);

        (,,, bool executed,,, ) = wallet.getTransaction(0);
        assertTrue(executed);
        assertEq(recipient.balance, 1 ether);
    }

    //22
    function test_CannotExecuteWithInsufficientApprovals() public {
        vm.deal(address(wallet), 2 ether);

        vm.prank(owner1);
        wallet.submitTransaction(recipient, 1 ether, "");

        vm.prank(owner1);
        wallet.approveTransaction(0);

        vm.prank(owner1);
        vm.expectRevert("not enough approvals");
        wallet.executeTransaction(0);
    }

    //23
    function test_CannotExecuteTwice() public {
        vm.deal(address(wallet), 2 ether);

        vm.prank(owner1);
        wallet.submitTransaction(recipient, 1 ether, "");

        vm.prank(owner1);
        wallet.approveTransaction(0);

        vm.prank(owner2);
        wallet.approveTransaction(0);

        vm.prank(owner1);
        wallet.executeTransaction(0);

        vm.prank(owner1);
        vm.expectRevert("tx already executed");
        wallet.executeTransaction(0);
    }

    //24
    function test_NonOwnerCannotExecute() public {
        vm.deal(address(wallet), 2 ether);

        vm.prank(owner1);
        wallet.submitTransaction(recipient, 1 ether, "");

        vm.prank(owner1);
        wallet.approveTransaction(0);

        vm.prank(owner2);
        wallet.approveTransaction(0);

        vm.prank(nonOwner);
        vm.expectRevert("not owner");
        wallet.executeTransaction(0);
    }

    //25
    function test_RevokePreventesExecution() public {
        vm.deal(address(wallet), 2 ether);

        vm.prank(owner1);
        wallet.submitTransaction(recipient, 1 ether, "");

        vm.prank(owner1);
        wallet.approveTransaction(0);

        vm.prank(owner2);
        wallet.approveTransaction(0);

        vm.prank(owner2);
        wallet.revokeApproval(0);

        vm.prank(owner1);
        vm.expectRevert("not enough approvals");
        wallet.executeTransaction(0);
    }

    //26
    function test_ExecuteEmitsEvent() public {
        vm.deal(address(wallet), 5 ether);

        vm.prank(owner1);
        wallet.submitTransaction(recipient, 1 ether, "");

        vm.prank(owner1);
        wallet.approveTransaction(0);

        vm.prank(owner2);
        wallet.approveTransaction(0);

        vm.prank(owner1);
        vm.expectEmit(true, false, false, false);
        emit Executed(0);
        wallet.executeTransaction(0);
    }

    // ETH receipt tests
    //27
    function test_WalletReceivesETH() public {
        vm.deal(owner1, 5 ether);

        vm.prank(owner1);
        (bool success,) = address(wallet).call{value: 2 ether}("");
        assertTrue(success);
        assertEq(address(wallet).balance, 2 ether);
    }

    //28
    function test_DepositEmitsEvent() public {
        vm.deal(owner1, 5 ether);

        vm.expectEmit(true, false, false, true, address(wallet));
        emit Deposited(owner1, 2 ether, 2 ether);

        vm.prank(owner1);
        (bool success,) = address(wallet).call{value: 2 ether}("");
        assertTrue(success);
    }

    //29
    function test_ExecuteSendsETHToRecipient() public {
        vm.deal(address(wallet), 5 ether);

        uint recipientBalanceBefore = recipient.balance;
        uint walletBalanceBefore = address(wallet).balance;

        vm.prank(owner1);
        wallet.submitTransaction(recipient, 1 ether, "");

        vm.prank(owner1);
        wallet.approveTransaction(0);

        vm.prank(owner2);
        wallet.approveTransaction(0);

        vm.prank(owner1);
        wallet.executeTransaction(0);

        assertEq(recipient.balance, recipientBalanceBefore + 1 ether);
        assertEq(address(wallet).balance, walletBalanceBefore - 1 ether);
    }

    //30
    function test_GetApprovalsReturnsCorrectOwners() public {
        vm.prank(owner1);
        wallet.submitTransaction(recipient, 1 ether, "");

        vm.prank(owner1);
        wallet.approveTransaction(0);

        vm.prank(owner2);
        wallet.approveTransaction(0);

        address[] memory approvers = wallet.getApprovals(0);
        assertEq(approvers.length, 2);
        assertEq(approvers[0], owner1);
        assertEq(approvers[1], owner2);
    }

    // cancelTransaction tests
    //31
    function test_OwnerCanCancelTransaction() public {
        vm.prank(owner1);
        wallet.submitTransaction(recipient, 1 ether, "");

        vm.prank(owner1);
        wallet.cancelTransaction(0);

        (,,, bool executed, bool cancelled,,) = wallet.getTransaction(0);
        assertEq(executed, false);
        assertEq(cancelled, true);
    }

    //32
    function test_NonOwnerCannotCancel() public {
        vm.prank(owner1);
        wallet.submitTransaction(recipient, 1 ether, "");

        vm.prank(nonOwner);
        vm.expectRevert("not owner");
        wallet.cancelTransaction(0);
    }

    //33
    function test_CannotCancelExecutedTx() public {
        vm.deal(address(wallet), 2 ether);

        vm.prank(owner1);
        wallet.submitTransaction(recipient, 1 ether, "");

        vm.prank(owner1);
        wallet.approveTransaction(0);

        vm.prank(owner2);
        wallet.approveTransaction(0);

        vm.prank(owner1);
        wallet.executeTransaction(0);

        vm.prank(owner1);
        vm.expectRevert("tx already executed");
        wallet.cancelTransaction(0);
    }

    //34
    function test_CannotCancelAlreadyCancelledTx() public {
        vm.prank(owner1);
        wallet.submitTransaction(recipient, 1 ether, "");

        vm.prank(owner1);
        wallet.cancelTransaction(0);

        vm.prank(owner1);
        vm.expectRevert("tx cancelled");
        wallet.cancelTransaction(0);
    }

    //35
    function test_CannotApproveAfterCancel() public {
        vm.prank(owner1);
        wallet.submitTransaction(recipient, 1 ether, "");

        vm.prank(owner1);
        wallet.cancelTransaction(0);

        vm.prank(owner2);
        vm.expectRevert("tx cancelled");
        wallet.approveTransaction(0);
    }

    //36
    function test_CannotExecuteAfterCancel() public {
        vm.deal(address(wallet), 2 ether);

        vm.prank(owner1);
        wallet.submitTransaction(recipient, 1 ether, "");

        vm.prank(owner1);
        wallet.approveTransaction(0);

        vm.prank(owner2);
        wallet.approveTransaction(0);

        vm.prank(owner1);
        wallet.cancelTransaction(0);

        vm.prank(owner1);
        vm.expectRevert("tx cancelled");
        wallet.executeTransaction(0);
    }

    //37
    function test_CannotRevokeAfterCancel() public {
        vm.prank(owner1);
        wallet.submitTransaction(recipient, 1 ether, "");

        vm.prank(owner1);
        wallet.approveTransaction(0);

        vm.prank(owner1);
        wallet.cancelTransaction(0);

        vm.prank(owner1);
        vm.expectRevert("tx cancelled");
        wallet.revokeApproval(0);
    }

    //38
    function test_CancelEmitsEvent() public {
        vm.prank(owner1);
        wallet.submitTransaction(recipient, 1 ether, "");

        vm.prank(owner1);
        vm.expectEmit(true, false, false, false, address(wallet));
        emit Cancelled(0);
        wallet.cancelTransaction(0);
    }

    // expiry tests
    //39
    function test_CannotApproveExpiredTx() public {
        vm.prank(owner1);
        wallet.submitTransaction(recipient, 1 ether, "");

        vm.warp(block.timestamp + 8 days);

        vm.prank(owner2);
        vm.expectRevert("tx expired");
        wallet.approveTransaction(0);
    }

    //40
    function test_CannotExecuteExpiredTx() public {
        vm.deal(address(wallet), 2 ether);

        vm.prank(owner1);
        wallet.submitTransaction(recipient, 1 ether, "");

        vm.prank(owner1);
        wallet.approveTransaction(0);

        vm.prank(owner2);
        wallet.approveTransaction(0);

        vm.warp(block.timestamp + 8 days);

        vm.prank(owner1);
        vm.expectRevert("tx expired");
        wallet.executeTransaction(0);
    }

    //41
    function test_CanApproveBeforeExpiry() public {
        vm.prank(owner1);
        wallet.submitTransaction(recipient, 1 ether, "");

        vm.warp(block.timestamp + 6 days);

        vm.prank(owner2);
        wallet.approveTransaction(0);

        (,,,,,uint approvalCount,) = wallet.getTransaction(0);
        assertEq(approvalCount, 1);
    }
}