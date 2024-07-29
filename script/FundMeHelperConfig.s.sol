// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.22;

import "forge-std/Script.sol";

contract FundMeHelperConfig is Script {
    
    struct NetworkConfig {
        address dataFeed;
        bytes32 id; // Eth dataFeed
    }

    NetworkConfig public activeNetworkConfig;

    constructor() {
        if (block.chainid == 1001) {
            activeNetworkConfig = getKaiaKairosConfig();
        } else if (block.chainid == 8217) {
            activeNetworkConfig = getKaiaMainnetConfig();
        } else {
            revert();
        }
    }

    function getKaiaKairosConfig()
        public
        pure
        returns (NetworkConfig memory)
    {
        NetworkConfig memory networkConfig = NetworkConfig({
            dataFeed: 0x2880aB155794e7179c9eE2e38200202908C17B43,
            id: 0xde5e6ef09931fecc7fdd8aaa97844e981f3e7bb1c86a6ffc68e9166bb0db3743
        });
        return networkConfig;
    }

    function getKaiaMainnetConfig()
        public
        pure
        returns (NetworkConfig memory)
    {
        NetworkConfig memory networkConfig = NetworkConfig({
            dataFeed: 0x2880aB155794e7179c9eE2e38200202908C17B43,
            id: 0xde5e6ef09931fecc7fdd8aaa97844e981f3e7bb1c86a6ffc68e9166bb0db3743
        });
        return networkConfig;
    }
}
