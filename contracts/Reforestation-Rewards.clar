(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_UNAUTHORIZED (err u100))
(define-constant ERR_INVALID_TREE (err u101))
(define-constant ERR_ALREADY_VERIFIED (err u102))
(define-constant ERR_NOT_FOUND (err u103))
(define-constant ERR_INSUFFICIENT_FUNDS (err u104))
(define-constant ERR_INVALID_AMOUNT (err u105))
(define-constant ERR_INVALID_LOCATION (err u106))
(define-constant ERR_VERIFICATION_FAILED (err u107))

(define-data-var next-tree-id uint u1)
(define-data-var reward-per-tree uint u100)
(define-data-var verification-threshold uint u3)
(define-data-var contract-balance uint u0)
(define-data-var total-trees-planted uint u0)
(define-data-var total-rewards-distributed uint u0)

(define-map trees
    uint
    {
        planter: principal,
        species: (string-ascii 50),
        location: (string-ascii 100),
        planted-at: uint,
        verified: bool,
        verification-count: uint,
        reward-claimed: bool,
    }
)

(define-map user-stats
    principal
    {
        trees-planted: uint,
        trees-verified: uint,
        total-rewards: uint,
        reputation-score: uint,
    }
)

(define-map verifiers
    principal
    {
        verified-trees: uint,
        reputation: uint,
        is-active: bool,
    }
)

(define-map tree-verifications
    {
        tree-id: uint,
        verifier: principal,
    }
    {
        verified-at: uint,
        verification-notes: (string-ascii 200),
    }
)

(define-public (plant-tree
        (species (string-ascii 50))
        (location (string-ascii 100))
    )
    (let (
            (tree-id (var-get next-tree-id))
            (planter tx-sender)
            (current-block burn-block-height)
        )
        (asserts! (> (len species) u0) ERR_INVALID_TREE)
        (asserts! (> (len location) u0) ERR_INVALID_LOCATION)
        (map-set trees tree-id {
            planter: planter,
            species: species,
            location: location,
            planted-at: current-block,
            verified: false,
            verification-count: u0,
            reward-claimed: false,
        })
        (map-set user-stats planter
            (merge
                (default-to {
                    trees-planted: u0,
                    trees-verified: u0,
                    total-rewards: u0,
                    reputation-score: u0,
                }
                    (map-get? user-stats planter)
                ) { trees-planted: (+
                (get trees-planted
                    (default-to {
                        trees-planted: u0,
                        trees-verified: u0,
                        total-rewards: u0,
                        reputation-score: u0,
                    }
                        (map-get? user-stats planter)
                    ))
                u1
            ) }
            ))
        (var-set next-tree-id (+ tree-id u1))
        (var-set total-trees-planted (+ (var-get total-trees-planted) u1))
        (ok tree-id)
    )
)

(define-public (verify-tree
        (tree-id uint)
        (notes (string-ascii 200))
    )
    (let (
            (tree (unwrap! (map-get? trees tree-id) ERR_NOT_FOUND))
            (verifier tx-sender)
            (current-block burn-block-height)
        )
        (asserts! (not (is-eq (get planter tree) verifier)) ERR_UNAUTHORIZED)
        (asserts!
            (is-none (map-get? tree-verifications {
                tree-id: tree-id,
                verifier: verifier,
            }))
            ERR_ALREADY_VERIFIED
        )
        (map-set tree-verifications {
            tree-id: tree-id,
            verifier: verifier,
        } {
            verified-at: current-block,
            verification-notes: notes,
        })
        (let (
                (new-verification-count (+ (get verification-count tree) u1))
                (is-verified (>= new-verification-count (var-get verification-threshold)))
            )
            (map-set trees tree-id
                (merge tree {
                    verification-count: new-verification-count,
                    verified: is-verified,
                })
            )
            (map-set verifiers verifier
                (merge
                    (default-to {
                        verified-trees: u0,
                        reputation: u0,
                        is-active: true,
                    }
                        (map-get? verifiers verifier)
                    ) { verified-trees: (+
                    (get verified-trees
                        (default-to {
                            verified-trees: u0,
                            reputation: u0,
                            is-active: true,
                        }
                            (map-get? verifiers verifier)
                        ))
                    u1
                ) }
                ))
            (map-set user-stats verifier
                (merge
                    (default-to {
                        trees-planted: u0,
                        trees-verified: u0,
                        total-rewards: u0,
                        reputation-score: u0,
                    }
                        (map-get? user-stats verifier)
                    ) { trees-verified: (+
                    (get trees-verified
                        (default-to {
                            trees-planted: u0,
                            trees-verified: u0,
                            total-rewards: u0,
                            reputation-score: u0,
                        }
                            (map-get? user-stats verifier)
                        ))
                    u1
                ) }
                ))
            (ok is-verified)
        )
    )
)

