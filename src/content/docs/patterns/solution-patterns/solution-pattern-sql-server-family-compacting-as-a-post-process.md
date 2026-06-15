---
title: "Solution Pattern - SQL Server Family - Compacting as a Post-Process"
---

## Purpose

This Solution Pattern shows how to remove redundant records from already-stored time-variant data in a single set-based pass — rows whose values are identical to the preceding record for the same key, and therefore represent no actual change. This is record condensing applied as a post-process.

## Motivation

After loading — for example into the Persistent Staging Area — or after combining data objects, a data set can contain consecutive records that carry no genuine change: the same values and the same change data indicator, separated only by a later timestamp. These rows add storage and obscure the real change history without conveying anything.

Because the data is already stored, the column scope and the timeline order are both known. That makes it possible to identify the redundant rows by comparing each record with its predecessor and remove them in one pass, without re-deriving anything.

Unlike [Functional Compacting](/patterns/solution-patterns/solution-pattern-sql-server-family-functional-compacting/), which reduces a timeline by a rule about *time* and can discard real changes, this pattern removes **only** rows that represent no change at all — so it is lossless with respect to meaningful history.

## Applicability

This pattern applies to SQL-based, stored time-variant data objects (the PSA in particular) where redundant no-change records should be removed after the fact. The same checksum comparison can also be expressed as a filter over a query result when a non-destructive form is required.

## Structure

The statement compares each record with the previous one for the same key and deletes the duplicates:

* A CTE computes a checksum over the business key and the tracked columns, using the solution's standard derivation (trim, convert, `NULL` sentinel, delimiter, `HASHBYTES`).
* `LAG` over the checksum and the change data indicator, partitioned by key and ordered by key and timestamp, fetches the value of the preceding record.
* A row is redundant — and is deleted — when both its checksum and its change data indicator equal those of the preceding record. The first record per key has no predecessor (`LAG` returns `NULL`) and is always kept.

```sql file=<rootDir>/patterns/solution-patterns/solution-pattern-sql-server-family-compacting-as-a-post-process-snippet-1.sql
```

To use this non-destructively over a result set, keep the inverse condition instead of deleting: retain rows where the checksum or the change data indicator differs from the preceding record (or where there is no predecessor).

## Implementation guidelines

* Generate the checksum from metadata: the business key and tracked columns, with trimming, conversion, `NULL` sentinel, delimiter, and hash algorithm identical to the rest of the solution, so the same definition of "no change" is applied everywhere.
* Keep the change data indicator in the comparison: a record whose values match the previous one but whose indicator differs (for example, a logical delete followed by a re-insert of identical values) is a genuine change and must be retained.
* Order strictly by key and timestamp so each record is compared with its true predecessor; add a tie-breaker (such as the inscription record identifier) when timestamps are not unique per key.
* Index the key and timestamp columns supporting the `LAG` partition and order.
* For a non-destructive context, apply the inverse filter as a `SELECT` rather than a `DELETE`, so the source remains intact and the condensed set is produced on read.

## Considerations and consequences

* The `DELETE` form is **destructive**: it removes rows from the stored object in place. Run it only where the object is itself derived and reproducible, or retain the source of truth elsewhere.
* It is **lossless with respect to change**: only rows that represent no change are removed, so the meaningful history is preserved exactly. This is the key difference from functional compacting.
* Correctness depends on a consistent checksum. Differences in trimming, formatting, or `NULL` handling produce false matches (real changes removed) or false differences (redundancy retained).
* The window functions pass over the full object; on large data sets, ensure the supporting indexes exist and consider batching the delete.

## Related patterns

* [Solution Pattern - SQL Server Family - Functional Compacting](/patterns/solution-patterns/solution-pattern-sql-server-family-functional-compacting/) — the complementary approach: reducing a timeline by a rule about time, rather than removing only unchanged rows.
* [Design Pattern - Generic - Loading Landing Area Tables Using Record Condensing](/patterns/design-patterns/design-pattern-generic-loading-landing-area-tables-using-row-compacting/)
* [Design Pattern - Generic - Using Checksums for Row Comparison](/patterns/design-patterns/design-pattern-generic-using-checksums/)
* [Solution Pattern - SQL Server Family - Persistent Staging Area](/patterns/solution-patterns/solution-pattern-sql-server-family-persistent-staging-area/)
