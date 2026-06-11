---
title: "Solution Pattern - SQL Server Family - Timeline-Based PIT"
---

## Purpose

This Solution Pattern shows how to create a timeline-based Point-In-Time (PIT) table: one record per key for every change moment across the Satellites of a Hub, each carrying pointers to the Satellite records in effect during that period.

## Motivation

Combining several time-variant objects requires aligning their timelines — work that grows with every object and every query that needs the combination. A PIT table performs this alignment once: it records, per key and per time period, exactly which record of each Satellite applies. Downstream deliveries (dimensions, facts) then attach the context with simple equi-joins.

The timeline-based variant covers the *complete* timeline: a record for every change moment of every participating Satellite, so any point in time can be queried at full fidelity.

## Applicability

This pattern applies when the combination of a Hub's Satellites is queried often enough to justify materialising the alignment, and consumers need the full change history rather than periodic snapshots. It assumes the Satellites carry state time periods (closed-open).

## Structure

The statement builds the timeline and resolves the pointers:

* **Timeline.** A zero record per key at the low-end default (`1900-01-01`) is combined with the union of every Satellite's state from timestamps; a `LEAD` per key closes each period (high-end default `9999-12-31`).
* **Pointer resolution.** The Hub is joined for the key, and each Satellite is joined with a period-covering predicate, so each PIT record points to the Satellite record in effect during that period.
* **Pointers, not payload.** Per Satellite, the PIT carries the record locator — surrogate key, inscription timestamp, inscription record identifier, and state from timestamp — rather than the descriptive attributes themselves. Frequently used columns (such as the business key) can optionally be included.

```sql file=<rootDir>/patterns/solution-patterns/solution-pattern-sql-server-family-timeline-based-pit-snippet-1.sql
```

## Implementation guidelines

* Generate the statement from metadata: the Hub, the participating Satellites, and their locator columns are known in the solution metadata, so the same template serves every PIT.
* Keep the PIT narrow: pointers and timestamps. The payload stays in the Satellites and is attached at delivery time via equi-joins — see [Creating a Dimension from a PIT](/patterns/solution-patterns/solution-pattern-sql-server-family-creating-a-dimension-from-a-pit/).
* Include a from timestamp source for every participating Satellite in the timeline union; a missed source means invisible changes.
* Use the solution's standard low-end and high-end defaults and closed-open period semantics throughout.
* Index the PIT on the key and period columns; its whole purpose is fast lookups.

## Considerations and consequences

* The PIT contains a record for every change moment of every participating Satellite — full fidelity at the cost of volume. Where periodic states suffice, a [snapshot-based PIT](/patterns/solution-patterns/solution-pattern-sql-server-family-snapshot-based-pit/) is substantially smaller.
* The PIT is derived data: it can be truncated and rebuilt from the integration layer at any time, and must be refreshed when the participating Satellites load.
* Adding or removing a participating Satellite changes the timeline (and the PIT's shape); regenerate from metadata rather than altering in place.

## Related patterns

* [Solution Pattern - SQL Server Family - Snapshot-Based PIT](/patterns/solution-patterns/solution-pattern-sql-server-family-snapshot-based-pit/)
* [Solution Pattern - SQL Server Family - Creating a Dimension from a PIT](/patterns/solution-patterns/solution-pattern-sql-server-family-creating-a-dimension-from-a-pit/)
* [Solution Pattern - SQL Server Family - Creating a Fact Object](/patterns/solution-patterns/solution-pattern-sql-server-family-creating-a-fact-object/)
* [Solution Pattern - SQL Server Family - Combining Multiple Time-Variant Objects](/patterns/solution-patterns/solution-pattern-sql-server-family-combining-multiple-time-variant-objects/)
