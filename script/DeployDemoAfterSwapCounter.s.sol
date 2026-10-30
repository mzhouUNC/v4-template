// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import {Hooks} from "v4-core/src/libraries/Hooks.sol";
import {HookMiner} from "v4-periphery/src/utils/HookMiner.sol";
import {IPoolManager} from "v4-core/src/interfaces/IPoolManager.sol";
import {DemoAfterSwapCounter} from "../src/DemoAfterSwapCounter.sol";

contract DeployDemoAfterSwapCounter is Script {
    address constant CREATE2_DEPLOYER =
        0x4e59b44847b379578588920cA78FbF26c0B4956C;

    function run() external {
        address poolManager = vm.envAddress("POOLMANAGER");
        uint256 pk = vm.envUint("PRIVATE_KEY");

        uint160 flags = uint160(Hooks.AFTER_SWAP_FLAG);
        bytes memory args = abi.encode(poolManager);

        (address expected, bytes32 salt) =
            HookMiner.find(
                CREATE2_DEPLOYER,
                flags,
                type(DemoAfterSwapCounter).creationCode,
                args
            );

        vm.startBroadcast(pk);
        DemoAfterSwapCounter hook =
            new DemoAfterSwapCounter{salt: salt}(IPoolManager(poolManager));
        vm.stopBroadcast();

        require(address(hook) == expected, "address mismatch");

        console2.log("Hook deployed at:", address(hook));
        console2.log("Salt:", uint256(salt));
    }
}
