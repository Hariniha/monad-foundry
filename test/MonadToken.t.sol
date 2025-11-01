// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/MonadToken.sol";

contract MonadTokenTest is Test {
    MonadToken public token;
    address public owner;
    address public minter;
    address public pauser;
    address public user1;
    address public user2;

    event TokensMinted(address indexed to, uint256 amount, address indexed minter);
    event TokensBurned(address indexed from, uint256 amount);
    event RoleGrantedByAdmin(bytes32 indexed role, address indexed account, address indexed admin);
    event RoleRevokedByAdmin(bytes32 indexed role, address indexed account, address indexed admin);

    function setUp() public {
        owner = address(this);
        minter = makeAddr("minter");
        pauser = makeAddr("pauser");
        user1 = makeAddr("user1");
        user2 = makeAddr("user2");

        token = new MonadToken();
    }

    /*//////////////////////////////////////////////////////////////
                            DEPLOYMENT TESTS
    //////////////////////////////////////////////////////////////*/

    function test_Deployment() public {
        assertEq(token.name(), "Monad Token");
        assertEq(token.symbol(), "MONA");
        assertEq(token.decimals(), 18);
        assertEq(token.totalSupply(), 100_000 * 10**18);
        assertEq(token.balanceOf(owner), 100_000 * 10**18);
    }

    function test_InitialRoles() public {
        assertTrue(token.isAdmin(owner));
        assertTrue(token.isMinter(owner));
        assertTrue(token.isPauser(owner));
        assertFalse(token.isAdmin(user1));
        assertFalse(token.isMinter(user1));
        assertFalse(token.isPauser(user1));
    }

    /*//////////////////////////////////////////////////////////////
                            MINTING TESTS
    //////////////////////////////////////////////////////////////*/

    function test_Mint() public {
        uint256 mintAmount = 1000 * 10**18;
        uint256 initialBalance = token.balanceOf(user1);
        uint256 initialSupply = token.totalSupply();

        vm.expectEmit(true, true, false, true);
        emit TokensMinted(user1, mintAmount, owner);
        
        token.mint(user1, mintAmount);

        assertEq(token.balanceOf(user1), initialBalance + mintAmount);
        assertEq(token.totalSupply(), initialSupply + mintAmount);
    }

    function test_MintByMinter() public {
        token.grantMinterRole(minter);
        uint256 mintAmount = 500 * 10**18;

        vm.prank(minter);
        token.mint(user1, mintAmount);

        assertEq(token.balanceOf(user1), mintAmount);
    }

    function test_RevertWhen_NonMinterMints() public {
        uint256 mintAmount = 1000 * 10**18;

        vm.prank(user1);
        vm.expectRevert();
        token.mint(user2, mintAmount);
    }

    function testFuzz_Mint(address to, uint256 amount) public {
        vm.assume(to != address(0));
        vm.assume(amount < type(uint256).max / 2);

        uint256 initialBalance = token.balanceOf(to);
        token.mint(to, amount);
        assertEq(token.balanceOf(to), initialBalance + amount);
    }

    /*//////////////////////////////////////////////////////////////
                            BURNING TESTS
    //////////////////////////////////////////////////////////////*/

    function test_Burn() public {
        uint256 burnAmount = 1000 * 10**18;
        uint256 initialBalance = token.balanceOf(owner);
        uint256 initialSupply = token.totalSupply();

        vm.expectEmit(true, false, false, true);
        emit TokensBurned(owner, burnAmount);

        token.burn(burnAmount);

        assertEq(token.balanceOf(owner), initialBalance - burnAmount);
        assertEq(token.totalSupply(), initialSupply - burnAmount);
    }

    function test_BurnByUser() public {
        uint256 mintAmount = 1000 * 10**18;
        token.mint(user1, mintAmount);

        vm.prank(user1);
        token.burn(500 * 10**18);

        assertEq(token.balanceOf(user1), 500 * 10**18);
    }

    function test_RevertWhen_BurnMoreThanBalance() public {
        vm.prank(user1);
        vm.expectRevert();
        token.burn(1000 * 10**18);
    }

    /*//////////////////////////////////////////////////////////////
                            PAUSE TESTS
    //////////////////////////////////////////////////////////////*/

    function test_Pause() public {
        token.pause();
        assertTrue(token.paused());

        vm.expectRevert();
        token.transfer(user1, 100 * 10**18);
    }

    function test_Unpause() public {
        token.pause();
        token.unpause();
        assertFalse(token.paused());

        token.transfer(user1, 100 * 10**18);
        assertEq(token.balanceOf(user1), 100 * 10**18);
    }

    function test_PauseByPauser() public {
        token.grantPauserRole(pauser);

        vm.prank(pauser);
        token.pause();
        assertTrue(token.paused());
    }

    function test_RevertWhen_NonPauserPauses() public {
        vm.prank(user1);
        vm.expectRevert();
        token.pause();
    }

    function test_RevertWhen_TransferWhilePaused() public {
        token.pause();
        
        vm.expectRevert();
        token.transfer(user1, 100 * 10**18);
    }

    /*//////////////////////////////////////////////////////////////
                        ROLE MANAGEMENT TESTS
    //////////////////////////////////////////////////////////////*/

    function test_GrantMinterRole() public {
        assertFalse(token.isMinter(user1));
        
        vm.expectEmit(true, true, true, true);
        emit RoleGrantedByAdmin(token.MINTER_ROLE(), user1, owner);
        
        token.grantMinterRole(user1);
        assertTrue(token.isMinter(user1));
    }

    function test_RevokeMinterRole() public {
        token.grantMinterRole(user1);
        assertTrue(token.isMinter(user1));

        vm.expectEmit(true, true, true, true);
        emit RoleRevokedByAdmin(token.MINTER_ROLE(), user1, owner);

        token.revokeMinterRole(user1);
        assertFalse(token.isMinter(user1));
    }

    function test_GrantPauserRole() public {
        assertFalse(token.isPauser(user1));
        token.grantPauserRole(user1);
        assertTrue(token.isPauser(user1));
    }

    function test_RevokePauserRole() public {
        token.grantPauserRole(user1);
        token.revokePauserRole(user1);
        assertFalse(token.isPauser(user1));
    }

    function test_GrantAdminRole() public {
        assertFalse(token.isAdmin(user1));
        token.grantAdminRole(user1);
        assertTrue(token.isAdmin(user1));
    }

    function test_RevokeAdminRole() public {
        token.grantAdminRole(user1);
        token.revokeAdminRole(user1);
        assertFalse(token.isAdmin(user1));
    }

    function test_RevertWhen_NonAdminGrantsRole() public {
        vm.prank(user1);
        vm.expectRevert();
        token.grantMinterRole(user2);
    }

    function test_RevertWhen_NonAdminRevokesRole() public {
        token.grantMinterRole(user1);

        vm.prank(user2);
        vm.expectRevert();
        token.revokeMinterRole(user1);
    }

    /*//////////////////////////////////////////////////////////////
                        TRANSFER TESTS
    //////////////////////////////////////////////////////////////*/

    function test_Transfer() public {
        uint256 transferAmount = 1000 * 10**18;
        token.transfer(user1, transferAmount);

        assertEq(token.balanceOf(user1), transferAmount);
        assertEq(token.balanceOf(owner), 100_000 * 10**18 - transferAmount);
    }

    function test_TransferFrom() public {
        uint256 transferAmount = 1000 * 10**18;
        
        token.approve(user1, transferAmount);

        vm.prank(user1);
        token.transferFrom(owner, user2, transferAmount);

        assertEq(token.balanceOf(user2), transferAmount);
    }

    function testFuzz_Transfer(address to, uint256 amount) public {
        vm.assume(to != address(0));
        vm.assume(to != owner);
        vm.assume(amount <= token.balanceOf(owner));

        token.transfer(to, amount);
        assertEq(token.balanceOf(to), amount);
    }

    /*//////////////////////////////////////////////////////////////
                        INTEGRATION TESTS
    //////////////////////////////////////////////////////////////*/

    function test_CompleteWorkflow() public {
        // Grant roles
        token.grantMinterRole(minter);
        token.grantPauserRole(pauser);

        // Minter mints tokens
        vm.prank(minter);
        token.mint(user1, 1000 * 10**18);
        assertEq(token.balanceOf(user1), 1000 * 10**18);

        // User burns tokens
        vm.prank(user1);
        token.burn(200 * 10**18);
        assertEq(token.balanceOf(user1), 800 * 10**18);

        // Pauser pauses transfers
        vm.prank(pauser);
        token.pause();

        // Transfer should fail
        vm.prank(user1);
        vm.expectRevert();
        token.transfer(user2, 100 * 10**18);

        // Pauser unpauses
        vm.prank(pauser);
        token.unpause();

        // Transfer should work
        vm.prank(user1);
        token.transfer(user2, 100 * 10**18);
        assertEq(token.balanceOf(user2), 100 * 10**18);
    }

    function test_MultipleAdmins() public {
        // Grant admin role to user1
        token.grantAdminRole(user1);

        // user1 can now grant minter role
        vm.prank(user1);
        token.grantMinterRole(user2);
        assertTrue(token.isMinter(user2));

        // user2 can now mint
        vm.prank(user2);
        token.mint(user2, 1000 * 10**18);
        assertEq(token.balanceOf(user2), 1000 * 10**18);
    }
}
