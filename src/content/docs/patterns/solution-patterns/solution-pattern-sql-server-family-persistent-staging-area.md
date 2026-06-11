---
title: "Solution Pattern - SQL Server Family - Persistent Staging Area"
---

## Purpose

This Solution Pattern shows how to load a Persistent Staging Area (PSA) data object from the Landing Area with a single, set-based, insert-only SQL statement. It is a metadata-driven implementation of the [Design Pattern - Generic - Persistent Staging Area](/patterns/design-patterns/design-pattern-generic-persistent-staging-area/).

## Motivation

The PSA records every change presented to the data solution, in arrival order, without ever updating or deleting. The load must therefore do three things reliably: never reprocess what has already been recorded, never record a non-change, and preserve the arrival order of genuine changes — all while remaining safe to re-run.

## Applicability

This pattern applies to SQL-based PSA loads from a Landing Area that delivers a data delta with the staging layer's standard attributes (inscription timestamp, inscription record identifier, change data indicator, and checksum). The same template serves every PSA object, with the object names and key columns supplied by the solution metadata.

## Structure

The statement inserts the Landing Area records that represent genuine changes:

* A `LEFT OUTER JOIN` against the target PSA on the natural key, inscription timestamp, and inscription record identifier prevents reprocessing records that have already been loaded.
* A second lookup retrieves the most recently arrived PSA record per key that is not logically deleted, supplying the checksum and change data indicator to compare against.
* A `ROW_NUMBER` per natural key establishes the arrival order of the incoming records.
* The change-merging filter keeps the first incoming record per key only when it differs from the PSA's current state — by checksum, or by change data indicator when the checksums match — and keeps all later incoming records as-is, since they follow a record that was just established as a change.

The generic template:

```sql file=<rootDir>/patterns/solution-patterns/solution-pattern-sql-server-family-persistent-staging-area-snippet-1.sql
```

A worked, runnable example for the FastChangeCo case:

```sql file=<rootDir>/patterns/solution-patterns/solution-pattern-sql-server-family-persistent-staging-area-snippet-2.sql
```

## Implementation guidelines

* Generate the statement from metadata: the Landing Area and PSA object names, the natural key, and the attribute columns are supplied by the solution metadata.
* Guard against reprocessing on the full logical key — natural key, inscription timestamp, and inscription record identifier — so reruns of the same batch are harmless.
* Compare only the first incoming record per key against the PSA's current state; later records in the same batch are by definition new history.
* Use the checksum for change detection across the attributes, and keep the change data indicator in the comparison so a delete followed by a re-insert of identical values is still recorded.
* Exclude logically deleted records from the comparison baseline, so a key that re-appears after a delete is recorded as a new change.

## Considerations and consequences

* The load is insert-only and idempotent: it can run continuously and in parallel with downstream processing, in line with the PSA's role as a transaction log.
* Change detection depends on a consistent checksum definition; differences in trimming, formatting, or `NULL` handling produce false changes or missed changes.
* The most-recent-record lookup reads the target PSA per key. On large PSA objects, indexing on the natural key and inscription columns keeps this efficient.

## Related patterns

* [Design Pattern - Generic - Persistent Staging Area](/patterns/design-patterns/design-pattern-generic-persistent-staging-area/)
* [Solution Pattern - SQL Server Family - Landing Area](/patterns/solution-patterns/solution-pattern-sql-server-family-landing-area/)
* [Solution Pattern - SQL Server Family - Data Vault Satellite](/patterns/solution-patterns/solution-pattern-sql-server-family-data-vault-satellite/)
* [Design Pattern - Generic - Using Checksums for Row Comparison](/patterns/design-patterns/design-pattern-generic-using-checksums/)
