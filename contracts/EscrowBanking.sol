// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * EscrowBanking: sender -> escrow -> receiver, with a bank (arbiter) that can
 * release or refund funds. Designed for classroom demo with Remix + Ganache + MetaMask.
 *
 * Security notes:
 * - Funds move via .call with checks.
 * - Bank is a single arbiter (demo governance).
 * - Evidence is off-chain; we store its keccak256 hash.
 * - Optional deadline can be used in UI logic (not enforced here for simplicity).
 */
contract EscrowBanking {
    enum EscrowStatus { Created, Funded, Released, Refunded, Cancelled }

    struct Escrow {
        address payable sender;
        address payable receiver;
        uint256 amount;
        bytes32 evidenceHash;   // keccak256 of invoice/proof stored off-chain
        uint6

