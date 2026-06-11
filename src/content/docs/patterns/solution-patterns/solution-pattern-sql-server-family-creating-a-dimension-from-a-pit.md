---
title: "Solution Pattern - SQL Server Family - Creating a Dimension from a PIT"
---

## Purpose

This Solution Pattern shows how to create a (time-variant) dimension from a Point-In-Time (PIT) table with a single SQL statement.

## Motivation

A PIT table pre-computes the combined timeline across the Satellites of a Hub: for every key and every change moment it records which Satellite record was in effect, by its surrogate key, inscription timestamp, and inscription record identifier. With the temporal alignment already resolved, building a dimension becomes straightforward — the Satellites are attached with simple equi-joins, without any range predicates or window logic over the source objects.

## Applicability

This pattern applies when a PIT table exists for the Hub the dimension describes, and the dimension should reflect the full change history (a time-variant, 'type 2' style dimension). It is the preferred construction when the combination of Satellites is queried frequently enough to justify maintaining the PIT.

## Structure

The statement selects from the PIT and decorates it with the descriptive context:

* Each Satellite is joined on the exact record locator the PIT carries for it: surrogate key, inscription timestamp, and inscription record identifier. These are equi-joins — the PIT already did the temporal work.
* The dimension key is generated at runtime with `ROW_NUMBER` over a deterministic ordering.
* The time period of each dimension record is the PIT's state from timestamp, closed by a `LEAD` to the next state per key (with the `9999-12-31` high-end default).
* The remaining columns map the business key and the descriptive attributes from the joined Satellites.

```sql file=<rootDir>/patterns/solution-patterns/solution-pattern-sql-server-family-creating-a-dimension-from-a-pit-snippet-1.sql
```

## Implementation guidelines

* Generate the statement from metadata: the PIT, the participating Satellites, their record locator columns, and the data item mappings are all known in the solution metadata.
* Use `LEFT JOIN`s to the Satellites, so periods where a Satellite has no record yet still produce a dimension record (with `NULL`s for that Satellite's attributes).
* Keep the `ROW_NUMBER` ordering deterministic and stable (for example inscription timestamp, inscription record identifier, state from timestamp, business key), so reruns produce the same keys for the same data.
* Alternatively, persist the dimension key in the PIT itself; the dimension statement then simply selects it, and facts referencing the same PIT use identical keys by construction.
* Derive the closing `Before_Timestamp` per key with `LEAD`, consistent with the closed-open convention used across the solution.

## Considerations and consequences

* Runtime-generated dimension keys are only stable as long as the underlying data and ordering are unchanged: a reload after new data arrives produces different key values. Consumers must treat the dimension as fully refreshed, or the keys must be persisted (in the PIT or a key map) for stability.
* The dimension's grain equals the PIT's grain: one record per key per change moment. Snapshot-based PITs produce snapshot-grain dimensions accordingly.
* The pattern's simplicity is bought upstream — the PIT must be maintained as Satellites load. Where no PIT is warranted, a dimension can be created directly from the integration layer objects instead.
* Virtualising the dimension (as a view over the PIT) is a natural fit: the statement is deterministic and inexpensive relative to the PIT construction itself.

## Related patterns

* [Solution Pattern - SQL Server Family - Creating a Dimension from Integration Layer Objects](/patterns/solution-patterns/solution-pattern-sql-server-family-creating-a-dimension-from-integration-layer-objects/)
* [Solution Pattern - SQL Server Family - Creating a Fact Object](/patterns/solution-patterns/solution-pattern-sql-server-family-creating-a-fact-object/)
* [Solution Pattern - SQL Server Family - Combining Multiple Time-Variant Objects](/patterns/solution-patterns/solution-pattern-sql-server-family-combining-multiple-time-variant-objects/)
