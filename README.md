# Cross-Chain Atomic Swap Protocol

A comprehensive cross-chain atomic swap implementation built on Stacks blockchain with advanced privacy features, multi-signature support, and mixing pools for enhanced anonymity.

## 🌟 Features

- **Hash Time Locked Contracts (HTLC)**: Secure atomic swaps with cryptographic guarantees
- **Multi-Signature Support**: Enhanced security with configurable signature requirements
- **Privacy Mixing Pools**: Anonymous transaction mixing for enhanced privacy
- **Zero-Knowledge Proofs**: Framework for confidential transaction verification
- **Cross-Chain Compatibility**: Support for multiple blockchain networks
- **Fee Management**: Configurable protocol and mixer fees
- **Comprehensive Testing**: Full test suite with edge case coverage
- **Admin Controls**: Governance features for protocol management

## 🏗️ Architecture

The protocol consists of several key components:

### Core Contracts
- `atomic-swap.clar`: Main contract implementing the atomic swap protocol
- `atomic-swap-test.clar`: Test helper contract for development and testing

### Key Features

#### 1. Atomic Swaps
- Trustless cross-chain asset exchanges
- HTLC-based security model
- Configurable timelock periods
- Automatic refund mechanisms

#### 2. Multi-Signature Support
- Configurable signature requirements
- Support for complex approval workflows
- Enhanced security for high-value swaps

#### 3. Privacy Mixing Pools
- Anonymous transaction mixing
- Configurable pool parameters
- Delayed execution for enhanced privacy
- Participant limit controls

#### 4. Zero-Knowledge Proofs
- Framework for confidential transactions
- Proof verification system
- Privacy-preserving swap details

## 🚀 Quick Start

### Prerequisites
- [Clarinet](https://github.com/hirosystems/clarinet) installed
- Node.js and npm/yarn
- Stacks wallet for testnet/mainnet deployment

### Installation

```bash
# Clone the repository
git clone https://github.com/7zak/cross-chain-atomic-swap.git
cd cross-chain-atomic-swap

# Install dependencies (if any)
npm install

# Run tests
clarinet test

# Start local development environment
clarinet integrate
```

### Basic Usage

#### 1. Initialize an Atomic Swap

```clarity
;; Create a new atomic swap
(contract-call? .atomic-swap initiate-swap
  'SP2J6ZY48GV1EZ5V2V5RB9MP66SW86PYKKNRV9EJ7  ;; participant
  u10000                                        ;; amount (10,000 microSTX)
  0x1234...                                     ;; hash-lock
  u144                                          ;; time-lock (144 blocks ≈ 24 hours)
  "STX"                                         ;; swap-token
  "BTC"                                         ;; target-chain
  0xabcd...                                     ;; target-address
  u1                                            ;; multi-sig-required
  u0                                            ;; privacy-level
)
```

#### 2. Claim a Swap

```clarity
;; Claim swap with preimage
(contract-call? .atomic-swap claim-swap
  0x5678...  ;; swap-id
  0x9abc...  ;; preimage
)
```

#### 3. Refund an Expired Swap

```clarity
;; Refund after expiration
(contract-call? .atomic-swap refund-swap
  0x5678...  ;; swap-id
)
```

## 📚 API Reference

### Public Functions

#### `initiate-swap`
Creates a new atomic swap with specified parameters.

**Parameters:**
- `participant`: Principal address of the swap counterparty
- `amount`: Amount to swap (in microunits)
- `hash-lock`: SHA256 hash of the secret preimage
- `time-lock`: Number of blocks before swap expires
- `swap-token`: Token identifier for the swap
- `target-chain`: Target blockchain identifier
- `target-address`: Address on target chain
- `multi-sig-required`: Number of required signatures
- `privacy-level`: Privacy level (0 = public, higher = more private)

**Returns:** `(response (buff 32) uint)` - Swap ID on success

#### `claim-swap`
Claims a swap by providing the correct preimage.

**Parameters:**
- `swap-id`: Unique identifier of the swap
- `preimage`: Secret that hashes to the hash-lock

**Returns:** `(response bool uint)` - Success status

#### `refund-swap`
Refunds an expired swap to the initiator.

**Parameters:**
- `swap-id`: Unique identifier of the swap

**Returns:** `(response bool uint)` - Success status

#### `create-mixing-pool`
Creates a new privacy mixing pool.

**Parameters:**
- `min-amount`: Minimum amount for pool participation
- `max-amount`: Maximum amount for pool participation
- `activation-threshold`: Number of participants needed to activate
- `execution-delay`: Blocks to wait before execution
- `execution-window`: Blocks available for execution

**Returns:** `(response (buff 32) uint)` - Pool ID on success

### Read-Only Functions

#### `get-swap`
Retrieves swap details by ID.

#### `get-swap-status`
Gets comprehensive status information for a swap.

#### `is-swap-claimable`
Checks if a swap can be claimed.

#### `is-swap-refundable`
Checks if a swap can be refunded.

## 🔒 Security Considerations

### Hash Time Locked Contracts (HTLC)
- Use cryptographically secure random preimages
- Ensure sufficient timelock duration for cross-chain operations
- Verify hash-lock matches expected preimage hash

### Multi-Signature Security
- Configure appropriate signature thresholds
- Use trusted signers for multi-sig swaps
- Verify all signatures before claiming

### Privacy Considerations
- Mixing pools provide transaction privacy
- Higher privacy levels may require additional verification
- Consider timing analysis when using privacy features

## 🧪 Testing

The project includes comprehensive tests covering:

- Basic swap functionality
- Multi-signature workflows
- Privacy mixing pools
- Error conditions and edge cases
- Security validations

Run tests with:
```bash
clarinet test
```

## 🚀 Deployment

### Development Network
```bash
clarinet integrate
```

### Testnet Deployment
1. Configure your testnet account in `settings/Testnet.toml`
2. Deploy using Clarinet or Stacks.js
3. Verify deployment with test transactions

### Mainnet Deployment
1. **Security Audit Required**: Ensure thorough security review
2. Configure mainnet settings
3. Deploy with appropriate gas fees
4. Initialize contract parameters

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Add tests for new functionality
4. Ensure all tests pass
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## ⚠️ Disclaimer

This software is provided "as is" without warranty. Use at your own risk. Conduct thorough testing and security audits before using in production environments.
