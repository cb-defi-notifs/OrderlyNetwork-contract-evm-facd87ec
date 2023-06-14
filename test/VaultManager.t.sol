// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../src/VaultManager.sol";
import "../src/Ledger.sol";

contract VaultManagerTest is Test {
    IVaultManager vaultManager;
    ILedger ledger;
    uint256 constant CHAIN_ID = 0xabcd;
    bytes32 constant TOKEN_HASH = 0x61fc29e9a6b4b52b423e75ca44734454f94ea60ddff3dc47af01a2a646fe9572;

    function setUp() public {
        vaultManager = new VaultManager();
        ledger = new Ledger();

        vaultManager.setLedgerAddress(address(ledger));
    }

    function test_sub_add_get() public {
        vm.startPrank(address(ledger));
        vaultManager.addBalance(CHAIN_ID, TOKEN_HASH, 100);
        assertEq(vaultManager.getBalance(CHAIN_ID, TOKEN_HASH), 100);
        vaultManager.addBalance(CHAIN_ID, TOKEN_HASH, 200);
        assertEq(vaultManager.getBalance(CHAIN_ID, TOKEN_HASH), 300);
        vaultManager.subBalance(CHAIN_ID, TOKEN_HASH, 150);
        assertEq(vaultManager.getBalance(CHAIN_ID, TOKEN_HASH), 150);
        vm.stopPrank();
    }

    function testFail_sub_overflow() public {
        vm.startPrank(address(ledger));
        vaultManager.addBalance(CHAIN_ID, TOKEN_HASH, 100);
        assertEq(vaultManager.getBalance(CHAIN_ID, TOKEN_HASH), 100);
        vaultManager.subBalance(CHAIN_ID, TOKEN_HASH, 150);
        vm.stopPrank();
    }
}
