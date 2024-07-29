// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.22;

import "forge-std/Script.sol";
import "../src/FundMe.sol";
import "./FundMeHelperConfig.s.sol";

contract DeployFundMe is Script {
    bytes32 public constant Id = 0xde5e6ef09931fecc7fdd8aaa97844e981f3e7bb1c86a6ffc68e9166bb0db3743;

    function deployFundMe() public returns (FundMe, FundMeHelperConfig) {
        FundMeHelperConfig fundMeHelperConfig = new FundMeHelperConfig();
        address ethUsdDataFeed = fundMeHelperConfig.activeNetworkConfig();

        vm.startBroadcast();
        FundMe fundMe = new FundMe(ethUsdDataFeed, Id);
        vm.stopBroadcast();
        return (fundMe, fundMeHelperConfig);
    }

    function run() external returns (FundMe, FundMeHelperConfig) {
        return deployFundMe();
    }
}
