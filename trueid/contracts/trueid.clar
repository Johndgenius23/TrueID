;; Decentralized Identity Verification Smart Contract
;; Define the contract owner
(define-constant contract-owner 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM) ;; Replace with your address
;; Map to store user identities
(define-map identities principal {
    name: (string-utf8 100),
    email: (string-utf8 100),
    verified: bool
})
;; Error codes
(define-constant ERR_UNAUTHORIZED (err u1001))
(define-constant ERR_ALREADY_REGISTERED (err u1002))
(define-constant ERR_NOT_FOUND (err u1003))
;; Function to register identity
(define-public (register-identity (user-name (string-utf8 100)) (user-email (string-utf8 100)))
    (begin
        ;; Check if the caller already has an identity
        (asserts! (is-none (map-get? identities tx-sender)) ERR_ALREADY_REGISTERED)
       
        ;; Store the identity
        (map-set identities tx-sender { name: user-name, email: user-email, verified: false })
       
        ;; Return success
        (ok true)
    )
)
;; Function to verify identity (only callable by contract owner)
(define-public (verify-identity (target-user principal))
    (begin
        ;; Ensure only the contract owner can verify identities
        (asserts! (is-eq tx-sender contract-owner) ERR_UNAUTHORIZED)
       
        ;; Check if the user exists
        (asserts! (is-some (map-get? identities target-user)) ERR_NOT_FOUND)
       
        ;; Update the verified status
        (map-set identities target-user (merge (unwrap! (map-get? identities target-user) ERR_NOT_FOUND) { verified: true }))
       
        ;; Return success
        (ok true)
    )
)
;; Function to get identity information
(define-read-only (get-identity (target-user principal))
    (begin
        ;; Fetch the identity
        (match (map-get? identities target-user)
            identity (ok identity)
            (err ERR_NOT_FOUND)
        )
    )
)
;; Function to delete identity (only callable by the user)
(define-public (delete-identity)
    (begin
        ;; Ensure the caller has an identity
        (asserts! (is-some (map-get? identities tx-sender)) ERR_NOT_FOUND)
       
        ;; Delete the identity
        (map-delete identities tx-sender)
       
        ;; Return success
        (ok true)
    )
)