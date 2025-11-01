// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Pausable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

/**
 * @title MonadToken
 * @dev ERC20 Token with role-based access control
 * Roles:
 * - DEFAULT_ADMIN_ROLE: Can grant/revoke all roles
 * - MINTER_ROLE: Can mint new tokens
 * - PAUSER_ROLE: Can pause/unpause token transfers
 */
contract MonadToken is ERC20, ERC20Pausable, ERC20Burnable, AccessControl {
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");

    event TokensMinted(address indexed to, uint256 amount, address indexed minter);
    event TokensBurned(address indexed from, uint256 amount);
    event RoleGrantedByAdmin(bytes32 indexed role, address indexed account, address indexed admin);
    event RoleRevokedByAdmin(bytes32 indexed role, address indexed account, address indexed admin);

    /**
     * @dev Constructor that gives msg.sender all roles and mints initial supply
     */
    constructor() ERC20("Monad Token", "MONA") {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);
        _grantRole(PAUSER_ROLE, msg.sender);

        _mint(msg.sender, 100_000 * 10**decimals()); // Initial Supply: 100,000 MONA
    }

    /**
     * @dev Mint new tokens to an address
     * @param to The address that will receive the minted tokens
     * @param amount The amount of tokens to mint
     */
    function mint(address to, uint256 amount) public onlyRole(MINTER_ROLE) {
        _mint(to, amount);
        emit TokensMinted(to, amount, msg.sender);
    }

    /**
     * @dev Pause all token transfers
     */
    function pause() public onlyRole(PAUSER_ROLE) {
        _pause();
    }

    /**
     * @dev Unpause token transfers
     */
    function unpause() public onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    /**
     * @dev Grant minter role to an account
     * @param account The address to grant the role to
     */
    function grantMinterRole(address account) public onlyRole(DEFAULT_ADMIN_ROLE) {
        grantRole(MINTER_ROLE, account);
        emit RoleGrantedByAdmin(MINTER_ROLE, account, msg.sender);
    }

    /**
     * @dev Revoke minter role from an account
     * @param account The address to revoke the role from
     */
    function revokeMinterRole(address account) public onlyRole(DEFAULT_ADMIN_ROLE) {
        revokeRole(MINTER_ROLE, account);
        emit RoleRevokedByAdmin(MINTER_ROLE, account, msg.sender);
    }

    /**
     * @dev Grant pauser role to an account
     * @param account The address to grant the role to
     */
    function grantPauserRole(address account) public onlyRole(DEFAULT_ADMIN_ROLE) {
        grantRole(PAUSER_ROLE, account);
        emit RoleGrantedByAdmin(PAUSER_ROLE, account, msg.sender);
    }

    /**
     * @dev Revoke pauser role from an account
     * @param account The address to revoke the role from
     */
    function revokePauserRole(address account) public onlyRole(DEFAULT_ADMIN_ROLE) {
        revokeRole(PAUSER_ROLE, account);
        emit RoleRevokedByAdmin(PAUSER_ROLE, account, msg.sender);
    }

    /**
     * @dev Grant admin role to an account
     * @param account The address to grant the role to
     */
    function grantAdminRole(address account) public onlyRole(DEFAULT_ADMIN_ROLE) {
        grantRole(DEFAULT_ADMIN_ROLE, account);
        emit RoleGrantedByAdmin(DEFAULT_ADMIN_ROLE, account, msg.sender);
    }

    /**
     * @dev Revoke admin role from an account
     * @param account The address to revoke the role from
     */
    function revokeAdminRole(address account) public onlyRole(DEFAULT_ADMIN_ROLE) {
        revokeRole(DEFAULT_ADMIN_ROLE, account);
        emit RoleRevokedByAdmin(DEFAULT_ADMIN_ROLE, account, msg.sender);
    }

    /**
     * @dev Check if an address has admin role
     * @param account The address to check
     * @return bool true if the address has admin role
     */
    function isAdmin(address account) public view returns (bool) {
        return hasRole(DEFAULT_ADMIN_ROLE, account);
    }

    /**
     * @dev Check if an address has minter role
     * @param account The address to check
     * @return bool true if the address has minter role
     */
    function isMinter(address account) public view returns (bool) {
        return hasRole(MINTER_ROLE, account);
    }

    /**
     * @dev Check if an address has pauser role
     * @param account The address to check
     * @return bool true if the address has pauser role
     */
    function isPauser(address account) public view returns (bool) {
        return hasRole(PAUSER_ROLE, account);
    }

    /**
     * @dev Override burn to emit custom event
     * @param value The amount of tokens to burn
     */
    function burn(uint256 value) public override {
        super.burn(value);
        emit TokensBurned(msg.sender, value);
    }

    /**
     * @dev Override for Pausable ERC20
     */
    function _update(address from, address to, uint256 value)
        internal
        override(ERC20, ERC20Pausable)
    {
        super._update(from, to, value);
    }
}
