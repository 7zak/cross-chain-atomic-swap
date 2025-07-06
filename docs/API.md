# API Documentation

## Contract Functions

### Public Functions

#### `initiate-swap`
```clarity
(define-public (initiate-swap 
  (participant principal)
  (amount uint)
  (hash-lock (buff 32))
  (time-lock uint)
  (swap-token (string-ascii 32))
  (target-chain (string-ascii 32))
  (target-address (buff 64))
  (multi-sig-required uint)
  (privacy-level uint)
))
```

Creates a new atomic swap between the caller (initiator) and the specified participant.

**Parameters:**
- `participant`: The principal who can claim this swap
- `amount`: Amount to be swapped (in microunits)
- `hash-lock`: SHA256 hash of the secret preimage
- `time-lock`: Number of blocks before the swap can be refunded
- `swap-token`: Identifier for the token being swapped
- `target-chain`: Target blockchain identifier
- `target-address`: Address on the target blockchain
- `multi-sig-required`: Number of signatures required (1 for simple swaps)
- `privacy-level`: Privacy level (0 = public, higher values for more privacy)

**Returns:**
- Success: `(ok swap-id)` where `swap-id` is a 32-byte buffer
- Error: Various error codes (see Error Codes section)

**Example:**
```clarity
(contract-call? .atomic-swap initiate-swap
  'SP2J6ZY48GV1EZ5V2V5RB9MP66SW86PYKKNRV9EJ7
  u1000000
  0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef
  u144
  "STX"
  "BTC"
  0xabcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890ab
  u1
  u0
)
```

#### `claim-swap`
```clarity
(define-public (claim-swap (swap-id (buff 32)) (preimage (buff 32))))
```

Claims a swap by providing the correct preimage that hashes to the hash-lock.

**Parameters:**
- `swap-id`: Unique identifier of the swap to claim
- `preimage`: The secret that when hashed with SHA256 equals the hash-lock

**Returns:**
- Success: `(ok true)`
- Error: Various error codes

**Validation:**
- Only the designated participant can claim
- Swap must not be already claimed or refunded
- Preimage must hash to the hash-lock
- Swap must not be expired
- Multi-sig requirements must be met (if applicable)

#### `refund-swap`
```clarity
(define-public (refund-swap (swap-id (buff 32))))
```

Refunds an expired swap back to the initiator.

**Parameters:**
- `swap-id`: Unique identifier of the swap to refund

**Returns:**
- Success: `(ok true)`
- Error: Various error codes

**Validation:**
- Only the initiator can refund
- Swap must be expired
- Swap must not be already claimed or refunded

#### `approve-multi-sig-swap`
```clarity
(define-public (approve-multi-sig-swap (swap-id (buff 32)) (signature (buff 65))))
```

Submits a signature approval for a multi-signature swap.

**Parameters:**
- `swap-id`: Unique identifier of the swap
- `signature`: Cryptographic signature (65 bytes)

**Returns:**
- Success: `(ok true)`
- Error: Various error codes

#### `submit-zk-proof`
```clarity
(define-public (submit-zk-proof (swap-id (buff 32)) (proof-data (buff 1024))))
```

Submits a zero-knowledge proof for confidential transaction verification.

**Parameters:**
- `swap-id`: Unique identifier of the swap
- `proof-data`: ZK proof data (up to 1024 bytes)

**Returns:**
- Success: `(ok true)`
- Error: Various error codes

#### `create-mixing-pool`
```clarity
(define-public (create-mixing-pool 
  (min-amount uint) 
  (max-amount uint) 
  (activation-threshold uint)
  (execution-delay uint)
  (execution-window uint)
))
```

Creates a new mixing pool for enhanced privacy.

**Parameters:**
- `min-amount`: Minimum amount required to join the pool
- `max-amount`: Maximum amount allowed in the pool
- `activation-threshold`: Number of participants needed to activate the pool
- `execution-delay`: Number of blocks to wait before execution
- `execution-window`: Number of blocks available for execution after delay

**Returns:**
- Success: `(ok pool-id)` where `pool-id` is a 32-byte buffer
- Error: Various error codes

