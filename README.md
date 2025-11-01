# Monad Token - Foundry Project

An ERC20 token implementation with role-based access control (Admin, Minter, Pauser roles).

## Features

- **ERC20 Standard**: Full ERC20 token implementation
- **Role-Based Access Control**: 
  - Admin: Can grant/revoke roles
  - Minter: Can mint new tokens
  - Pauser: Can pause/unpause token transfers
- **Burnable**: Token holders can burn their tokens
- **Pausable**: Admin can pause all token transfers
- **Initial Supply**: 100,000 MONA tokens

## Setup

### Prerequisites

1. Install Foundry:
   ```bash
   curl -L https://foundry.paradigm.xyz | bash
   foundryup
   ```

2. Install dependencies:
   ```bash
   forge install
   ```

### Build

```bash
forge build
```

### Test

```bash
forge test
forge test -vvv  # For verbose output
```

### Deploy

#### Deploy to local network (Anvil)

1. Start Anvil:
   ```bash
   anvil
   ```

2. Deploy (in another terminal):
   ```bash
   forge script script/Deploy.s.sol --rpc-url localhost --broadcast
   ```

#### Deploy to testnet

1. Create a `.env` file with your private key and RPC URL:
   ```
   PRIVATE_KEY=your_private_key_here
   SEPOLIA_RPC_URL=your_sepolia_rpc_url
   ETHERSCAN_API_KEY=your_etherscan_api_key
   ```

2. Deploy:
   ```bash
   source .env
   forge script script/Deploy.s.sol --rpc-url $SEPOLIA_RPC_URL --broadcast --verify
   ```

## Contract Functions

### Public Functions

- `mint(address to, uint256 amount)` - Mint tokens (Minter role required)
- `burn(uint256 amount)` - Burn your tokens
- `pause()` - Pause all transfers (Pauser role required)
- `unpause()` - Unpause transfers (Pauser role required)
- `grantMinterRole(address account)` - Grant minter role (Admin only)
- `revokeMinterRole(address account)` - Revoke minter role (Admin only)
- `grantPauserRole(address account)` - Grant pauser role (Admin only)
- `revokePauserRole(address account)` - Revoke pauser role (Admin only)

### View Functions

- `balanceOf(address account)` - Get token balance
- `totalSupply()` - Get total supply
- `isAdmin(address account)` - Check if address has admin role
- `isMinter(address account)` - Check if address has minter role
- `isPauser(address account)` - Check if address has pauser role

## Security

- All role management functions are protected by AccessControl
- Only admins can grant/revoke roles
- Only minters can mint new tokens
- Only pausers can pause/unpause the contract

## License

MIT
