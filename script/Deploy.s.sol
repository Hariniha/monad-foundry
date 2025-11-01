// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/MonadToken.sol";

contract DeployScript is Script {
    function run() external returns (MonadToken) {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        
        vm.startBroadcast(deployerPrivateKey);
        
        MonadToken token = new MonadToken();
        
        console.log("MonadToken deployed to:", address(token));
        console.log("Token Name:", token.name());
        console.log("Token Symbol:", token.symbol());
        console.log("Total Supply:", token.totalSupply());
        console.log("Deployer Address:", vm.addr(deployerPrivateKey));
        
        vm.stopBroadcast();
        
        return token;
    }
}
