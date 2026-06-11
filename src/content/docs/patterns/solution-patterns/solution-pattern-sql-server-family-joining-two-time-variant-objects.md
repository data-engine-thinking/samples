---
title: "Solution Pattern - SQL Server Family - Joining Two Time-Variant Objects"
---

## Purpose

This Solution Pattern shows how to join two time-variant data objects in SQL so that the result carries a valid combined timeline: every output record represents a period in which both inputs were simultaneously in effect.

## Motivation

When two entities with independent change histories are combined — for example, two Satellites describing the same Hub — their timelines must be synchronised. Each object changes at its own moments, so the combined timeline is the intersection of the two: a new segment starts at every boundary of either object, and a combined period is only valid where the input periods genuinely overlap.

Joining on the key alone would pair every state of one object with every state of the other; joining on exact timestamps would miss the periods in between. The interval intersection produces exactly the valid temporal pairs.

## Applicability

This pattern applies when delivering data that combines two time-variant objects sharing a key — typically two Satellites attached to the same Hub — and the result must remain time-variant. It assumes both objects carry complete state time periods (from and before timestamps, closed-open); where the before timestamp is not persisted, it is derived first.

## Structure

The statement joins the two objects on their shared key and intersects their periods:

* The combined **state from timestamp** is the *greatest* of the two from timestamps.
* The combined **state before timestamp** is the *smallest* of the two before timestamps.
* The filter keeps only pairs where the combined from is earlier than the combined before — that is, pairs whose periods actually overlap.

Each output record carries the attributes of both objects, valid for exactly the intersected period:

```sql file=<rootDir>/patterns/solution-patterns/solution-pattern-sql-server-family-joining-two-time-variant-objects-snippet-1.sql
```

## Implementation guidelines

* Use closed-open time periods consistently, with a standard high-end default (such as `9999-12-31`) for open periods, so the greatest/smallest comparisons work without special cases.
* If the before timestamps are not persisted, derive them first — see [Solution Pattern - SQL Server Family - Deriving End-Dating](/patterns/solution-patterns/solution-pattern-sql-server-family-deriving-end-dating/).
* The `CASE` expressions implement greatest/least comparisons portably; on platforms that support them (SQL Server 2022 and later), `GREATEST` and `LEAST` express the same logic more compactly.
* An `INNER JOIN` returns only periods where both objects have valid data. Where one object may have no data for part of the timeline, use an outer join and decide explicitly how to represent the missing side (`NULL` attributes for that period).
* Extend to more than two objects by applying the pattern iteratively: join two objects, then join the result with the next object using the same greatest/least intersection.

## Considerations and consequences

* The result is more granular than either input: a new segment begins at every boundary of either object. Combining many objects multiplies segments accordingly.
* Adjacent output segments can carry identical attribute values when a change in one object does not alter the selected columns of the other. Apply compacting afterwards if this redundancy is unwanted — see [Solution Pattern - SQL Server Family - Compacting as a Post-Process](/patterns/solution-patterns/solution-pattern-sql-server-family-compacting-as-a-post-process/).
* The pattern presumes the input timelines are themselves consistent (no gaps or overlaps); any timeline defects in the inputs propagate into the combined result.
* The intersection logic is a set-based join with range predicates; indexing the key and period columns supports performance on larger objects.

## Related patterns

* [Design Pattern - Generic - Assertion and State Timelines](/patterns/design-patterns/design-pattern-generic-assertion-and-state-timelines/)
* [Design Pattern - Generic - Bitemporal Data](/patterns/design-patterns/design-pattern-generic-bitemporal-data/)
* [Solution Pattern - SQL Server Family - Deriving End-Dating](/patterns/solution-patterns/solution-pattern-sql-server-family-deriving-end-dating/)
* [Solution Pattern - SQL Server Family - Joining Objects in the Persistent Staging Area](/patterns/solution-patterns/solution-pattern-sql-server-family-joining-objects-in-the-persistent-staging-area/)
* [Solution Pattern - SQL Server Family - Compacting as a Post-Process](/patterns/solution-patterns/solution-pattern-sql-server-family-compacting-as-a-post-process/)
