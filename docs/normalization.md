# Campus Marketplace: Functional Dependencies and Normalization

## 1. Starting point: one unnormalized sheet

Without a database, the marketplace could be tracked in a single spreadsheet:

```
MARKET( listing_id, title, price, status,
        seller_srn, seller_name, seller_email,
        category_name, parent_category_name,
        { buyer_srn, buyer_name, offered_price, req_status,
          amount, payment_mode } )                 -- repeating group: many requests per listing
```

### Functional dependencies

| # | FD |
|---|----|
| F1 | listing_id → title, price, status, seller_srn, category_name |
| F2 | seller_srn → seller_name, seller_email |
| F3 | seller_email → seller_srn |
| F4 | category_name → parent_category_name |
| F5 | (listing_id, buyer_srn) → offered_price, req_status |
| F6 | buyer_srn → buyer_name |
| F7 | request → amount, payment_mode |

### Inference rules (Armstrong's axioms)

* **Transitivity**: from F1 and F2, listing_id → seller_srn → seller_name, so **listing_id → seller_name**.
* **Transitivity**: from F1 and F4, **listing_id → parent_category_name**.
* **Augmentation**: from F1, (listing_id, buyer_srn) → title. This is a *partial* dependency on the key (listing_id, buyer_srn).
* **Decomposition**: from F2, seller_srn → seller_email.
* **Union**: from F2 and F3, seller_email → seller_srn, seller_name. So seller_email is also a candidate key of the seller data.
* Closure: {seller_srn}⁺ = {seller_srn, seller_name, seller_email}.

## 2. 1NF: remove the repeating group

Every attribute must be atomic, so each request becomes its own row:

```
MARKET_1NF( listing_id, buyer_srn, title, price, status, seller_srn, seller_name, seller_email,
            category_name, parent_category_name, buyer_name, offered_price, req_status,
            amount, payment_mode )
key = (listing_id, buyer_srn)
```

## 3. 2NF: remove partial dependencies

`title`, `price`, `seller_*` and `category_*` depend on **listing_id only**, which is part of the key.
This is a partial dependency, so those attributes move into their own relation:

```
LISTING_2NF ( listing_id, title, price, status, seller_srn, seller_name, seller_email,
              category_name, parent_category_name )
REQUEST_2NF ( request_id, listing_id, buyer_srn, buyer_name, offered_price, req_status,
              amount, payment_mode )
```

## 4. 3NF: remove transitive dependencies

* listing_id → seller_srn → seller_name, seller_email. Seller data moves to
  **USERS(user_id, srn, name, email, ...)**, and the listing keeps `seller_id` as an FK.
* listing_id → category_name → parent_category_name. This moves to
  **CATEGORY(category_id, name, parent_category_id)**.
* request_id → buyer_srn → buyer_name. `buyer_id` becomes an FK to USERS.
* request_id → amount, payment_mode, but only for completed deals (otherwise NULL). These move to
  **TRANSACTIONS(transaction_id, request_id UNIQUE, amount, payment_mode, ...)**.

## 5. BCNF: every determinant is a candidate key

| Relation | Non-trivial FDs | Candidate keys | BCNF? |
|---|---|---|---|
| users | user_id → \*, srn → \*, email → \* | {user_id}, {srn}, {email} | ✔ |
| category | category_id → \*, name → \* | {category_id}, {name} | ✔ |
| listing | listing_id → \* | {listing_id} | ✔ |
| purchase_request | request_id → \* | {request_id} | ✔ |
| transactions | transaction_id → \*, request_id → \* | {transaction_id}, {request_id} | ✔ |
| review | review_id → \*, (transaction_id, reviewer_id) → \* | {review_id}, {transaction_id, reviewer_id} | ✔ |
| audit_log | log_id → \* | {log_id} | ✔ |

**Derived data is not stored.** A seller's average rating is computed by `fn_user_rating()` instead of being
kept as a column in `users`. A stored copy would have to be updated with every new review, which is an
update anomaly.

## 6. Higher normal forms

* **4NF.** A listing has many requests and each deal can have many reviews. These independent multivalued
  facts are kept in separate relations (`purchase_request`, `review`), so there are no multivalued
  dependencies other than those implied by keys.
* **5NF.** No relation has a join dependency that is not implied by its candidate keys.

## 7. Lossless join and dependency preservation

Every decomposition step splits a relation into R1 and R2 where R1 ∩ R2 is a key of one side
(for example USERS ∩ LISTING = {user_id}, the key of USERS), so every step is **lossless**.
Each FD F1–F7 can be checked inside one of the final relations, so the dependencies are **preserved**.
