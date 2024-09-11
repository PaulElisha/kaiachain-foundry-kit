// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import '../src/PriceFeedManager.sol';

contract DeployPriceFeedManager is Script {

     function run() external returns (PriceFeedManager) {
        vm.startBroadcast();
        PriceFeedManager priceFeedManager = new PriceFeedManager();
        vm.stopBroadcast();

        address uni = priceFeedManager.getBaobabFeedAddress("UNI-USDT");
        address Uni = priceFeedManager.getCypressFeedAddress("UNI-USDT");
        console.log(uni);
        console.log(Uni);

        return priceFeedManager;

    }

    
}
