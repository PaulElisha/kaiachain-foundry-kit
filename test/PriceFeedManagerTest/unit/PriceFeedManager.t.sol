// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.20;

import 'forge-std/Test.sol';
import '../../../src/OraklPriceFeedManager/PriceFeedManager.sol';

contract PriceFeedManagerTest is Test {
    PriceFeedManager priceFeedManager;
    address public constant BAOBAB_UNI = 0xE4b4c779738ebF52523e6f0f21f977af34085842;
    address public constant CYPRESS_UNI = 0x0c523429A32E8597C3bfF73923d24F4c0b566AfE;

    function setUp() public {
        priceFeedManager = new PriceFeedManager();
    }

    function testgetBaobabFeedAddress() public view {
        address Uni = priceFeedManager.getBaobabFeedAddress("UNI-USDT");
        assertEq(Uni, BAOBAB_UNI);
    }

    function testgetCypressFeedAddress() public view {
        address Uni = priceFeedManager.getCypressFeedAddress("UNI-USDT");
        assertEq(Uni, CYPRESS_UNI);
    }
}