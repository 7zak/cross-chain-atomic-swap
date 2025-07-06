;; Test contract for atomic swap functionality
;; This contract provides helper functions and test scenarios

;; Import the main contract (in a real setup, this would be done differently)
;; For now, we'll create test helper functions

;; Test constants
(define-constant TEST-HASH-LOCK 0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef)
(define-constant TEST-PREIMAGE 0xabcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890)
(define-constant TEST-AMOUNT u10000)
(define-constant TEST-TIMELOCK u100)

;; Test helper: Create a test swap
(define-public (create-test-swap (participant principal))
  (contract-call? .atomic-swap initiate-swap
    participant
    TEST-AMOUNT
    TEST-HASH-LOCK
    TEST-TIMELOCK
    "STX"
    "BTC"
    0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef12
    u1  ;; multi-sig-required
    u0  ;; privacy-level
  )
)

;; Test helper: Create a multi-sig swap
(define-public (create-multisig-test-swap (participant principal) (required-sigs uint))
  (contract-call? .atomic-swap initiate-swap
    participant
    TEST-AMOUNT
    TEST-HASH-LOCK
    TEST-TIMELOCK
    "STX"
    "BTC"
    0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef12
    required-sigs
    u0  ;; privacy-level
  )
)

;; Test helper: Create a mixing pool
(define-public (create-test-mixing-pool)
  (contract-call? .atomic-swap create-mixing-pool
    u1000   ;; min-amount
    u50000  ;; max-amount
    u3      ;; activation-threshold
    u10     ;; execution-delay
    u100    ;; execution-window
  )
)

;; Test helper: Join a mixing pool
(define-public (join-test-mixing-pool (pool-id (buff 32)) (amount uint))
  (contract-call? .atomic-swap join-mixing-pool
    pool-id
    amount
    0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef12
  )
)

;; Test scenario: Complete swap flow
(define-public (test-complete-swap-flow (participant principal))
  (let (
    (swap-result (unwrap! (create-test-swap participant) (err u999)))
  )
    ;; Return the swap ID for further testing
    (ok swap-result)
  )
)

;; Test scenario: Multi-sig approval flow
(define-public (test-multisig-flow (participant principal))
  (let (
    (swap-result (unwrap! (create-multisig-test-swap participant u2) (err u999)))
  )
    ;; Approve the swap
    (unwrap! (contract-call? .atomic-swap approve-multi-sig-swap
      swap-result
      0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef12345
    ) (err u998))

    (ok swap-result)
  )
)

;; Test scenario: Mixing pool flow
(define-public (test-mixing-pool-flow)
  (let (
    (pool-result (unwrap! (create-test-mixing-pool) (err u997)))
  )
    ;; Join the pool
    (unwrap! (join-test-mixing-pool pool-result u5000) (err u996))

    (ok pool-result)
  )
)

;; Read-only test helpers
(define-read-only (get-test-constants)
  {
    hash-lock: TEST-HASH-LOCK,
    preimage: TEST-PREIMAGE,
    amount: TEST-AMOUNT,
    timelock: TEST-TIMELOCK
  }
)

;; Verify hash function for testing
(define-read-only (test-hash-verification (preimage (buff 32)) (expected-hash (buff 32)))
  (is-eq (sha256 preimage) expected-hash)
)

;; Test data generator
(define-read-only (generate-test-swap-id (initiator principal) (participant principal))
  (sha256 (concat
    (unwrap-panic (to-consensus-buff? initiator))
    (unwrap-panic (to-consensus-buff? participant))
    (unwrap-panic (to-consensus-buff? stacks-block-height))
    TEST-HASH-LOCK
  ))
)