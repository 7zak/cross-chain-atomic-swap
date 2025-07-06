# Usage Examples

This document provides practical examples of using the Cross-Chain Atomic Swap Protocol.

## Basic Atomic Swap

### Scenario: STX to BTC Swap

Alice wants to swap 1,000,000 microSTX for Bitcoin with Bob.

#### Step 1: Alice generates a secret and hash
```javascript
// Generate a random 32-byte secret
const secret = crypto.randomBytes(32);
const hashLock = crypto.createHash('sha256').update(secret).digest();

console.log('Secret:', secret.toString('hex'));
console.log('Hash Lock:', hashLock.toString('hex'));
```

#### Step 2: Alice initiates the swap
```clarity
;; Alice calls initiate-swap
(contract-call? .atomic-swap initiate-swap
  'SP2J6ZY48GV1EZ5V2V5RB9MP66SW86PYKKNRV9EJ7  ;; Bob's address
  u1000000                                        ;; 1,000,000 microSTX
  0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef  ;; hash-lock
  u144                                            ;; 24 hours (144 blocks)
  "STX"                                           ;; token
  "BTC"                                           ;; target chain
  0xabcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890ab  ;; Bob's BTC address
  u1                                              ;; single signature
  u0                                              ;; public swap
)
```

#### Step 3: Bob verifies and creates corresponding BTC swap
Bob checks the Stacks swap details and creates a corresponding HTLC on Bitcoin using the same hash-lock.

#### Step 4: Alice claims Bob's BTC
Alice uses the secret to claim Bob's Bitcoin.

#### Step 5: Bob claims Alice's STX
```clarity
;; Bob uses Alice's revealed secret to claim STX
(contract-call? .atomic-swap claim-swap
  0x5678...  ;; swap-id from step 2
  0x9abc...  ;; Alice's secret (revealed when she claimed BTC)
)
```

## Multi-Signature Swap

### Scenario: Corporate Treasury Swap

A company wants to perform a large swap requiring multiple approvals.

#### Step 1: Initiate multi-sig swap
```clarity
;; Requires 2 out of 3 signatures
(contract-call? .atomic-swap initiate-swap
  'SP2J6ZY48GV1EZ5V2V5RB9MP66SW86PYKKNRV9EJ7  ;; counterparty
  u10000000                                       ;; 10M microSTX
  0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef
  u288                                            ;; 48 hours
  "STX"
  "ETH"
  0xabcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890ab
  u2                                              ;; requires 2 signatures
  u0
)
```

#### Step 2: First approval
```clarity
;; First authorized signer approves
(contract-call? .atomic-swap approve-multi-sig-swap
  0x5678...  ;; swap-id
  0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef12345  ;; signature
)
```

#### Step 3: Second approval
```clarity
;; Second authorized signer approves
(contract-call? .atomic-swap approve-multi-sig-swap
  0x5678...  ;; swap-id
  0xabcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef  ;; signature
)
```

#### Step 4: Claim with sufficient signatures
Now the swap can be claimed since it has the required 2 signatures.

## Privacy Mixing Pool

### Scenario: Anonymous Transaction Mixing

Multiple users want to mix their transactions for enhanced privacy.

#### Step 1: Create mixing pool
```clarity
;; Create a mixing pool
(contract-call? .atomic-swap create-mixing-pool
  u100000   ;; min 100,000 microSTX
  u1000000  ;; max 1,000,000 microSTX
  u5        ;; needs 5 participants to activate
  u72       ;; 12 hour delay
  u144      ;; 24 hour execution window
)
```

#### Step 2: Users join the pool
```clarity
;; User 1 joins
(contract-call? .atomic-swap join-mixing-pool
  0xpool-id...
  u500000
  0xblinded-address-1...
)

;; User 2 joins
(contract-call? .atomic-swap join-mixing-pool
  0xpool-id...
  u300000
  0xblinded-address-2...
)

;; ... more users join until threshold is reached
```

