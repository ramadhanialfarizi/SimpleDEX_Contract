// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {SimpleDex} from "../src/SimpleDex.sol";
import {MockToken} from "../src/MockToken.sol";

contract SimpleDexScript is Script {
    SimpleDex public simpleDex;
    MockToken public tokenA;
    MockToken public tokenB;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        // 1. Deploy mock tokens dulu
        tokenA = new MockToken("Token A", "TKA");
        tokenB = new MockToken("Token B", "TKB");

        // 2. Deploy SimpleDex dengan address token yang valid
        simpleDex = new SimpleDex(address(tokenA), address(tokenB));

        vm.stopBroadcast();
    }
}