---
title: "Solution Pattern - SQL Server Family - Creating a Dimension from Integration Layer Objects"
---

## Purpose

This Solution Pattern shows how to create a dimension directly from integration layer objects — Hubs and Satellites — without an intermediate Point-In-Time (PIT) table, as a single layered SQL statement.

## Motivation

Maintaining a PIT table is worthwhile when a combination of Satellites is queried often, but it is not a prerequisite for delivery. A dimension can be assembled straight from the integration layer: the timeline construction that a PIT would otherwise pre-compute is simply performed inline, and a checksum comparison reduces the result to the records that represent genuine changes for the selected columns.

This keeps the presentation layer flexible — dimensions can be defined, adjusted, and virtualised without first refactoring helper structures.

## Applicability

This pattern applies when a time-variant dimension is needed and no PIT table exists (or is warranted) for the Hub it describes. It is well suited to virtualised delivery, where the dimension is a view over the integration layer.

## Structure

The statement is a set of nested layers, each with one responsibility:

* **Combine all from timestamp values.** The union of change moments across the participating objects forms the timeline, as in [combining multiple time-variant objects](/patterns/solution-patterns/solution-pattern-sql-server-family-combining-multiple-time-variant-objects/).
* **Derive time periods.** A `LEAD` per key closes each interval.
* **Integration layer column selection.** The Hub and Satellites are joined point-in-time against the periods, and the dimension's columns are selected.
* **Checksum preparation and comparison.** A checksum across the *selected* columns is calculated and compared with the previous record per key, so only records that changed within the dimension's column scope remain.
* **Final formatting.** Column aliasing and final presentation-layer formatting, with the comparison filter applied.

```sql file=<rootDir>/patterns/solution-patterns/solution-pattern-sql-server-family-creating-a-dimension-from-integration-layer-objects-snippet-1.sql
```

## Implementation guidelines

* Generate the statement from metadata: the participating objects, the column selection, and the checksum definition all derive from the dimension's mapping metadata.
* Scope the checksum to the columns the dimension actually selects. The time periods apply to the whole record, so narrowing the column selection creates adjacent duplicates — the checksum comparison is what compacts them away.
* Keep the layers strictly nested as shown; each layer only references the previous one, which keeps the generated SQL predictable and debuggable.
* Use the solution's standard low-end and high-end timestamp defaults, and closed-open period semantics, throughout.
* The same construction serves persisted and virtual dimensions; for a virtual dimension, deploy the statement as a view.

## Considerations and consequences

* The timeline construction and checksum comparison run at query time. For frequently queried or heavily combined dimensions, a PIT table moves that work upstream — see [Creating a Dimension from a PIT](/patterns/solution-patterns/solution-pattern-sql-server-family-creating-a-dimension-from-a-pit/).
* Because compacting is driven by the selected columns, changing the dimension's column selection changes which records survive; the dimension is consistent for its definition, not a fixed subset of the integration layer.
* Window functions and point-in-time joins over large Satellites benefit from supporting indexes on key and timestamp columns.
* The dimension key concern is the same as for the PIT-based construction: runtime-generated keys are not stable across reloads unless persisted.

## Related patterns

* [Solution Pattern - SQL Server Family - Creating a Dimension from a PIT](/patterns/solution-patterns/solution-pattern-sql-server-family-creating-a-dimension-from-a-pit/)
* [Solution Pattern - SQL Server Family - Combining Multiple Time-Variant Objects](/patterns/solution-patterns/solution-pattern-sql-server-family-combining-multiple-time-variant-objects/)
* [Solution Pattern - SQL Server Family - Compacting as a Post-Process](/patterns/solution-patterns/solution-pattern-sql-server-family-compacting-as-a-post-process/)
* [Design Pattern - Generic - Using Checksums for Row Comparison](/patterns/design-patterns/design-pattern-generic-using-checksums/)
