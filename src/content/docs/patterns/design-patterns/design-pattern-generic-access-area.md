---
title: "Design Pattern - Generic - Access Area"
---

## Purpose

This Design Pattern describes the access area: the final area of the architecture, where the prepared data leaves the data solution for further use through outgoing interfaces.

## Motivation

The presentation layer compiles the data available in the integration layer into a format that is fit-for-purpose for consumption — transforming the organisation's holistic information model into specific deliveries per use case. The access area is where this delivery happens: it is the part of the solution that consumers can access.

The goal is usually to limit and simplify data access. A typical delivery model has a limited number of relationships between data sets, so consumers do not need complex join logic — the dimensional model being the classic example. Conversations about the 'single version of the truth' belong here: the access area is the best place in the architecture to have them, even when that truth applies to a specific use case or subject area.

## Applicability

This pattern applies to every data solution that delivers data to consumers. Consumers vary widely — front-end reporting and analysis software, APIs, export files, exposed data sets, and people querying directly (most notably with SQL) — which is why the solution speaks of *outgoing interfaces*, mirroring the incoming interfaces of the staging layer.

## Structure

The access area captures the target delivery model for the data:

* Specific business logic for data delivery is applied here, to the extent it has not already been addressed in the integration layer.
* Common implementations include aggregation and organising data into hierarchies.
* Each delivery (data mart) reflects its use case; the shape varies with the consumer.

## Implementation guidelines

* Introduce a decoupling mechanism to isolate consumers from changes in the data solution's structure. A common approach is database views on top of the access area objects: the semantic layer references the views, never the underlying objects directly. Changes can then be applied while the view preserves backwards compatibility, until consumers have updated their interfaces.
* Keep data marts as small as possible, so they remain decoupled from each other — a change in one mart should not affect other marts and their applications.
* Where final preparation is expensive or shared between deliveries, support the access area with a performance area rather than complicating the delivery objects themselves.

## Considerations and consequences

* The 'truth' delivered is fit-for-purpose: different use cases may legitimately receive differently shaped (or differently aggregated) data from the same integrated foundation.
* Decoupling through views adds a maintained artefact per delivery, but buys the freedom to evolve the solution without breaking consumers.
* The variety of outgoing interfaces means the access area is where format-specific concerns (naming, data types, time zone presentation) are finally resolved.

## Related patterns

* [Design Pattern - Generic - Performance Area](/patterns/design-patterns/design-pattern-generic-performance-area/)
* [Design Pattern - Generic - Landing Area](/patterns/design-patterns/design-pattern-generic-landing-area/)
* [Solution Pattern - SQL Server Family - Creating a Dimension from a PIT](/patterns/solution-patterns/solution-pattern-sql-server-family-creating-a-dimension-from-a-pit/)
* [Solution Pattern - SQL Server Family - Creating a Fact Object](/patterns/solution-patterns/solution-pattern-sql-server-family-creating-a-fact-object/)
