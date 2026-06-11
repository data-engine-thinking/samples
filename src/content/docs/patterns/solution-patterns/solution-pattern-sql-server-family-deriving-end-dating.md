---
title: "Solution Pattern - SQL Server Family - Deriving End-Dating"
---

## Purpose

This Solution Pattern shows how to derive end-dating in SQL: evaluating the before timestamp that closes the time period started by a given from timestamp. Both the runtime ('on the fly') and the persisted approach are covered.

## Motivation

Defining a time period requires both a start and an end. Sometimes both values are provided by the operational system, but in many cases the end of a period must be calculated: a record is no longer current when a newer record for the same key arrives.

This concept is widely known as end-dating (or expiry-dating). In a closed-open approach it is more precisely 'before-dating': deriving the timestamp *before* which the record applies. Unless it is already available in the data, the before timestamp is derived from the from timestamp of the next record, sorted by key and from timestamp.

## Applicability

This pattern applies to time-variant data objects — Satellites in particular — where complete time periods are not (reliably) provided by the source. It covers the choice between:

* Deriving the before timestamp at runtime, preserving an insert-only data solution.
* Persisting the before timestamp as a physical column, closing periods with an update.

## Structure

### Deriving at runtime

The before timestamp can always be derived from the available from timestamps, so it does not need to be stored. The `LEAD` window function selects the from timestamp of the next record per key; when no next record exists, a standard high-end default (`9999-12-31`) indicates the absence of a before timestamp:

```sql file=<rootDir>/patterns/solution-patterns/solution-pattern-sql-server-family-deriving-end-dating-snippet-1.sql
```

This expression can be added to any query whenever a before timestamp is needed, and the derived values are always correct for the data and logic at hand.

### Closing persisted time periods

When the before timestamp is persisted as a physical column, periods must be closed when newer records arrive. The same `LEAD` derivation supplies the new value; the update applies it to records whose stored period is open or no longer consistent with the timeline:

```sql file=<rootDir>/patterns/solution-patterns/solution-pattern-sql-server-family-deriving-end-dating-snippet-2.sql
```

## Implementation guidelines

* Use a standard default high-end value to indicate the absence of a before timestamp, applied consistently across the solution. A date far in the future — such as `9999-12-31` — works well.
* If before timestamps are persisted, make the before-dating logic part of the *same* data logistics module as the insert, so inserts and updates commit or roll back as a single functional unit. When the insert succeeds but a separate update process fails, time periods become inconsistent, leading to overlaps and downstream problems.
* Persist (and derive) the before timestamp for the state timeline only. An 'inscription before timestamp' for the assertion timeline is not recommended: the assertion timeline is best used for filtering, while the state timeline serves date math and combining data sets. If a rare use case genuinely requires it, it can always be added later.
* A time period applies to the entire record — all of its columns and values. When the column scope changes (Satellite splitting, selecting subsets of columns for delivery), the time periods must be recalculated, which is easier when derivation happens at runtime.
* A metadata-driven engine can switch between runtime and persisted before timestamps based on directives for cost or performance optimisation, where the column is not directly mapped.

## Considerations and consequences

* Runtime derivation keeps the solution insert-only: no update transactions, no concurrency control concerns, and no risk of stale stored values. The trade-off is the cost of the window function each time a query runs, and the additional SQL knowledge required to interpret the data for point-in-time selections.
* Persisting the before timestamp simplifies downstream queries and can be more cost-effective on platforms that charge more for compute than for storage. The trade-offs are the I/O cost, the loss of a strictly insert-only process, and the obligation to keep stored periods consistent.
* A specific edge case in favour of persisting arises when the data solution supports driving keys.
* Some technologies do not support in-place updates at all, in which case runtime derivation is the only option.

## Related patterns

* [Design Pattern - Generic - Unitemporal Data](/patterns/design-patterns/design-pattern-generic-unitemporal-data/)
* [Design Pattern - Generic - Bitemporal Data](/patterns/design-patterns/design-pattern-generic-bitemporal-data/)
* [Design Pattern - Generic - Assertion and State Timelines](/patterns/design-patterns/design-pattern-generic-assertion-and-state-timelines/)
* [Solution Pattern - SQL Server Family - Data Vault Satellite](/patterns/solution-patterns/solution-pattern-sql-server-family-data-vault-satellite/)
