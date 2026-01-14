# Granularity and redundancy

Granularity determines the level of detail captured in snapshots, while redundancy refers to the repetition of unchanged data across consecutive snapshots. Balancing these factors is crucial for efficient storage and meaningful analysis.

Key considerations:

- Snapshot frequency impacts both granularity and storage requirements
- Redundant data can be eliminated through compacting techniques
- Finer granularity enables more detailed temporal analysis
- Coarser granularity reduces storage but may lose temporal precision

> [!NOTE]
> SQL samples are provided as-is. See [Disclaimer](xref:disclaimer).

[!code-sql[](granularity-and-redundancy-snippet-1.sql)]
