// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
import {Script} from "../lib/forge-std/src/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {HelperConfig} from "../script/HelperConfig.s.sol";

contract DeployFundMe is Script {
    function run() external returns (FundMe fundMe) {
        HelperConfig helperConfig = new HelperConfig();
        address ethUsdPriceFeed = helperConfig.activeNetworkConfig();

        vm.startBroadcast();
        fundMe = new FundMe(ethUsdPriceFeed);
        vm.stopBroadcast();
    }
}
