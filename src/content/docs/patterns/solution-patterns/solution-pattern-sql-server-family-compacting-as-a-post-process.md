---
title: "Solution Pattern - SQL Server Family - Compacting as a Post-Process"
---

## Purpose

This Solution Pattern shows how to reduce the number of records in a time-variant result set by eliminating redundant segments — periods where attribute values are unchanged — after a join or timeline construction step. Two complementary approaches are provided: continuous gap compacting and frequency compacting.

## Motivation

When multiple Satellites with different change frequencies are joined into a unified timeline, the join typically produces rows where all attribute values are identical across consecutive periods. These segments arise from the mechanics of the join rather than from genuine business changes. Carrying them into the presentation layer increases storage costs, slows queries, and adds rows that convey no additional information to downstream consumers.

Compacting as a post-process removes those redundant rows while leaving the genuine change history intact. It is applied after the timeline has been built, so it does not interfere with the join logic.

## Applicability

This pattern applies to SQL-based presentation layer processes that produce time-variant result sets, particularly after joining two or more Satellites or time-variant objects. It is appropriate when:

- The result contains consecutive rows with identical attribute values that are a by-product of the join rather than real changes.
- The downstream consumer requires a lower temporal granularity than the raw integrated data provides.
- Storage reduction or query performance in the presentation layer is a design goal.

## Structure

Two compacting approaches are provided, each addressing a different redundancy type.

### Continuous gap compacting

Continuous gap compacting retains only the rows that represent genuine transitions — rows where the gap to the next row in the timeline is at or above a chosen minimum threshold, plus the final row for each key. Rows separated by a gap smaller than the threshold are considered redundant and are discarded.

The implementation uses `LEAD` to look ahead to the next timestamp per key and `DATEDIFF` to calculate the gap. The outer filter keeps rows where the gap meets the threshold or where `LEAD` returns `NULL` (the last row).

```sql file=<rootDir>/patterns/solution-patterns/solution-pattern-sql-server-family-compacting-as-a-post-process-continuous-gap-snippet-1.sql
```

### Frequency compacting

Frequency compacting reduces temporal granularity to a fixed interval (for example, one row per hour per key). Within each time bucket, `FIRST_VALUE` ordered descending picks the most recent record, and the outer filter keeps only the rows where the original timestamp matches that selected value.

```sql file=<rootDir>/patterns/solution-patterns/solution-pattern-sql-server-family-compacting-as-a-post-process-frequency-snippet-1.sql
```

## Implementation guidelines

- Apply compacting as the final step after the join or timeline construction is complete. Earlier application may discard rows that would have been needed by the join.
- Choose **continuous gap compacting** when redundancy arises from high-frequency micro-changes and the goal is to keep only records separated by a meaningful gap. Set the gap threshold to match the granularity that downstream consumers require.
- Choose **frequency compacting** when a fixed analytical interval is needed (hourly, daily, weekly). Adjust the `DATEPART` bucket definition in the `PARTITION BY` clause to match the target granularity.
- Both approaches rely on window functions partitioned by the surrogate key and ordered by timestamp. Ensure the key and timestamp columns are indexed appropriately for the partition and order operations.
- The gap threshold or time bucket definition should be a parameter supplied from solution metadata, so the same template can be applied to any time-variant object.
- Verify that the final (open-ended) row for each key is always retained. Continuous gap compacting preserves it via the `NULL` guard on `LEAD`; frequency compacting preserves it because it falls into its own bucket.

## Considerations and consequences

- Compacting is **lossy by design**: intermediate rows within a gap or bucket are permanently removed from the compacted result. The original integrated data in the PSA and Satellites remains untouched, so the detail can be reconstructed if needed.
- The gap threshold or bucket size determines what counts as "redundant". Setting it too aggressively discards real changes; setting it too conservatively leaves most redundancy in place. Calibrate against the known change frequency of the source data.
- Continuous gap compacting preserves change timing (the retained timestamps are real event timestamps). Frequency compacting introduces alignment to bucket boundaries, which shifts the apparent timing of changes within each bucket.
- Both approaches assume a consistent sort order by timestamp within each surrogate key partition. Ties on the timestamp column produce non-deterministic results; ensure timestamps are unique per key or add a secondary sort column.
- When applied inside a view or inline CTE, the window function passes over the full intermediate result set. On large data volumes, materialising the pre-compacted result before applying the filter can improve performance.

## Related patterns

- [Design Pattern - Generic - Loading Landing Area Tables Using Record Condensing](/patterns/design-patterns/design-pattern-generic-loading-landing-area-tables-using-row-compacting/) — a related but distinct concept: condensing redundant records at intake in the Landing Area rather than as a post-process in the presentation layer.
- [Design Pattern - Generic - Assertion and State Timelines](/patterns/design-patterns/design-pattern-generic-assertion-and-state-timelines/)
