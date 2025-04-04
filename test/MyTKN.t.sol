// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {MyTKN} from "../src/MyTKN.sol";

contract MyTKNTest is Test {
    MyTKN public myTKN;
    uint256 public initialSupply;
    address tokenOwner;

    function setUp() public {
        myTKN = new MyTKN("MTK", "myTOken");
        initialSupply = 1000000 * 10 ** myTKN.decimals();
        tokenOwner = myTKN.owner();
    }

    function test_mintOwner() public {
        uint256 balanceOwnerBeforeMint = myTKN.balanceOf(address(this));
        _mint();
        uint256 balanceOwnerAfterMint = myTKN.balanceOf(address(this));
        assertEq(balanceOwnerAfterMint - balanceOwnerBeforeMint, initialSupply);
        assertEq(myTKN.totalSupply(), initialSupply);
    }

    function test_mintNotOwner() public {
        address notOwner = makeAddr("NOTOWNER");
        vm.startPrank(notOwner);
        vm.expectRevert(bytes("only owner can create tokens"));
        _mint();
        vm.stopPrank();
    }

    function test_transfer() public {
        _mint();
        address bob = makeAddr("BOB");
        uint256 balanceBOBBeforeTransfer = myTKN.balanceOf(bob);
        _transfer(bob, 100);
        uint256 balanceBOBAfterTransfer = myTKN.balanceOf(bob);
        assertEq(balanceBOBAfterTransfer - balanceBOBBeforeTransfer, 100);
    }

    function test_Reverttransfer() public {
        _mint();
        address alice = makeAddr("ALICE");
        address bob = makeAddr("BOB");
        vm.startPrank(bob);
        vm.expectRevert(bytes("you don't have enough tokens"));
        _transfer(alice, 100);
        vm.stopPrank();
    }

    function test_ReverttransferAdress0() public {
        _mint();
        vm.expectRevert(bytes("canno't transfer to zero address"));
        _transfer(address(0), 100);
    }

    function test_approve() public {
        _mint();
        address bob = makeAddr("BOB");
        uint256 allowanceBOBBefore = myTKN.allowances(address(this), bob);
        _approve(bob, 100);
        uint256 allowanceBOBAfter = myTKN.allowances(address(this), bob);
        assertEq(allowanceBOBAfter - allowanceBOBBefore, 100);
    }

    function test_ReverttransferFromAmount() public {
        _mint();
        address bob = makeAddr("BOB");
        address alice = makeAddr("ALICE");
        uint256 exceedBalance = 10000000 * 10 ** myTKN.decimals();
        _approve(bob, exceedBalance);

        vm.startPrank(bob);
        vm.expectRevert(bytes("you don't have enough tokens"));
        myTKN.transferFrom(address(this), alice, exceedBalance);
        vm.stopPrank();
    }

    function test_transferFrom() public {
        _mint();
        address bob = makeAddr("BOB");
        address alice = makeAddr("ALICE");
        _approve(bob, 100);
        uint256 allowanceBOBBefore = myTKN.allowances(address(this), bob); //100
        uint256 balanceALICEBeforeTransfer = myTKN.balanceOf(alice);
        vm.startPrank(bob);
        myTKN.transferFrom(address(this), alice, 10);
        vm.stopPrank();
        uint256 balanceALICEAfterTransfer = myTKN.balanceOf(alice);
        uint256 allowanceBOBAfter = myTKN.allowances(address(this), bob); //90
        assertEq(allowanceBOBBefore - allowanceBOBAfter, 10);
        assertEq(balanceALICEAfterTransfer - balanceALICEBeforeTransfer, 10);
    }

    function test_ReverttransferFromAllowance() public {
        _mint();
        address bob = makeAddr("BOB");
        address alice = makeAddr("ALICE");
        _approve(bob, 100);
        vm.startPrank(bob);
        vm.expectRevert(bytes("you don't have enough allowances"));
        myTKN.transferFrom(address(this), alice, 110);
        vm.stopPrank();
    }

    //Helper functions
    function _mint() internal {
        myTKN.mint(initialSupply);
    }

    function _transfer(address to, uint256 amount) internal {
        myTKN.transfer(to, amount);
    }

    function _approve(address to, uint256 amount) internal {
        myTKN.approve(to, amount);
    }
}
