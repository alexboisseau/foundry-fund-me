// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import {Script, console} from "forge-std/Script.sol";
import {DevOpsTools} from "@foundry-devops/DevOpsTools.sol";
import {FundMe} from "../src/FundMe.sol";

contract FundFundMe is Script {
  uint256 private constant SEND_VALUE = 0.007 ether;

  function fundFundMe(address _contractAddress) public {
    vm.startBroadcast();
    FundMe(payable(_contractAddress)).fund{value: SEND_VALUE}();
    vm.stopBroadcast();
    console.log("Funded FundMe with %s", SEND_VALUE);
  }

  function run() public {
    address mostRecentlyDeployedFundMe = DevOpsTools.get_most_recent_deployment(
      "FundMe",
      block.chainid
    );
    fundFundMe(mostRecentlyDeployedFundMe);
  }
}

contract WithdrawFundMe is Script {
  function withdrawFundMe(address mostRecentlyDeployed) public {
    vm.startBroadcast();
    FundMe(payable(mostRecentlyDeployed)).withdraw();
    vm.stopBroadcast();
    console.log("Withdraw FundMe balance!");
  }

  function run() external {
    address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment(
      "FundMe",
      block.chainid
    );
    withdrawFundMe(mostRecentlyDeployed);
  }
}
