// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import {Test} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {FundFundMe, WithdrawFundMe} from "../../script/Interactions.s.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";

contract InteractionsTest is Test {
  uint256 private constant SEND_VALUE = 0.1 ether;
  uint256 private constant STARTING_USER_BALANCE = 10 ether;
  address private constant USER = address(1);

  FundMe private fundMe;
  HelperConfig private helperConfig;

  function setUp() public {
    DeployFundMe deployer = new DeployFundMe();
    fundMe = deployer.run();
    vm.deal(USER, STARTING_USER_BALANCE);
  }

  function testUserCanFundAndOwnerWithdraw() public {
    FundFundMe fundFundMe = new FundFundMe();
    fundFundMe.fundFundMe(address(fundMe));

    WithdrawFundMe withdrawFundMe = new WithdrawFundMe();
    withdrawFundMe.withdrawFundMe(address(fundMe));

    assert(address(fundMe).balance == 0);
  }
}
