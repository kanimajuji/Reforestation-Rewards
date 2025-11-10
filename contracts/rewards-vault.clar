(define-trait ft-trait-v1
  (
    (transfer (uint principal principal (optional (buff 34))) (response bool uint))
  )
)

(define-map locks
  { owner: principal, token: principal }
  { amount: uint, unlock-height: uint }
)

(define-read-only (get-lock (owner principal) (token <ft-trait-v1>))
  (let
    (
      (token-principal (contract-of token))
      (key { owner: owner, token: token-principal })
    )
    (map-get? locks key)
  )
)

(define-public (lock (token <ft-trait-v1>) (amount uint) (unlock-height uint))
  (let
    (
      (owner tx-sender)
      (token-principal (contract-of token))
      (key { owner: owner, token: token-principal })
    )
    (asserts! (> amount u0) (err u100))
    (asserts! (> unlock-height burn-block-height) (err u101))
    (asserts! (is-none (map-get? locks key)) (err u102))
    (try! (contract-call? token transfer amount owner (as-contract tx-sender) none))
    (map-set locks key { amount: amount, unlock-height: unlock-height })
    (ok true)
  )
)

(define-public (unlock (token <ft-trait-v1>))
  (let
    (
      (owner tx-sender)
      (token-principal (contract-of token))
      (key { owner: owner, token: token-principal })
      (lock-record (unwrap! (map-get? locks key) (err u200)))
      (amount (get amount lock-record))
      (unlock-h (get unlock-height lock-record))
    )
    (asserts! (> amount u0) (err u202))
    (asserts! (>= burn-block-height unlock-h) (err u201))
    (try! (as-contract (contract-call? token transfer amount tx-sender owner none)))
    (map-delete locks key)
    (ok true)
  )
)
