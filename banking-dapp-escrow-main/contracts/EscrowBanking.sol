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
        uint64  deadline;       // optional (epoch seconds)
        EscrowStatus status;
    }

    address public bank;        // arbiter
    uint256 public nextId;
    mapping(uint256 => Escrow) public escrows;

    event EscrowCreated(
        uint256 indexed id,
        address indexed sender,
        address indexed receiver,
        uint256 amount,
        uint64 deadline,
        bytes32 evidenceHash
    );
    event Funded(uint256 indexed id, address indexed sender, uint256 amount);
    event Released(uint256 indexed id, address indexed bank, address indexed receiver, uint256 amount);
    event Refunded(uint256 indexed id, address indexed bank, address indexed sender, uint256 amount);
    event Cancelled(uint256 indexed id, address indexed sender);

    modifier onlyBank() {
        require(msg.sender == bank, "Only bank");
        _;
    }

    modifier onlySender(uint256 id) {
        require(msg.sender == escrows[id].sender, "Only sender");
        _;
    }

    constructor(address _bank) {
        require(_bank != address(0), "bank required");
        bank = _bank;
    }

    /// @notice Create a new escrow
    /// @param _receiver Receiver wallet
    /// @param _deadline Optional deadline (epoch seconds; 0 if unused)
    /// @param _evidenceHash keccak256 hash of off-chain proof (invoice, PoD, etc.)
    function createEscrow(
        address payable _receiver,
        uint64 _deadline,
        bytes32 _evidenceHash
    ) external returns (uint256 id) {
        require(_receiver != address(0), "receiver required");
        id = nextId++;
        escrows[id] = Escrow({
            sender: payable(msg.sender),
            receiver: _receiver,
            amount: 0,
            evidenceHash: _evidenceHash,
            deadline: _deadline,
            status: EscrowStatus.Created
        });
        emit EscrowCreated(id, msg.sender, _receiver, 0, _deadline, _evidenceHash);
    }

    /// @notice Sender funds the escrow (one-time)
    function fund(uint256 id) external payable onlySender(id) {
        Escrow storage e = escrows[id];
        require(e.status == EscrowStatus.Created, "not creatable");
        require(msg.value > 0, "amount > 0");
        e.amount = msg.value;
        e.status = EscrowStatus.Funded;
        emit Funded(id, msg.sender, msg.value);
    }

    /// @notice Bank releases funds to the receiver
    function release(uint256 id) external onlyBank {
        Escrow storage e = escrows[id];
        require(e.status == EscrowStatus.Funded, "not funded");
        e.status = EscrowStatus.Released;
        (bool ok, ) = e.receiver.call{value: e.amount}("");
        require(ok, "transfer failed");
        emit Released(id, msg.sender, e.receiver, e.amount);
    }

    /// @notice Bank refunds funds to the sender
    function refund(uint256 id) external onlyBank {
        Escrow storage e = escrows[id];
        require(e.status == EscrowStatus.Funded, "not funded");
        e.status = EscrowStatus.Refunded;
        (bool ok, ) = e.sender.call{value: e.amount}("");
        require(ok, "refund failed");
        emit Refunded(id, msg.sender, e.sender, e.amount);
    }

    /// @notice Sender can cancel before funding
    function cancel(uint256 id) external onlySender(id) {
        Escrow storage e = escrows[id];
        require(e.status == EscrowStatus.Created, "cannot cancel");
        e.status = EscrowStatus.Cancelled;
        emit Cancelled(id, msg.sender);
    }

    /// @notice Change bank arbiter (demo governance)
    function setBank(address _bank) external onlyBank {
        require(_bank != address(0), "bank required");
        bank = _bank;
    }
}
