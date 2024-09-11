// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import  "forge-std/Script.sol";
import '../../src/LuckyDraw/LuckyDraw.sol';
import  "orakl/contracts/v0.1/src/interfaces/IPrepayment.sol";
import "lib/foundry-devops/src/DevOpsTools.sol";

contract DrawLuckyDraw is Script {
    /// -----------------------------------------------------------------------
    /// Oracle variables
    /// -----------------------------------------------------------------------
    address oraklPrepaymentAddress = 0x8d3A1663d10eEb0bC9C9e537e1BBeA69383194e7;
    IPrepayment prepayment = IPrepayment(oraklPrepaymentAddress);
    /// -----------------------------------------------------------------------
    /// DevOps variables
    /// -----------------------------------------------------------------------
    address luckyDrawDeployedAddress = DevOpsTools.get_most_recent_deployment("LuckyDraw", block.chainid);
    address tokenERC20DeployedAddress = DevOpsTools.get_most_recent_deployment("TokenERC20", block.chainid);

    /// -----------------------------------------------------------------------
    /// Interactions
    /// -----------------------------------------------------------------------
    function run() external {
        vm.startBroadcast();
        prepayment.addConsumer(777, luckyDrawDeployedAddress);
        console.log("Added consumer");
        LuckyDraw luckyDraw = LuckyDraw(luckyDrawDeployedAddress);
        luckyDraw.setERC20Token(tokenERC20DeployedAddress);
        console.log("Set ERC20 Token");
        luckyDraw.requestRandomWords();
        vm.stopBroadcast();
        console.log("Drawn LuckyDraw");
    }
}
