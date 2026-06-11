---
title: "Solution Pattern - SQL Server Family - Data Vault Hub"
---

## Purpose

This Solution Pattern shows how to load a Data Vault Hub table with a single, set-based SQL statement. It is a metadata-driven implementation of the [Design Pattern - Data Vault - Hub](/patterns/design-patterns/design-pattern-data-vault-hub/).

## Motivation

The Hub stores the unique business keys that identify a Core Business Concept, such as customers, products, or orders. Loading a Hub is an insert-only process: each business key is recorded once, the first time it is encountered, and never changes afterwards. Implementing this as one set-based statement keeps the process modular, repeatable, and easy to generate from solution metadata.

## Applicability

This pattern applies to SQL-based Hub loads in the integration layer, where business keys are selected from a Persistent Staging Area (or Landing Area) and inserted into the target Hub if they are not yet present. The example uses a natural business key style surrogate key — a delimited concatenation of the business key — but the same structure supports hash or integer key distribution.

## Structure

The statement inserts the business keys that do not yet exist in the target Hub, keeping the earliest arrival per key:

* The innermost query selects the business key and inscription timestamp from the source, with a key lookup (`LEFT OUTER JOIN` against the target Hub) so that only keys not yet present are selected. Records without a business key are excluded.
* A `ROW_NUMBER` window function partitions by business key and orders by inscription timestamp, establishing the arrival order of each key.
* The outer filter keeps only the first arrival (`Arrival_Order = 1`), so a key that appears multiple times in the source is inserted once, with its earliest inscription timestamp.
* The surrogate key is derived from the business key: the value is trimmed, converted to a consistent string representation, protected against `NULL` with a sentinel value, and suffixed with a delimiter.

```sql file=<rootDir>/patterns/solution-patterns/solution-pattern-sql-server-family-data-vault-hub-snippet-1.sql
```

## Implementation guidelines

* Generate the statement from metadata: the source and target data object names, the business key mapping, and the surrogate key definition are supplied by the solution metadata, so the same template serves every Hub load.
* Standardise the surrogate key derivation — trimming, data type conversion, `NULL` sentinel, and delimiter — across the entire solution, so that every process that references the same business key produces the same key value.
* Keep the process insert-only. Existing keys are filtered out by the key lookup, so the statement can be re-run safely.
* Retain the earliest inscription timestamp per business key. The `ROW_NUMBER` approach shown here achieves this; a `MIN` with `GROUP BY` is an equivalent alternative.
* Source the audit trail identifier from the data logistics control framework. The example uses a placeholder value of `0`; in a metadata-generated process this is supplied by the framework at runtime.
* When multiple sources load the same Hub, deploy one process per source. The processes are identical except for the business key mapping, and can run in parallel provided duplicate-insert protection is in place.

## Considerations and consequences

* The natural business key style surrogate (a delimited string) keeps the key human-readable and avoids a lookup or hashing step, at the cost of wider keys. Hash keys or integer sequences can be substituted without changing the statement structure.
* The `NULL` sentinel guards the surrogate key derivation, but the example also excludes records without a business key. Decide deliberately whether keyless records should be excluded or captured under a dedicated zero key.
* Concurrent processes loading the same Hub can attempt to insert the same key at the same time. The key lookup alone does not protect against this race; database-level constraints or process orchestration must guarantee uniqueness.
* The key lookup reads the full target Hub on each run. Hubs are narrow tables, so this is rarely a problem, but indexing the business key column keeps the lookup efficient as the Hub grows.

## Related patterns

* [Design Pattern - Data Vault - Hub](/patterns/design-patterns/design-pattern-data-vault-hub/)
* [Design Pattern - Logical - Core Business Concept](/patterns/design-patterns/design-pattern-logical-core-business-concept/)
