---
title: "Solution Pattern - SQL Server Family - Combining Multiple Time-Variant Objects"
---

## Purpose

This Solution Pattern shows how to combine three or more time-variant data objects in SQL by first constructing a unified timeline of all change moments, and then joining each object's context to that timeline.

## Motivation

[Joining two time-variant objects](/patterns/solution-patterns/solution-pattern-sql-server-family-joining-two-time-variant-objects/) pairwise works well, but iterating pairwise joins becomes unwieldy as the number of objects grows: the timeline complexity increases with each additional object, and every temporal boundary must be considered for segmentation.

Building the combined timeline first — one grid of time periods per key, covering every change moment of every participating object — turns the problem around. Each object is then joined to the grid with a simple point-in-time predicate, regardless of how many objects participate.

## Applicability

This pattern applies when combining data from several time-variant objects that share a key — typically multiple Satellites describing the same Hub — for delivery or further processing. It assumes each object carries a from timestamp per change; before timestamps are derived as part of the pattern.

## Structure

The statement is built in three steps:

* **Collect the timeline.** The union of every object's from timestamps per key, together with a zero record per key at a low-end default (`1900-01-01`), produces the complete set of boundary moments. The zero record ensures the timeline covers the key from the beginning of time, so context that arrives later simply shows as absent in the earliest periods.
* **Close the periods.** A `LEAD` over the collected timestamps per key derives the before timestamp that closes each interval, with the high-end default (`9999-12-31`) for the open period.
* **Assemble the result.** The Hub is joined for the business key, and each Satellite is joined with a point-in-time predicate: the Satellite record whose period covers the grid segment supplies the context for that segment. `LEFT OUTER JOIN`s keep segments where an object has no valid data yet, with `NULL` attributes for that side.

```sql file=<rootDir>/patterns/solution-patterns/solution-pattern-sql-server-family-combining-multiple-time-variant-objects-snippet-1.sql
```

## Implementation guidelines

* Generate the statement from metadata: the participating objects, their key mapping, and the data item mappings per object are supplied by the solution metadata, so the same template serves any combination.
* Include a from timestamp source for *every* participating object in the timeline collection — a boundary missed in step one is a change invisible in the result.
* Use the standard low-end (`1900-01-01`) and high-end (`9999-12-31`) defaults consistently with the rest of the solution.
* Use closed-open period semantics in the point-in-time predicates, so each grid segment matches exactly one record per object.
* This construction is the basis of a Point-In-Time (PIT) table: materialising the grid (with the matched keys and timestamps per object) pre-computes the combination and avoids repeating the window functions and range joins at query time. Consider a PIT when the combination is queried frequently or when many objects participate.

## Considerations and consequences

* The grid contains a segment for every change moment of every object, so the result is more granular than any input. With many frequently-changing objects the segment count grows accordingly — performance optimisation becomes critical, which is the main argument for materialising as a PIT.
* Segments preceding an object's first record carry `NULL`s for that object's attributes; consumers must handle these explicitly.
* Adjacent segments can carry identical values when a boundary of one object does not change the selected columns of another. Apply compacting afterwards if this redundancy is unwanted.
* The pattern presumes each object's own timeline is consistent; defects propagate into the combined result.

## Related patterns

* [Solution Pattern - SQL Server Family - Joining Two Time-Variant Objects](/patterns/solution-patterns/solution-pattern-sql-server-family-joining-two-time-variant-objects/)
* [Solution Pattern - SQL Server Family - Deriving End-Dating](/patterns/solution-patterns/solution-pattern-sql-server-family-deriving-end-dating/)
* [Solution Pattern - SQL Server Family - Compacting as a Post-Process](/patterns/solution-patterns/solution-pattern-sql-server-family-compacting-as-a-post-process/)
* [Design Pattern - Generic - Assertion and State Timelines](/patterns/design-patterns/design-pattern-generic-assertion-and-state-timelines/)