#### `join-mixing-pool`
```clarity
(define-public (join-mixing-pool (pool-id (buff 32)) (amount uint) (blinded-output-address (buff 64))))
```

Joins an existing mixing pool.

**Parameters:**
- `pool-id`: Unique identifier of the mixing pool
- `amount`: Amount to contribute to the pool
- `blinded-output-address`: Blinded output address for privacy

**Returns:**
- Success: `(ok true)`
- Error: Various error codes

#### `withdraw-from-mixer`
```clarity
(define-public (withdraw-from-mixer (pool-id (buff 32)) (participant-id uint)))
```

Withdraws from an active mixing pool.

**Parameters:**
- `pool-id`: Unique identifier of the mixing pool
- `participant-id`: Participant's ID in the pool

**Returns:**
- Success: `(ok true)`
- Error: Various error codes

### Read-Only Functions

#### `get-swap`
```clarity
(define-read-only (get-swap (swap-id (buff 32))))
```

Retrieves complete swap information.

**Returns:**
- `(some swap-data)` if swap exists
- `none` if swap doesn't exist

#### `get-swap-status`
```clarity
(define-read-only (get-swap-status (swap-id (buff 32))))
```

Gets comprehensive status information for a swap.

**Returns:**
```clarity
{
  exists: bool,
  claimed: bool,
  refunded: bool,
  expired: bool,
  claimable: bool,
  refundable: bool
}
```

#### `is-swap-claimable`
```clarity
(define-read-only (is-swap-claimable (swap-id (buff 32))))
```

Checks if a swap can currently be claimed.

#### `is-swap-refundable`
```clarity
(define-read-only (is-swap-refundable (swap-id (buff 32))))
```

Checks if a swap can currently be refunded.

#### `get-mixing-pool`
```clarity
(define-read-only (get-mixing-pool (pool-id (buff 32))))
```

Retrieves mixing pool information.

#### `get-contract-admin`
```clarity
(define-read-only (get-contract-admin))
```

Returns the current contract administrator.

#### `get-protocol-fee-balance`
```clarity
(define-read-only (get-protocol-fee-balance))
```

Returns the current protocol fee balance.

#### `get-contract-version`
```clarity
(define-read-only (get-contract-version))
```

Returns the contract version string.

## Error Codes

| Code | Constant | Description |
|------|----------|-------------|
| u1 | ERR-UNAUTHORIZED | Caller not authorized for this operation |
| u2 | ERR-SWAP-NOT-FOUND | Swap with given ID doesn't exist |
| u3 | ERR-ALREADY-CLAIMED | Swap has already been claimed |
| u4 | ERR-NOT-CLAIMABLE | Swap cannot be claimed at this time |
| u5 | ERR-TIMELOCK-ACTIVE | Timelock is still active |
| u6 | ERR-TIMELOCK-EXPIRED | Timelock has expired |
| u7 | ERR-INVALID-PROOF | Invalid zero-knowledge proof |
| u8 | ERR-INVALID-SIGNATURE | Invalid signature provided |
| u9 | ERR-INVALID-HASH | Hash verification failed |
| u10 | ERR-INSUFFICIENT-FUNDS | Insufficient funds for operation |
| u11 | ERR-SWAP-EXPIRED | Swap has expired |
| u12 | ERR-INVALID-REFUND | Invalid refund attempt |
| u13 | ERR-INVALID-PARTICIPANT | Invalid participant |
| u14 | ERR-MIXER-NOT-FOUND | Mixing pool not found |
| u15 | ERR-INVALID-FEE | Invalid fee amount |
| u16 | ERR-PARTICIPANT-LIMIT-REACHED | Maximum participants reached |

## Constants

| Constant | Value | Description |
|----------|-------|-------------|
| MAX-TIMEOUT-BLOCKS | u1000 | Maximum timelock duration |
| MIN-SWAP-AMOUNT | u1000 | Minimum swap amount |
| MAX-PARTICIPANTS-PER-MIXER | u10 | Maximum participants per mixing pool |
| MIXER-FEE-PERCENTAGE | u5 | Mixer fee (0.5%) |
| PROTOCOL-FEE-PERCENTAGE | u2 | Protocol fee (0.2%) |
| DEFAULT-QUORUM | u2 | Default multi-sig quorum |
