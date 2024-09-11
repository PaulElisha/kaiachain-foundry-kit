// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import  "./DeployHelper.s.sol";
import '../../src/Token/TokenERC20.sol';
import '../../src/LuckyDraw/LuckyDraw.sol';

contract Deploy is Script {
    function run() external returns (LuckyDraw, TokenERC20, DeployHelper) {
        /// @dev initialize the DeployHelper contract
        DeployHelper deployHelper = new DeployHelper();

        /// @dev get the active network configuration using the DeployHelper contract
        (address dataFeed, address coordinator, bytes32 keyHash, uint64 accountId) =
            deployHelper.activeNetworkConfig();

        /// @dev start the broadcast
        vm.startBroadcast();

        LuckyDraw luckyDraw = new LuckyDraw(dataFeed, coordinator, keyHash, accountId);
        /// @dev create a new Monee contract with the active network configuration
        TokenERC20 tokenERC20 = new TokenERC20(address(luckyDraw));

        /// @dev stop the broadcast
        vm.stopBroadcast();

        /// @dev return the Counter and DeployHelper contracts
        return (luckyDraw, tokenERC20, deployHelper);
    }
}
