// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test,console} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";

contract FundmeTest is Test {

    int public number = 0;
    FundMe fundMe;
    address USER = makeAddr("user");



    //caller : CLI-> FundMeTest contract -> DeployFundMe contract-> VM.startBroadcast  -> FundMe obj 
    function setUp() external {
        number = 2;
        //fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        DeployFundMe obj = new DeployFundMe();
        fundMe = obj.run();
        vm.deal(USER,100e18);

    }

    
    function testMimimumDollarIsFive() external {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    // CLI -> VM.tester -> test
    function testOwnerIsMsgSender() public {
        assertEq(fundMe.getOwner(), msg.sender);
    }

    
    function testPriceFeedIsAccurate() public {
        uint256 version = fundMe.getVersion();
        assertEq(version, 4);
    }

    function testFundFailsWithoutEnoughETH() public {
        vm.expectRevert();
        fundMe.fund{value:1}();
    }


    function testFundUpdatesFundedDataStructure() public {
        vm.prank(USER);
        vm.deal(USER,20e18);
        fundMe.fund{value: 10e18}();
        console.log(USER);
        console.log(fundMe.getAdressToAmountFunded(USER));
        console.log(fundMe.getFunders(0));
         uint256 amount = fundMe.getAdressToAmountFunded(USER);
         assertEq(amount, 10e18);

    }

    function testAddsFunderToArrayOfFunders() public {
        vm.prank(USER);
        fundMe.fund{value: 1e18}();

        assertEq(USER,fundMe.getFunders(0));
    
    }
    
    function testOnlyOwnerCanWithdraw()public{

    }

    function testWitdrawnWithASingleFunder()public{
        vm.prank(USER);
        fundMe.fund{value: 1e18}();

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance =address(fundMe).balance;

        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance  = address(fundMe).balance;

        assertEq(endingFundMeBalance, 0);
        assertEq(startingOwnerBalance +startingFundMeBalance ,endingOwnerBalance ) ;

    }
 

    function testWitdrawnWithMultipleFunders() public {


        
    }








}