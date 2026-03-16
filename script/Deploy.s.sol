// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {MultiSigWallet} from "../src/MultiSigWallet.sol";

contract DeployMultiSigWallet is Script {
    function run() external returns (MultiSigWallet) {
        uint deployerKey = vm.envUint("PRIVATE_KEY");

        address[] memory owners = new address[](3);
        owners[0] = vm.envAddress("OWNER1");
        owners[1] = vm.envAddress("OWNER2");
        owners[2] = vm.envAddress("OWNER3");

        uint required = 2;

        vm.startBroadcast(deployerKey);
        MultiSigWallet wallet = new MultiSigWallet(owners, required);
        vm.stopBroadcast();

        console.log("MultiSigWallet deployed at:", address(wallet));
        return wallet;
    }
}