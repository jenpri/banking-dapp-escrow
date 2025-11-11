Title: Banking Escrow DApp (Remix + Ganache + MetaMask)
Module: Distributed Digital Transactions — Student: Jenny Matarrita Zúñiga (2023104)
Lecturer: Dr. Muhammad Iqbal — Topic: Banking & Financial Services

Problem & Objective
Peer-to-peer payments in traditional banking rely on intermediaries and manual checks, creating delays, limited transparency, and higher costs. This project implements a blockchain-based escrow where a bank acts as arbiter between a sender and a receiver. The goal is a transparent, auditable, and secure payment flow in which funds are locked and only released or refunded based on the arbiter’s decision.

Solution Design
The solution is a Solidity smart contract deployed on an Ethereum-like local network (Ganache) and used through MetaMask. Roles: (1) Sender creates and funds the escrow; (2) Receiver obtains the payment upon confirmation; (3) Bank (arbiter) authorizes release or refund. The contract emits events to build an on-chain audit trail. Off-chain documents (e.g., invoices or proof of delivery) are referenced by their keccak256 hashes to protect sensitive data while preserving verifiability.

Cryptography & Security
Transactions are signed with Ethereum’s ECDSA (secp256k1), ensuring authenticity and non-repudiation. Keccak256 hashing preserves data integrity for evidence stored off-chain. Optionally, EIP-712 typed-data signatures could reduce gas and improve UX by verifying off-chain approvals before an on-chain action. The bank’s role aligns with real-world compliance (KYC/AML) handled outside the chain while the ledger guarantees transparency.

Smart Contract & Procedure
The contract EscrowBanking exposes createEscrow, fund, release, refund, and cancel, plus events for each state transition. Lab steps (Remix + Ganache + MetaMask):

Deploy with the bank’s address as constructor parameter.

Create escrow (sender) with receiver, optional deadline, and evidence hash.

Fund the escrow by sending ETH as Value.

Release (to receiver) or Refund (to sender) by the bank.

Verify events and balances.
Screenshots of each step are included on the poster.

Benefits & Challenges
Benefits: transparent audit trail, fast settlement, reduced intermediaries, and strong cryptographic guarantees.
Challenges: KYC/AML remain off-chain; privacy requires careful data handling; gas costs on public networks; and clear governance for disputes.

Conclusion
The escrow pattern demonstrates how blockchain can complement banking by providing verifiable, event-driven settlement with a minimal, auditable core. This prototype is classroom-ready and portable to testnets or L2s for future work.

References (Harvard)
Nakamoto (2008); Wood (2014); Swan (2015); Antonopoulos (2018); CCT DDT CA1 Brief (2025).

GenAI Declaration
Generative AI (ChatGPT) was used for brainstorming, language polishing, and structuring the poster and code comments. Prompts and outputs are documented in the appendix.
