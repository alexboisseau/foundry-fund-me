// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import {Script} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployFundMe is Script {
  function run() external returns (FundMe) {
    // AftBeforeer start broadcast => Fake tx
    HelperConfig helperConfig = new HelperConfig();
    address priceFeed = helperConfig.activeNetworkConfig();

    // After start broadcast => Real tx
    vm.startBroadcast();
    FundMe fundMe = new FundMe(priceFeed);
    vm.stopBroadcast();
    return fundMe;
  }
}
