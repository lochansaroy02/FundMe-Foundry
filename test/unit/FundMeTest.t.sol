// SPDX-License-Identifier: MIT

pragma solidity ^0.8.23;
import {Test, console} from "../../lib/forge-std/src/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundme;
    uint256 constant GAS_PRICE = 1;
    address alice = makeAddr("alice");
    uint256 SEND_VALUE = 0.1 ether;
    uint256 constant STARTING_BALANCE = 10 ether;

    function setUp() external {
        vm.deal(alice, STARTING_BALANCE);
        DeployFundMe deployFundme = new DeployFundMe();
        fundme = deployFundme.run();
    }

    // function testIsOwner() public {
    //     console.log(fundme.i_owner());
    //     console.log(msg.sender);
    //     assertEq(fundme.i_owner(), msg.sender);
    // }

    function testFunds() public {
        console.log(address(fundme));
    }

    function testFundFailsWIthoutEnoughETH() public {
        vm.expectRevert(); // <- The next line after this one should revert! If not test fails.
        fundme.fund(); // <- We send 0 value
    }

    function testFundUpdatesFundDataStructure() public {
        vm.prank(alice);

        fundme.fund{value: SEND_VALUE}();
        uint256 amountFunded = fundme.getAddressToAmountFunded(address(alice));
        console.log(amountFunded);
        assertEq(amountFunded, SEND_VALUE); // ammountFunded < SEND_VALUE error
    }

    function testAddsFunderToArrayOfFunders() public {
        vm.startPrank(alice);
        fundme.fund{value: SEND_VALUE}();
        vm.stopPrank();

        address funder = fundme.getFunder(0);
        assertEq(funder, alice);
    }

    function testOnlyOwnerCanWithdraw() public funded {
        vm.expectRevert();
        fundme.withdraw();
    }

    modifier funded() {
        vm.prank(alice);
        fundme.fund{value: SEND_VALUE}();
        assert(address(fundme).balance > 0);
        _;
    }

    function testWithdrawFromASingleFunder() public funded {
        //Arrange
        uint256 initialFundmeBalance = address(fundme).balance;
        uint256 initialOwnerBalance = fundme.getOwner().balance;

        vm.txGasPrice(GAS_PRICE);
        uint256 gasStart = gasleft();

        // Act
        vm.startPrank(fundme.getOwner());
        fundme.withdraw();

        vm.stopPrank();

        uint256 gasEnd = gasleft();
        console.log(gasStart - gasEnd);

        // Assert
        uint256 finalFundmeBalance = address(fundme).balance;
        uint256 finalOwnerBalance = fundme.getOwner().balance;
        assertEq(finalFundmeBalance, 0);
        assertEq(initialFundmeBalance + initialOwnerBalance, finalOwnerBalance);
    }
    
    function testWithdrawFromMultipleFunders() public {
        uint160 numberOfFunders = 3;
        uint160 startingFunderIndex = 0;

        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            // hoax - prank+ deal
            hoax(address(i), SEND_VALUE);
            fundme.fund{value: SEND_VALUE}();
        }

        //Arrange
        uint256 initialFundmeBalance = address(fundme).balance;
        uint256 initialOwnerBalance = fundme.getOwner().balance;

        //Act
        vm.startPrank(fundme.getOwner());
        fundme.withdraw();
        vm.stopPrank();

        //assert

        // assert(address(fundme).balance == 0);
        // assert(
        //     initialFundmeBalance + initialOwnerBalance ==
        //         fundme.getOwner().balance
        // );
        // assert(
        //     (numberOfFunders + 1) * SEND_VALUE ==
        //         fundme.getOwner().balance - initialOwnerBalance
        // );
    }

    function testWithdrawFromMultipleFundersCheaper() public {
        uint160 numberOfFunders = 3;
        uint160 startingFunderIndex = 0;

        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            // hoax - prank+ deal
            hoax(address(i), SEND_VALUE);
            fundme.fund{value: SEND_VALUE}();
        }

        //Arrange
        uint256 initialFundmeBalance = address(fundme).balance;
        uint256 initialOwnerBalance = fundme.getOwner().balance;

        //Act
        vm.startPrank(fundme.getOwner());
        fundme.withdrawCheaper();
        vm.stopPrank();

        //assert

        // assert(address(fundme).balance == 0);
        // assert(
        //     initialFundmeBalance + initialOwnerBalance ==
        //         fundme.getOwner().balance
        // );
        // assert(
        //     (numberOfFunders + 1) * SEND_VALUE ==
        //         fundme.getOwner().balance - initialOwnerBalance
        // );
    }

    // Gas optimization
    function testPrintStorageData() public {
        for (uint256 i = 0; i < 3; i++) {
            bytes32 value = vm.load(address(fundme), bytes32(i));
            console.log("Vaule at location", i, ":");
            console.logBytes32(value);
        }
        // console.log("PriceFeed address:", address(fundme.getPriceFeed()));
    }
}
