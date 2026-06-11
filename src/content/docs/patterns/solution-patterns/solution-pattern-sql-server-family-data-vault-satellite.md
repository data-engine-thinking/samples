---
title: "Solution Pattern - SQL Server Family - Data Vault Satellite"
---

## Purpose

This Solution Pattern shows how to load a Data Vault Satellite with set-based SQL, covering the preparation of the incoming data delta and both unitemporal and bitemporal loading. It is a metadata-driven implementation of the [Design Pattern - Data Vault - Satellite](/patterns/design-patterns/design-pattern-data-vault-satellite/).

## Motivation

The Satellite stores the descriptive context for a Core Business Concept or Natural Business Relationship, and tracks how that context changes over time. Loading a Satellite is more involved than loading a Hub or Link: the incoming data must be prepared into a clean change set, compared against what is already recorded, and inserted in a way that preserves the timeline. Structuring this as a small number of set-based, metadata-generated statements keeps the process repeatable across every Satellite in the solution.

## Applicability

This pattern applies to SQL-based Satellite loads in the integration layer. The unitemporal form applies when history is tracked by inscription timestamp only; the bitemporal form applies when an additional state timeline (state from / state before timestamps) is maintained, and incoming records can affect time periods that are already recorded.

## Structure

The Satellite load consists of a preparation step followed by the load itself.

### Preparing the data delta

The incoming data is shaped into a clean change set before it is compared against the target. The inner selection gathers the records and derives the supporting attributes (surrogate key, checksum, change data indicator); a compacting preparation and filter then remove records that do not represent a genuine change, so only meaningful changes are carried forward:

```sql file=<rootDir>/patterns/solution-patterns/solution-pattern-sql-server-family-data-vault-satellite-snippet-1.sql
```

### Loading a unitemporal Satellite

The unitemporal load inserts the prepared changes that are not yet recorded in the target Satellite:

* A `LEFT OUTER JOIN` on the surrogate key, inscription timestamp, and inscription record identifier prevents reprocessing of records that have already been loaded.
* A `ROW_NUMBER` per surrogate key establishes the order of the incoming changes.
* The most recent incoming change per key (`KEY_ROW_NUMBER = 1`) is compared against the current record in the target — by checksum, and by change data indicator when the checksums match — so an unchanged record is not inserted again.
* Older incoming changes (`KEY_ROW_NUMBER != 1`) are inserted as-is, since they precede the change that was just evaluated.

```sql file=<rootDir>/patterns/solution-patterns/solution-pattern-sql-server-family-data-vault-satellite-snippet-2.sql
```

### Loading a bitemporal Satellite

The bitemporal load additionally maintains the state timeline. An incoming record can overlap time periods that are already recorded, in which case the existing records must be split so the timeline remains continuous:

* The `NewRecords` set contains the prepared changes, guarded against reprocessing.
* Existing records that overlap an incoming record on the state timeline are identified using their interval relationships.
* For each overlap, the existing record is duplicated to preserve the portion of its period to the right and to the left of the incoming change, with the state from / state before timestamps adjusted accordingly.
* The final insert combines the new records with the preserved left and right portions of the affected existing records.

```sql file=<rootDir>/patterns/solution-patterns/solution-pattern-sql-server-family-data-vault-satellite-snippet-3.sql
```

## Implementation guidelines

* Generate the statements from metadata: the data object names, surrogate key, attribute columns, checksum definition, and temporal columns are supplied by the solution metadata, so the same templates serve every Satellite.
* Use a checksum across the descriptive attributes to detect changes without comparing every column individually, and keep the checksum definition consistent across the solution.
* Keep the change data indicator in the comparison: when checksums match but the indicator differs (for example, a delete followed by a re-insert of identical values), the record still represents a change.
* Compare only the most recent incoming change per key against the target. Earlier changes in the same batch are by definition new history and can be inserted directly — this is what the `ROW_NUMBER` split achieves.
* Guard against reprocessing on the full logical key (surrogate key, inscription timestamp, inscription record identifier), so reruns of the same batch do not duplicate records.
* For bitemporal loads, derive the timeline adjustments deterministically from the interval relationships between incoming and existing records, and only keep the most recent duplicate per affected period (`rownum = 1`).
* End-dating (deriving the state before timestamp from the following record) can be maintained as part of the load or derived afterwards; either way, derive it consistently.

## Considerations and consequences

* The Satellite is insert-only: changes, including logical deletes, are recorded as new records. Corrections to the timeline in the bitemporal form are also implemented as inserts of adjusted duplicates, which preserves auditability at the cost of additional records.
* Record compacting during preparation discards records that do not represent genuine changes. The definition of "genuine change" — which attributes participate in the checksum — therefore determines what history is retained.
* The bitemporal pattern is markedly more complex than the unitemporal one. Apply it only where a second timeline is genuinely required; a unitemporal Satellite is sufficient when the inscription order is the only timeline of interest.
* Set-based timeline splitting reads and joins the target Satellite. On large Satellites, indexing on the surrogate key and temporal columns is essential to keep the overlap detection efficient.

## Related patterns

* [Design Pattern - Data Vault - Satellite](/patterns/design-patterns/design-pattern-data-vault-satellite/)
* [Design Pattern - Generic - Assertion and State Timelines](/patterns/design-patterns/design-pattern-generic-assertion-and-state-timelines/)
* [Design Pattern - Generic - Using Checksums for Row Comparison](/patterns/design-patterns/design-pattern-generic-using-checksums/)
* [Solution Pattern - SQL Server Family - Data Vault Hub](/patterns/solution-patterns/solution-pattern-sql-server-family-data-vault-hub/)
