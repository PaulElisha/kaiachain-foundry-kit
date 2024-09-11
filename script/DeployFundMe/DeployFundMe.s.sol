// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.22;

import "forge-std/Script.sol";
import '../../src/FundMe/FundMe.sol';
import '../DeployFundMe/FundMeHelperConfig.s.sol';

contract DeployFundMe is Script {

    function deployFundMe() public returns (FundMe, FundMeHelperConfig) {
        FundMeHelperConfig fundMeHelperConfig = new FundMeHelperConfig();
        (address pythDataFeed, bytes32 Id) = fundMeHelperConfig.activeNetworkConfig();

        vm.startBroadcast();
        FundMe fundMe = new FundMe(pythDataFeed, Id);
        vm.stopBroadcast();
        return (fundMe, fundMeHelperConfig);
    }

    function run() external returns (FundMe, FundMeHelperConfig) {
        return deployFundMe();
    }
}
