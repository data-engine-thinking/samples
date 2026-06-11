---
title: "Solution Pattern - SQL Server Family - Snapshot-Based PIT"
---

## Purpose

This Solution Pattern shows how to create a snapshot-based Point-In-Time (PIT) table: one record per key for each chosen snapshot moment, carrying pointers to the Satellite records in effect at that moment.

## Motivation

Not every consumer needs the full change history. Reporting is often periodic — daily, weekly, end-of-month — and only the state *as at* those moments matters. A snapshot-based PIT resolves, for each snapshot moment, which record of each Satellite applies, producing a compact structure that is far smaller than the full timeline while still answering the questions consumers actually ask.

## Applicability

This pattern applies when periodic states are sufficient for delivery, or when the full timeline-based PIT is too large to maintain economically. It assumes the Satellites carry state time periods (closed-open) and, for bitemporal selection, inscription timestamps.

## Structure

The statement resolves the pointers for one snapshot moment, defined by two parameters:

* The **assertion snapshot timestamp** filters on the assertion timeline — only records inscribed up to that moment participate. Defaulting it to the current time (`SYSUTCDATETIME()`) means "as currently known"; an earlier value reproduces what was known at that time.
* The **state snapshot timestamp** selects on the state timeline — for each Satellite, the record whose state period covers the snapshot moment.
* Per key, the result carries the snapshot timestamp, the Hub's surrogate key, and each Satellite's record locator (surrogate key, inscription timestamp, inscription record identifier, state from timestamp), plus optional frequently-used columns.

Running the statement for successive snapshot moments and appending the results builds up the PIT.

```sql file=<rootDir>/patterns/solution-patterns/solution-pattern-sql-server-family-snapshot-based-pit-snippet-1.sql
```

## Implementation guidelines

* Generate the statement from metadata, with the snapshot timestamps as parameters; the same template then serves every snapshot cadence.
* Keep the two snapshot parameters distinct: the assertion timestamp answers "as known when?", the state timestamp answers "as applicable when?". Setting both is what makes the selection bitemporal.
* Use period-covering predicates with closed-open semantics (`from <= snapshot AND before > snapshot`), so each Satellite contributes exactly one record per key per snapshot.
* Append snapshots in load order and index on key and snapshot timestamp; consumers filter on the snapshot timestamp to select their reporting moment.
* Keep the PIT pointer-based, as with the timeline-based variant; the payload is attached at delivery time via equi-joins.

## Considerations and consequences

* Only the chosen snapshot moments are queryable. Questions about states between snapshots cannot be answered from the snapshot PIT — that is the trade-off against the [timeline-based PIT](/patterns/solution-patterns/solution-pattern-sql-server-family-timeline-based-pit/), and the reason the two variants coexist.
* Late-arriving data inscribed after a snapshot was taken is not reflected in that snapshot. When this matters, recompute recent snapshots (the assertion parameter makes any snapshot reproducible).
* Size grows linearly with keys × snapshot moments, predictably and independently of how often the underlying data changes.
* As with any PIT, the structure is derived: rebuildable from the integration layer, refreshed on a schedule aligned with the snapshot cadence.

## Related patterns

* [Solution Pattern - SQL Server Family - Timeline-Based PIT](/patterns/solution-patterns/solution-pattern-sql-server-family-timeline-based-pit/)
* [Solution Pattern - SQL Server Family - Creating a Dimension from a PIT](/patterns/solution-patterns/solution-pattern-sql-server-family-creating-a-dimension-from-a-pit/)
* [Solution Pattern - SQL Server Family - Creating a Fact Object](/patterns/solution-patterns/solution-pattern-sql-server-family-creating-a-fact-object/)
* [Design Pattern - Generic - Bitemporal Data](/patterns/design-patterns/design-pattern-generic-bitemporal-data/)
