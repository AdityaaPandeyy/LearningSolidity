// SPDX-License-Identifier:MIT
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;
    uint256 public constant SEND_VALUE = 0.2 ether;
    uint256 public constant STARTING_USER_BALANCE = 10 ether;
    address public constant USER = address(1);

    // msg.sender is the person who deployed this FundMeTest , address(this) is the address of FundMeTest which further funds fundMe instance
    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, STARTING_USER_BALANCE);
    }

    function testWhoIsOwner() public view {
        assert(fundMe.getOwner() == msg.sender);
    }

    function testMinDollarisFive() public {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testVersion() public {
        assertEq(fundMe.getVersion(), 4);
    }

    function testFundFailsWithoutEnoughETH() public {
        vm.expectRevert();
        fundMe.fund(); // == fundMe{value:0}.fund()
    }

    function testFundUpdatesFundedDataStructure() public {
        fundMe.fund{value: 10e18}();
        assertEq(fundMe.getAddressToAmountFunded(address(this)), 10e18);
    }

    function testFunderDataStructure() public {
        fundMe.fund{value: 10e18}();
        assert(fundMe.getFunder(0) == address(this));
    }

    function testNotOwnerWithdraw() public {
        vm.expectRevert();
        fundMe.withdraw(); // this will revert because it is only msg.sender who can withdraw
    }

    function testWithDrawWithASingleFunder() public {}

    function testOwnerForKnowledge1() public {
        assertEq(fundMe.getOwner(), msg.sender); // passes
        //assertEq(USER,msg.sender); // fails
    }

    function testForKnowledge2() public {
        // assertEq(address(this),msg.sender); //fails always
        assertEq(address(this).balance, msg.sender.balance); //initially the balance of FundMeTest(left) and the only who deployed FundMeTest(right) is same

        // fundMe.fund{value: 2e17}();
        // assertEq(address(this).balance,msg.sender.balance); //fails because 2e17 wei is given to fundMe by address(this) aka FundMeTest
    }

    function testForKnowledge3() public {
        uint256 startingFundMeTestBalance = address(this).balance;
        uint256 startingFundMeBalance = address(fundMe).balance; // 0 initially
        // assertEq(startingOwnerBalance,0); //passes
        // assertEq(fundMe.getOwner(),msg.sender); //passes
        // assertEq(startingOwnerBalance,msg.sender.balance); //passes

        fundMe.fund{value: 2e17}(); //FundMeTest gave 2e17 to fundMe

        uint256 currentFundMeTestBalance = address(this).balance;
        uint256 currentFundMeBalance = address(fundMe).balance;
        // assertEq(currentFundMeBalance,2e17); //passes

        // assertEq(startingFundMeTestBalance-2e17,currentFundMeTestBalance); //passes
    }

    function testWithdrawFromASingleFunderWithoutGas() public {
        // Arrange
        fundMe.fund{value: 2e17}();
        uint256 startingFundMeBalance = address(fundMe).balance; // 2e17 at this point
        uint256 startingOwnerBalance = fundMe.getOwner().balance; // same as msg.sender.balance(they r literally the same thing always)

        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();

        uint256 endingFundMeBalance = address(fundMe).balance; // 0 now
        uint256 endingOwnerBalance = fundMe.getOwner().balance; // startingOwnerBalance+2e17
        // assertEq(endingFundMeBalance, 0);//passes
        // assertEq(startingFundMeBalance + startingOwnerBalance,endingOwnerBalance); //passes
    }

    function testWithdrawFromASingleFunderWithGas() public {
        // Arrange
        fundMe.fund{value: 2e17}();
        uint256 startingFundMeBalance = address(fundMe).balance; // 2e17 at this point
        uint256 startingOwnerBalance = fundMe.getOwner().balance; // same as msg.sender.balance(they r literally the same thing always)

        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();

        uint256 endingFundMeBalance = address(fundMe).balance; // 0 now
        uint256 endingOwnerBalance = fundMe.getOwner().balance; // startingOwnerBalance+2e17
        // assertEq(endingFundMeBalance, 0);//passes
        // assertEq(startingFundMeBalance + startingOwnerBalance,endingOwnerBalance); //passes
    }
}
