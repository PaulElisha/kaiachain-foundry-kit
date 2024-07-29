// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.22;

import "forge-std/Test.sol";
import "../../src/FundMe.sol";
import "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;
    address USER = makeAddr("user");
    address USER1 = makeAddr("user1");
    uint256 constant SEND_VALUE = 5 ether;
    uint256 constant STARTING_BALANCE = 10 ether;
    uint256 constant GAS_PRICE = 1;

    function setUp() public {
        // fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        DeployFundMe deployFundMe = new DeployFundMe();
        (fundMe, ) = deployFundMe.deployFundMe();
        vm.deal(USER, STARTING_BALANCE);
    }

    function testMinimumUsd() public view {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwner() public view {
        assertEq(fundMe.getOwner(), msg.sender);
    }

    function testFundFailsNotEnoughEth() public {
        vm.expectRevert();
        fundMe.fundUnsafe(); // Not Enough Eth Sent
    }

    function testFundFailsNotEnoughEthAndEmptyCallData() public {
        vm.expectRevert();
        fundMe.fundWithPriceUpdate(new bytes[](0)); // Not Enough Eth Sent
    }

    function testFundFailsEmptyCallData() public {
        vm.expectRevert();
        fundMe.fundWithPriceUpdate{value: SEND_VALUE}(new bytes[](0)); // Not Enough Eth Sent
    }

    modifier fundUnsafe() {
        vm.prank(USER);
        fundMe.fundUnsafe{value: SEND_VALUE}();
        _;
    }

    modifier fundWithPriceUpdate() {
        vm.prank(USER);
        fundMe.fundWithPriceUpdate{value: SEND_VALUE}(new bytes[](0));
        _;
    }

    function testFundUpdatesFunderMapping() public fundUnsafe {
        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        assertEq(amountFunded, SEND_VALUE);
    }

    function testGetFunderInArray() public fundUnsafe {
        address funder = fundMe.getFunder(0);
        vm.expectRevert();
        assertEq(funder, USER1);
    }

    function testNotFunderInArray() public fundUnsafe {
        address funder = fundMe.getFunder(0);
        assertEq(funder, USER);
    }

    function testOnlyOwnerCanWithdraw() public fundUnsafe {
        vm.expectRevert();
        vm.prank(USER);
        fundMe.withdraw();
    }

    function testWithdrawWithASingleFunder() public fundUnsafe {
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingfundMeBalance = address(fundMe).balance;

        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingfundMeBalance = address(fundMe).balance;

        assertEq(endingfundMeBalance, 0);
        assertEq(
            startingfundMeBalance + startingOwnerBalance,
            endingOwnerBalance
        );
    }

    function testWithdrawWithMultipleFunders() public fundUnsafe {
        uint160 numberOfFunders = 10;
        uint160 startingFundersIndex = 1;

        for (uint160 i = startingFundersIndex; i < numberOfFunders; i++) {
            hoax(address(i), SEND_VALUE);
            fundMe.fundUnsafe{value: SEND_VALUE}();
        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingfundMeBalance = address(fundMe).balance;
        console.log(startingfundMeBalance);

        uint256 gasStart = gasleft();
        vm.txGasPrice(GAS_PRICE);

        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        uint256 gasEnd = gasleft();
        uint256 gasUsed = (gasStart - gasEnd) * tx.gasprice;
        console.log(gasUsed);

        assert(address(fundMe).balance == 0);
        assert(
            startingfundMeBalance + startingOwnerBalance ==
                fundMe.getOwner().balance
        );
    }
}
