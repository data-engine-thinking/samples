---
title: "Solution Pattern - SQL Server Family - Creating a Fact Object"
---

## Purpose

This Solution Pattern shows how to create a fact object from a Point-In-Time (PIT) table and the Satellite that carries the measurable events, with a single SQL statement.

## Motivation

Facts combine references to dimensions with measures aggregated at a chosen grain. When a PIT table already resolves which Satellite records apply per key and moment, the fact statement reduces to: join the metric Satellite by its record locator, derive the dimension keys, and aggregate the measures.

## Applicability

This pattern applies when delivering measurable events from the integration layer as a fact object — persisted or virtual — and a PIT table exists at (or near) the fact's intended grain.

## Structure

The statement selects from the PIT, attaches the metric Satellite, and aggregates:

* The **date dimension key** is derived directly from the event timestamp (formatted as `YYYYMMDD`).
* The **dimension keys** are generated at runtime with `ROW_NUMBER` per dimension's surrogate key, ordered by the state from timestamp — mirroring how the corresponding dimensions generate their keys. When the keys are persisted in the PIT, they are selected instead.
* The metric Satellite is joined on the record locator the PIT carries for it: surrogate key, inscription timestamp, and inscription record identifier.
* The measures are aggregated with a `GROUP BY` on the dimension references, setting the fact's grain.

```sql file=<rootDir>/patterns/solution-patterns/solution-pattern-sql-server-family-creating-a-fact-object-snippet-1.sql
```

## Implementation guidelines

* Generate the statement from metadata: the PIT, the metric Satellite, the dimension references, and the measures with their aggregation functions are supplied by the fact's mapping metadata.
* If dimension keys are generated at runtime, the generation must be *identical* to the corresponding dimension statements — same partition, same ordering — or facts and dimensions will not join correctly. Persisting the keys in the PIT removes this coupling and is the more robust choice.
* Derive calendar keys (such as the date key) from the event timestamp with a deterministic format, so they join the date dimension without lookups.
* Choose the `GROUP BY` deliberately: it defines the fact's grain. Aggregating at the PIT's grain is not required — the example aggregates to customer/product/date.
* Use a `LEFT JOIN` for the metric Satellite if events may be absent for some PIT records, and decide how empty aggregates should be represented.

## Considerations and consequences

* Runtime key generation makes the fact and its dimensions a matched set: they must be produced from the same data state. A refresh of one without the other breaks the key alignment — the main argument for persisting keys when facts and dimensions are delivered independently.
* The aggregation discards event-level detail; if consumers also need the individual transactions, deliver a separate transactional fact at event grain.
* Virtualising the fact (a view over the PIT and Satellite) is viable when the aggregation is inexpensive; heavy aggregations over large PITs favour persistence.

## Related patterns

* [Solution Pattern - SQL Server Family - Creating a Dimension from a PIT](/patterns/solution-patterns/solution-pattern-sql-server-family-creating-a-dimension-from-a-pit/)
* [Solution Pattern - SQL Server Family - Creating a Dimension from Integration Layer Objects](/patterns/solution-patterns/solution-pattern-sql-server-family-creating-a-dimension-from-integration-layer-objects/)
