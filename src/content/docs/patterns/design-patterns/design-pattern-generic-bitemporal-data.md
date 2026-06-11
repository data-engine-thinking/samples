---
title: "Design Pattern - Generic - Bitemporal Data"
---

## Purpose

This Design Pattern describes bitemporal data: data with two independent timelines — the assertion timeline (when data was recorded) and the state timeline (when the data applies in the business) — working together.

## Motivation

In a unitemporal data object, changes are recorded in arrival order. But the order of data arrival does not always match when changes actually occurred in the business — a late-arriving older change can make the 'wrong' (older) value appear to be the most current one.

If the goal is to understand when values were valid *regardless of when the change was received*, a different perspective on time is needed: the state timeline, represented by the state timestamp. A fully bitemporal data object enables queries about the past, present, and even future state of the data, independent of when the changes were recorded, and reflects the historical understanding as it was at any given point in time.

## Applicability

This pattern applies when:

* Source systems provide (reasonably) reliable business effective timestamps.
* Business requirements demand "as-was" and "as-is" queries: data as it was known at a point in time, and data as it applied at a point in time.
* Late-arriving or backdated changes must be placed at their correct position on the business timeline.
* Corrections to historical records must be possible without losing the audit trail.

## Structure

Bitemporality is implemented using three timestamp columns:

* The **inscription timestamp**, representing the assertion timeline — used for filtering only.
* The **state from timestamp**, representing the start of a state time period.
* The **state before timestamp**, the end of a state time period, using a closed-open approach.

The primary key of a bitemporal data object consists of the surrogate key, the inscription timestamp, the inscription record identifier, and the state from (or state before) timestamp. The state from timestamp must be part of the key because a single arrival can affect multiple state periods.

The two timelines can be visualised on a Cartesian plane, with the assertion timeline on the y-axis and the state timeline on the x-axis. Each record occupies a block on this plane; queries are intersections at a chosen point on each axis.

## Implementation guidelines

* Standardise data objects to support bitemporality structurally: create the assertion timeline automatically, and map the state timeline to the best available option from the source. This way the same structure serves every object, even where the state timeline initially mirrors the assertion timeline.
* Resolve timeline effects at load time. An incoming record can relate to existing state periods in any of the interval (Allen) relationships — for example, a 'during' relationship disrupts an existing period, which must be split so the timeline remains continuous.
* Expect backdated adjustments to create a ripple effect: a change inserted in the past propagates adjustments until the next regular change on the state timeline.
* Use closed-open time periods (the state before timestamp is the start of the next period, not the end of the current one), so periods connect without gaps or double-counting.

## Considerations and consequences

* Bitemporal loading is markedly more complex than unitemporal loading, since overlapping periods must be detected and split deterministically. This complexity is paid once, in the load pattern; in return, data delivery does not need to repair timelines downstream.
* Corrections and backdated changes are recorded as new records — auditability is preserved at the cost of additional records.
* A unitemporal design defers these problems to the moment data is combined and delivered; a bitemporal design resolves them upfront. Which trade-off is appropriate depends on how often business time matters for consumption.
* The reliability of the state timeline is bounded by the quality of the source's business timestamps. Where these are absent, the state timeline falls back to the assertion timeline, and the data is effectively unitemporal until better information arrives.

## Related patterns

* [Design Pattern - Generic - Nontemporal Data](/patterns/design-patterns/design-pattern-generic-nontemporal-data/)
* [Design Pattern - Generic - Unitemporal Data](/patterns/design-patterns/design-pattern-generic-unitemporal-data/)
* [Design Pattern - Generic - Assertion and State Timelines](/patterns/design-patterns/design-pattern-generic-assertion-and-state-timelines/)
* [Design Pattern - Data Vault - Satellite](/patterns/design-patterns/design-pattern-data-vault-satellite/)
* [Solution Pattern - SQL Server Family - Data Vault Satellite](/patterns/solution-patterns/solution-pattern-sql-server-family-data-vault-satellite/)
