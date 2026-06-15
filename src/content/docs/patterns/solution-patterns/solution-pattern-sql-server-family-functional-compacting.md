---
title: "Solution Pattern - SQL Server Family - Functional Compacting"
---

## Purpose

This Solution Pattern shows how to reduce the number of records in a time-variant result set by applying a functional rule to the timeline itself — keeping only changes separated by at least a minimum gap, or one representative record per fixed time interval. Two complementary approaches are provided: continuous gap compacting and frequency compacting.

## Motivation

A high-frequency time-variant object can carry far more change points than a downstream consumer needs — for example, sub-second sensor readings when a report only requires an hourly view. Functional compacting deliberately reduces the record count by a rule about *time*: collapsing changes that fall within a chosen minimum gap, or reducing to a fixed reporting frequency.

This differs from record condensing (see [Compacting as a Post-Process](/patterns/solution-patterns/solution-pattern-sql-server-family-compacting-as-a-post-process/)), which removes only rows whose values are genuinely unchanged. Functional compacting can discard real, distinct changes in order to meet a target granularity — that is its intent.

## Applicability

This pattern applies to SQL-based processes that produce or deliver time-variant result sets, typically in the presentation layer. It is appropriate when:

- The source changes more often than consumers need, and a coarser temporal granularity is acceptable.
- A fixed reporting cadence (hourly, daily, weekly) is required for delivery.
- Storage reduction or query performance is a design goal and some loss of intermediate detail is acceptable.

## Structure

Two compacting approaches are provided, each addressing a different way of reducing the timeline.

### Continuous gap compacting

Continuous gap compacting retains only the rows that represent genuine transitions — rows where the gap to the next row in the timeline is at or above a chosen minimum threshold, plus the final row for each key. Rows separated by a gap smaller than the threshold are considered redundant and are discarded.

The implementation uses `LEAD` to look ahead to the next timestamp per key and `DATEDIFF` to calculate the gap. The outer filter keeps rows where the gap meets the threshold or where `LEAD` returns `NULL` (the last row).

```sql file=<rootDir>/patterns/solution-patterns/solution-pattern-sql-server-family-functional-compacting-continuous-gap-snippet-1.sql
```

### Frequency compacting

Frequency compacting reduces temporal granularity to a fixed interval (for example, one row per hour per key). Within each time bucket, `FIRST_VALUE` ordered descending picks the most recent record, and the outer filter keeps only the rows where the original timestamp matches that selected value.

```sql file=<rootDir>/patterns/solution-patterns/solution-pattern-sql-server-family-functional-compacting-frequency-snippet-1.sql
```

## Implementation guidelines

- Apply functional compacting as the final step, after the timeline has been constructed. Earlier application may discard rows that would have been needed by a join.
- Choose **continuous gap compacting** when redundancy arises from high-frequency micro-changes and the goal is to keep only records separated by a meaningful gap. Set the gap threshold to match the granularity that downstream consumers require.
- Choose **frequency compacting** when a fixed analytical interval is needed (hourly, daily, weekly). Adjust the `DATEPART` bucket definition in the `PARTITION BY` clause to match the target granularity.
- Both approaches rely on window functions partitioned by the surrogate key and ordered by timestamp. Ensure the key and timestamp columns are indexed appropriately for the partition and order operations.
- The gap threshold or time bucket definition should be a parameter supplied from solution metadata, so the same template can be applied to any time-variant object.
- Verify that the final (open-ended) row for each key is always retained. Continuous gap compacting preserves it via the `NULL` guard on `LEAD`; frequency compacting preserves it because it falls into its own bucket.

## Considerations and consequences

- Functional compacting is **lossy by design**: intermediate rows within a gap or bucket are permanently removed from the compacted result, even when they represent real, distinct changes. The original integrated data in the PSA and Satellites remains untouched, so the detail can be reconstructed if needed.
- The gap threshold or bucket size determines what is kept. Setting it too aggressively discards meaningful changes; setting it too conservatively leaves most of the granularity in place. Calibrate against the known change frequency of the source data and the consumer's requirement.
- Continuous gap compacting preserves change timing (the retained timestamps are real event timestamps). Frequency compacting introduces alignment to bucket boundaries, which shifts the apparent timing of changes within each bucket.
- Both approaches assume a consistent sort order by timestamp within each surrogate key partition. Ties on the timestamp column produce non-deterministic results; ensure timestamps are unique per key or add a secondary sort column.
- When applied inside a view or inline CTE, the window function passes over the full intermediate result set. On large data volumes, materialising the pre-compacted result before applying the filter can improve performance.

## Related patterns

- [Solution Pattern - SQL Server Family - Compacting as a Post-Process](/patterns/solution-patterns/solution-pattern-sql-server-family-compacting-as-a-post-process/) — the complementary approach: removing only rows whose values are genuinely unchanged, rather than reducing by time.
- [Design Pattern - Generic - Loading Landing Area Tables Using Record Condensing](/patterns/design-patterns/design-pattern-generic-loading-landing-area-tables-using-row-compacting/)
- [Design Pattern - Generic - Assertion and State Timelines](/patterns/design-patterns/design-pattern-generic-assertion-and-state-timelines/)
