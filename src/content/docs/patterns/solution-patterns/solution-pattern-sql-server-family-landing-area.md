---
title: "Solution Pattern - SQL Server Family - Landing Area"
---

## Purpose

This Solution Pattern shows how to populate a Landing Area data object with a single, set-based SQL statement that derives the data delta. It is a metadata-driven implementation of the [Design Pattern - Generic - Landing Area](/patterns/design-patterns/design-pattern-generic-landing-area/).

## Motivation

When a source delivers a full or current-state extract rather than a ready-made data delta, the Landing Area process must derive the delta itself. Comparing the incoming data against the most recent state already captured downstream identifies which records are new, changed, or no longer present, so that only genuine changes are carried forward.

## Applicability

This pattern applies to SQL-based Landing Area loads where the data delta is derived by comparison — for example, when no native change data capture is available on the source and a Persistent Staging Area (PSA) holds the most recent committed state to compare against. It assumes a checksum is available to detect changes across the non-key attributes.

## Structure

The statement truncates the Landing Area target and rebuilds the current data delta from two sets:

* LDA - the incoming source data, including its checksum.
* PSA - the most recent, non-deleted record per business key from the Persistent Staging Area.

A `FULL OUTER JOIN` on the business key compares the two sets and derives the change data indicator:

* The key is present in the PSA but not in the source → a logical delete (`'D'`).
* The key is present in the source but not in the PSA → a new record (`'C'`).
* The key is present in both, but the checksums differ → a changed record (`'C'`).
* Otherwise the record is unchanged and is excluded from the result.

Records that represent a change are then inserted into the Landing Area, ready to be committed downstream.

```sql file=<rootDir>/patterns/solution-patterns/solution-pattern-sql-server-family-landing-area-snippet-1.sql
```

## Implementation guidelines

* Generate the statement from metadata: the data object names, business key, attribute columns, and checksum column are supplied by the solution metadata, so the same template serves every Landing Area object.
* Use a checksum across the non-key attributes to detect changes without comparing every column individually.
* Select only the most recent, non-deleted record per key from the PSA as the comparison baseline.
* Use a `FULL OUTER JOIN` so inserts, changes, and logical deletes are all detected in a single pass.
* Apply a truncate-and-insert approach, so each run replaces the previous data delta for the interface.

## Considerations and consequences

* Deriving the delta by full comparison reads the entire source and the most recent PSA state on each run. On large data sets this carries a performance cost compared with a source that already supplies a delta.
* The pattern depends on a reliable checksum. The checksum definition — including how it handles NULLs and concatenation — must be consistent across the solution to avoid missed or false changes.
* Logical deletes are inferred from absence in the source, so the source extract must be complete. A partial extract would incorrectly flag the missing keys as deletes.
* Because the placeholders are filled from metadata, the same pattern is reusable across sources and platforms that support the required SQL constructs.

## Related patterns

* [Design Pattern - Generic - Landing Area](/patterns/design-patterns/design-pattern-generic-landing-area/)
* [Design Pattern - Generic - Using Checksums](/patterns/design-patterns/design-pattern-generic-using-checksums/)