#### Step 3: Pool activates and users withdraw
After the delay period, users can withdraw anonymously:

```clarity
;; User withdraws after delay
(contract-call? .atomic-swap withdraw-from-mixer
  0xpool-id...
  u0  ;; participant-id
)
```

## Zero-Knowledge Proof Integration

### Scenario: Confidential Swap Amount

Alice wants to prove she has sufficient funds without revealing the exact amount.

#### Step 1: Generate ZK proof off-chain
```javascript
// Pseudocode for ZK proof generation
const proof = generateZKProof({
  statement: "I have at least 1,000,000 microSTX",
  witness: { actualAmount: 2500000, randomness: secret },
  publicInputs: { minAmount: 1000000 }
});
```

#### Step 2: Submit proof to contract
```clarity
;; Submit the ZK proof
(contract-call? .atomic-swap submit-zk-proof
  0xswap-id...
  0xproof-data...  ;; serialized proof (up to 1024 bytes)
)
```

## Error Handling Examples

### Handling Common Errors

```clarity
;; Example of proper error handling
(match (contract-call? .atomic-swap claim-swap swap-id preimage)
  success (begin
    (print "Swap claimed successfully!")
    success
  )
  error (begin
    (if (is-eq error u1)
      (print "Error: Unauthorized - you're not the participant")
      (if (is-eq error u3)
        (print "Error: Swap already claimed")
        (if (is-eq error u9)
          (print "Error: Invalid preimage - hash doesn't match")
          (print "Error: Unknown error occurred")
        )
      )
    )
    error
  )
)
```

### Checking Swap Status Before Operations

```clarity
;; Check if swap is claimable before attempting to claim
(let ((status (contract-call? .atomic-swap get-swap-status swap-id)))
  (if (get claimable status)
    (contract-call? .atomic-swap claim-swap swap-id preimage)
    (err u4)  ;; ERR-NOT-CLAIMABLE
  )
)
```

## Integration with Frontend

### JavaScript/TypeScript Integration

```typescript
import { StacksNetwork, makeContractCall, broadcastTransaction } from '@stacks/transactions';

async function initiateSwap(
  network: StacksNetwork,
  senderKey: string,
  participant: string,
  amount: number,
  hashLock: string,
  timeLock: number
) {
  const txOptions = {
    contractAddress: 'SP2J6ZY48GV1EZ5V2V5RB9MP66SW86PYKKNRV9EJ7',
    contractName: 'atomic-swap',
    functionName: 'initiate-swap',
    functionArgs: [
      standardPrincipalCV(participant),
      uintCV(amount),
      bufferCV(Buffer.from(hashLock, 'hex')),
      uintCV(timeLock),
      stringAsciiCV('STX'),
      stringAsciiCV('BTC'),
      bufferCV(Buffer.from('1234567890abcdef', 'hex')),
      uintCV(1),
      uintCV(0)
    ],
    senderKey,
    network,
    fee: 1000
  };

  const transaction = await makeContractCall(txOptions);
  const broadcastResponse = await broadcastTransaction(transaction, network);
  
  return broadcastResponse;
}
```

## Best Practices

### Security Considerations

1. **Use strong randomness** for secrets and hash-locks
2. **Set appropriate timelocks** - too short risks failed swaps, too long locks funds
3. **Verify counterparty addresses** before initiating swaps
4. **Monitor swap status** throughout the process
5. **Use multi-sig for large amounts**

### Privacy Considerations

1. **Use mixing pools** for enhanced anonymity
2. **Vary timing** of transactions to avoid correlation
3. **Consider ZK proofs** for confidential amounts
4. **Use different addresses** for different swaps

### Operational Considerations

1. **Test on devnet/testnet** before mainnet deployment
2. **Monitor gas fees** and adjust accordingly
3. **Implement proper error handling** in applications
4. **Keep backups** of important transaction data
5. **Plan for network congestion** with appropriate timelocks
