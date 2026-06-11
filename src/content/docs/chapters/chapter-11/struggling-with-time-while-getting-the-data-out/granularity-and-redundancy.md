---
title: "Granularity and Redundancy"
---

:::note[In the book]
This page is referenced in *Data Engine Thinking* (Chapter 11) via `dtng.link/b0zlj`.
:::

Granularity determines the level of detail captured in snapshots, while redundancy refers to the repetition of unchanged data across consecutive snapshots. Balancing these factors is crucial for efficient storage and meaningful analysis.

Key considerations:

- Snapshot frequency impacts both granularity and storage requirements
- Redundant data can be eliminated through compacting techniques
- Finer granularity enables more detailed temporal analysis
- Coarser granularity reduces storage but may lose temporal precision

:::note
SQL samples are provided as-is. See [disclaimer](/disclaimer/)
:::

```sql file=<rootDir>/chapters/chapter-11/presentation-layer-implementation/struggling-with-time-while-getting-the-data-out/timelines-and-snapshots/granularity-and-redundancy-snippet-1.sql
```
