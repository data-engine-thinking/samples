---
title: "Solution Pattern - SQL Server Family - Joining Objects in the Persistent Staging Area"
---

## Purpose

This Solution Pattern shows how to join two time-variant data objects from the Persistent Staging Area (PSA) into a single, continuous timeline using set-based SQL.

## Motivation

Combining two time-variant objects means reconciling two independent timelines into one. Each object changes on its own cadence — a customer's details and a category's details each have their own change history — so the combined result must reflect a change whenever *either* object changes.

Joining directly on the key alone would lose this temporal detail, and joining on exact timestamps would miss changes that occurred between each other's change moments. Instead, the combined timeline is assembled from both points of view and merged.

## Applicability

This pattern applies when data from two (or more) PSA objects must be combined at a shared key while preserving the full change history of both — for example, to prepare an integrated set for loading downstream data objects, or to evaluate combined states across objects. It assumes each object carries a from timestamp per change (with the before timestamp derivable), plus the PSA's standard columns (inscription timestamp, change data indicator, checksum).

## Structure

The statement builds the combined timeline from both perspectives:

* For each object, the effective time periods are derived at runtime: `LEAD` per key produces the timestamp that closes each interval (closed-open, with `9999-12-31` as the high-end default).
* The **first perspective** takes every change of the first object and joins it to the period of the second object that was in effect at that moment (`from >= start AND from < end`).
* The **second perspective** does the same in reverse, so changes of the second object that fall between changes of the first are also represented.
* A `UNION ALL` merges both perspectives, and a final `LEAD` over the combined set derives the before date that closes each interval — producing a single timeline with no gaps or overlaps.

Three runnable variants are provided. The complete example:

```sql file=<rootDir>/patterns/solution-patterns/solution-pattern-sql-server-family-joining-objects-in-the-persistent-staging-area-snippet-1.sql
```

A pared-down version that is easier to follow:

```sql file=<rootDir>/patterns/solution-patterns/solution-pattern-sql-server-family-joining-objects-in-the-persistent-staging-area-snippet-2.sql
```

An alternative formulation:

```sql file=<rootDir>/patterns/solution-patterns/solution-pattern-sql-server-family-joining-objects-in-the-persistent-staging-area-snippet-3.sql
```

For a detailed walkthrough of this approach, see the blog post [Joining tables in the persistent staging area](https://roelantvos.com/blog/joining-tables-in-the-persistent-staging-area/).

## Implementation guidelines

* Derive each object's time periods at runtime with `LEAD`, rather than relying on persisted end dates — the derivation is then always consistent with the data being joined.
* Use closed-open period comparisons (`>= start AND < end`) so each change maps to exactly one period of the other object, without double-counting boundary moments.
* Use a `LEFT JOIN` for the leading perspective when changes may precede any period of the joined object (no match yet), and an `INNER JOIN` for the reverse perspective to avoid duplicating the unmatched rows.
* Carry the PSA's standard columns (inscription timestamp, inscription record identifier, change data indicator, audit trail identifier) through the join, so the combined set remains traceable.
* Apply the final `LEAD` over the merged set partitioned by the driving key, ordered by the effective date, to close the combined intervals.

## Considerations and consequences

* The combined timeline contains a record for every change in either object, so the result is more granular than either input. Identical consecutive states can appear when a change in one object does not affect the selected columns of the other; compacting can be applied afterwards if this redundancy is unwanted.
* The pattern generalises to more than two objects by applying it iteratively, but each additional object multiplies the timeline fragments; combining many objects this way warrants performance testing.
* Window functions over large PSA objects benefit from indexing on the key and timestamp columns used in the `PARTITION BY` and `ORDER BY` clauses.
* This join resolves timelines at *read* time in the staging layer. In a bitemporal integration layer the same concerns are addressed structurally when loading Satellites.

## Related patterns

* [Design Pattern - Generic - Assertion and State Timelines](/patterns/design-patterns/design-pattern-generic-assertion-and-state-timelines/)
* [Solution Pattern - SQL Server Family - Deriving End-Dating](/patterns/solution-patterns/solution-pattern-sql-server-family-deriving-end-dating/)
* [Solution Pattern - SQL Server Family - Compacting as a Post-Process](/patterns/solution-patterns/solution-pattern-sql-server-family-compacting-as-a-post-process/)
