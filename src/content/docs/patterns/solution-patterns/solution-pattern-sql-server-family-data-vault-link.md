---
title: "Solution Pattern - SQL Server Family - Data Vault Link"
---

## Purpose

This Solution Pattern shows how to load a Data Vault Link table with a single, set-based SQL statement. It is a metadata-driven implementation of the [Design Pattern - Natural Business Relationship](/patterns/design-patterns/design-pattern-logical-natural-business-relationship/).

## Motivation

The Link records the Natural Business Relationships between Core Business Concepts: the combinations of business keys that occur together, such as a customer purchasing a product in a sale. Like the Hub, the Link is insert-only — each unique combination of keys is recorded once, the first time it is encountered. Implementing this as one set-based statement keeps the process modular, repeatable, and easy to generate from solution metadata.

## Applicability

This pattern applies to SQL-based Link loads in the integration layer, where the distinct combinations of business keys are selected from a Persistent Staging Area (or Landing Area) and inserted into the target Link if the combination is not yet present. The example uses hash-based surrogate keys (`HASHBYTES` with SHA1), but the same structure supports natural business key or integer key distribution.

## Structure

The statement inserts the key combinations that do not yet exist in the target Link:

* The innermost query selects the distinct combinations of business keys that participate in the relationship from the source.
* For each participating Core Business Concept, the corresponding Hub surrogate key is derived using the standard key derivation: the business key value is trimmed, converted to a consistent string representation, protected against `NULL` with a sentinel value, suffixed with a delimiter, and hashed.
* The Link surrogate key is derived the same way, from the concatenation of all participating business keys in a fixed order.
* A `NOT EXISTS` lookup against the target Link filters out combinations that have already been recorded, so the statement can be re-run safely.

```sql file=<rootDir>/patterns/solution-patterns/solution-pattern-sql-server-family-data-vault-link-snippet-1.sql
```

## Implementation guidelines

* Generate the statement from metadata: the source and target data object names, the participating business keys, and their order in the Link key derivation are supplied by the solution metadata, so the same template serves every Link load.
* Keep the key derivation — trimming, data type conversion, `NULL` sentinel, delimiter, and hash algorithm — identical to the derivation used in the corresponding Hub loads, so the Link's foreign keys always match the Hub surrogate keys.
* Fix the order of the business keys in the Link key derivation. Changing the order changes the hash, which would silently create duplicate relationships.
* Keep the process insert-only. The `NOT EXISTS` lookup makes the statement idempotent across reruns.
* Source the audit trail identifier from the data logistics control framework. The example uses a placeholder value of `0`; in a metadata-generated process this is supplied by the framework at runtime.

## Considerations and consequences

* The Link records that a relationship has been observed, not when it was valid or whether it still exists. Context and end-dating for a relationship are managed in associated Satellites.
* Hash-based keys keep the Link narrow and allow independent, parallel loading of Hubs and Links, at the cost of a (theoretical) collision risk and reduced readability. Hash inputs must be standardised — case, trimming, and formatting differences produce different hashes for the same logical key.
* Concurrent processes loading the same Link can attempt to insert the same combination at the same time. The `NOT EXISTS` lookup alone does not protect against this race; database-level constraints or process orchestration must guarantee uniqueness.
* A `DISTINCT` over the source pushes the deduplication work to the database. On large data sets, verify that this is acceptable, or deduplicate earlier in the data logistics.

## Related patterns

* [Design Pattern - Natural Business Relationship](/patterns/design-patterns/design-pattern-logical-natural-business-relationship/)
* [Design Pattern - Logical - Core Business Concept](/patterns/design-patterns/design-pattern-logical-core-business-concept/)
* [Solution Pattern - SQL Server Family - Data Vault Hub](/patterns/solution-patterns/solution-pattern-sql-server-family-data-vault-hub/)
