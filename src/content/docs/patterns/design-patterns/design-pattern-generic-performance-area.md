---
title: "Design Pattern - Generic - Performance Area"
---

## Purpose

This Design Pattern describes the performance area: an optional area within the presentation layer that ensures data can be delivered in a performant and efficient way.

## Motivation

Good performance matters throughout a data solution, but it is in the presentation layer that it usually matters most. In the earlier layers, transformations are relatively isolated and largely generic — pattern-based, and therefore easy to optimise thoroughly. In the presentation layer, everything comes together, and for reporting purposes often in a denormalised way.

When multiple data logistics processes need the same calculation, combination, or transformation, it is more effective to implement the required data set once — at the start of a processing schedule — and reuse it many times, than to repeat the work in every delivery.

## Applicability

The performance area is optional. It applies when:

* Multiple presentation layer processes share the same calculations or transformations.
* Delivery requires combinations or aggregates that are expensive to compute repeatedly.
* Physical optimisation (indexing, partitioning) of intermediate results pays off across consumers of those results.

## Structure

The performance area holds temporary result sets and (semi-)aggregates that support the final data preparation step. These objects can be physically optimised — indexed or partitioned — and are reused by more than one process. The area is *not* intended to be accessible to data consumers; it exists to support the access area.

Typical helper processes include:

* Aggregations, preparing data for a target level of detail.
* Pivoting data to suit a certain interface.
* Combining multiple integration layer objects to reduce the number of joins — Point-In-Time (PIT) tables are the canonical example.
* Reducing code duplication for often-used calculations.
* Date math: the logic to combine data sets that use different date ranges into a single set.

## Implementation guidelines

* Treat performance area objects as derived data: rebuildable from the integration layer at any time, and refreshed in step with the loads they depend on.
* Implement shared logic once, early in the processing schedule, and let the delivery processes reuse the result.
* Keep the area internal — consumers access the access area only, so performance area objects can be changed or dropped freely as processing needs evolve.
* Generate the helper structures from metadata where possible, so they evolve with the solution rather than becoming hand-maintained exceptions.

## Considerations and consequences

* The area trades storage and refresh effort for query and delivery performance; add helper objects when a measured need exists, not pre-emptively.
* Helper objects introduce processing dependencies: deliveries that reuse a result set can only run after it is refreshed. Orchestration must reflect this.
* Because the area is optional and internal, it can be introduced, restructured, or removed without affecting consumers — provided the access area remains stable.

## Related patterns

* [Design Pattern - Generic - Access Area](/patterns/design-patterns/design-pattern-generic-access-area/)
* [Solution Pattern - SQL Server Family - Timeline-Based PIT](/patterns/solution-patterns/solution-pattern-sql-server-family-timeline-based-pit/)
* [Solution Pattern - SQL Server Family - Snapshot-Based PIT](/patterns/solution-patterns/solution-pattern-sql-server-family-snapshot-based-pit/)