(define-public (claim-reward (tree-id uint))
    (let (
            (tree (unwrap! (map-get? trees tree-id) ERR_NOT_FOUND))
            (claimer tx-sender)
            (reward-amount (var-get reward-per-tree))
        )
        (asserts! (is-eq (get planter tree) claimer) ERR_UNAUTHORIZED)
        (asserts! (get verified tree) ERR_VERIFICATION_FAILED)
        (asserts! (not (get reward-claimed tree)) ERR_ALREADY_VERIFIED)
        (asserts! (>= (var-get contract-balance) reward-amount)
            ERR_INSUFFICIENT_FUNDS
        )
        (try! (as-contract (stx-transfer? reward-amount tx-sender claimer)))
        (map-set trees tree-id (merge tree { reward-claimed: true }))
        (map-set user-stats claimer
            (merge
                (default-to {
                    trees-planted: u0,
                    trees-verified: u0,
                    total-rewards: u0,
                    reputation-score: u0,
                }
                    (map-get? user-stats claimer)
                ) {
                total-rewards: (+
                    (get total-rewards
                        (default-to {
                            trees-planted: u0,
                            trees-verified: u0,
                            total-rewards: u0,
                            reputation-score: u0,
                        }
                            (map-get? user-stats claimer)
                        ))
                    reward-amount
                ),
                reputation-score: (+
                    (get reputation-score
                        (default-to {
                            trees-planted: u0,
                            trees-verified: u0,
                            total-rewards: u0,
                            reputation-score: u0,
                        }
                            (map-get? user-stats claimer)
                        ))
                    u10
                ),
            })
        )
        (var-set contract-balance (- (var-get contract-balance) reward-amount))
        (var-set total-rewards-distributed
            (+ (var-get total-rewards-distributed) reward-amount)
        )
        (ok reward-amount)
    )
)

(define-public (fund-contract (amount uint))
    (begin
        (asserts! (> amount u0) ERR_INVALID_AMOUNT)
        (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))
        (var-set contract-balance (+ (var-get contract-balance) amount))
        (ok amount)
    )
)

(define-public (set-reward-amount (new-amount uint))
    (begin
        (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
        (asserts! (> new-amount u0) ERR_INVALID_AMOUNT)
        (var-set reward-per-tree new-amount)
        (ok new-amount)
    )
)

(define-public (set-verification-threshold (new-threshold uint))
    (begin
        (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
        (asserts! (> new-threshold u0) ERR_INVALID_AMOUNT)
        (var-set verification-threshold new-threshold)
        (ok new-threshold)
    )
)

(define-public (deactivate-verifier (verifier principal))
    (begin
        (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
        (map-set verifiers verifier
            (merge
                (default-to {
                    verified-trees: u0,
                    reputation: u0,
                    is-active: true,
                }
                    (map-get? verifiers verifier)
                ) { is-active: false }
            ))
        (ok true)
    )
)

(define-read-only (get-tree (tree-id uint))
    (map-get? trees tree-id)
)

(define-read-only (get-user-stats (user principal))
    (map-get? user-stats user)
)

(define-read-only (get-verifier-info (verifier principal))
    (map-get? verifiers verifier)
)

(define-read-only (get-tree-verification
        (tree-id uint)
        (verifier principal)
    )
    (map-get? tree-verifications {
        tree-id: tree-id,
        verifier: verifier,
    })
)

(define-read-only (get-contract-stats)
    {
        total-trees: (var-get total-trees-planted),
        total-rewards: (var-get total-rewards-distributed),
        contract-balance: (var-get contract-balance),
        reward-per-tree: (var-get reward-per-tree),
        verification-threshold: (var-get verification-threshold),
        next-tree-id: (var-get next-tree-id),
    }
)

(define-read-only (get-reward-amount)
    (var-get reward-per-tree)
)

(define-read-only (get-contract-balance)
    (var-get contract-balance)
)

(define-read-only (is-tree-verified (tree-id uint))
    (match (map-get? trees tree-id)
        tree (get verified tree)
        false
    )
)
