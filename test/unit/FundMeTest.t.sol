// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
  FundMe public fundMe;
  address ALICE = makeAddr("ALICE");
  uint256 ALICE_INITIAL_BALANCE = 100 ether;
  uint256 SEND_ETH = 0.1 ether;

  function setUp() public {
    DeployFundMe deployFundMe = new DeployFundMe();
    fundMe = deployFundMe.run();
    deal(ALICE, ALICE_INITIAL_BALANCE);
  }

  /** MODIFIERS */

  modifier funded() {
    vm.prank(ALICE);
    fundMe.fund{value: SEND_ETH}();
    _;
  }

  /** MINIMUM USD */

  function testMinimumDollarIsFive() public {
    assertEq(fundMe.MINIMUM_USD(), 5e18);
  }

  /** OWNER */

  function testOwnerIsDeployer() public {
    assertEq(fundMe.getOwner(), msg.sender);
  }

  /** PRICE FEED VERSION */

  function testPriceFeedVersionIsCorrect() public {
    uint256 version = fundMe.getVersion();
    assertEq(version, 4);
  }

  /** FUND FUNCTION */

  function testFundFailsWithoutEnoughEth() public {
    vm.expectRevert();
    fundMe.fund();
  }

  function testFundUpdatesFunderBalance() public funded {
    uint256 balance = fundMe.getFunderBalance(ALICE);

    assertEq(balance, SEND_ETH);
  }

  function testFundUpdatesFundersArray() public funded {
    assertEq(fundMe.getFunder(0), ALICE);
  }

  /** WITHDRAW FUNCTION */

  function testOnlyOwnerCanWithdraw() public funded {
    vm.prank(ALICE);
    vm.expectRevert();
    fundMe.withdraw();
  }

  function testWithdrawWithASingleFunder() public funded {
    uint256 startingOwnerBalance = address(fundMe.getOwner()).balance;
    uint256 startingFundMeBalance = address(fundMe).balance;

    vm.prank(fundMe.getOwner());
    fundMe.withdraw();

    uint256 endingOwnerBalance = address(fundMe.getOwner()).balance;
    assertEq(endingOwnerBalance - startingOwnerBalance, startingFundMeBalance);
  }

  function testWithdrawFromMultipleFunders() public {
    // Arrange
    uint160 numberOfFunders = 10;

    for (uint160 i = 1; i < numberOfFunders; i++) {
      hoax(address(i), SEND_ETH); // hoax = vm.prank from address
      fundMe.fund{value: SEND_ETH}();
    }

    uint256 startingOwnerBalance = address(fundMe.getOwner()).balance;
    uint256 startingFundMeBalance = address(fundMe).balance;

    // Act
    vm.prank(fundMe.getOwner());
    fundMe.withdraw();

    // Assert
    uint256 endingOwnerBalance = address(fundMe.getOwner()).balance;
    assertEq(endingOwnerBalance - startingOwnerBalance, startingFundMeBalance);
  }
}
