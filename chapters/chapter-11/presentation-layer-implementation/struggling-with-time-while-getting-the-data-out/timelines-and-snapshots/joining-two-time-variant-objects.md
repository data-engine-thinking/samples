# Joining two time-variant objects

Joining time-variant objects requires careful alignment of temporal boundaries to ensure accurate historical representation. When two entities with independent change histories are combined, their timelines must be synchronized to create valid temporal intersections.

Key considerations when joining time-variant objects:

- Temporal boundaries must be aligned across both objects
- The resulting timeline reflects the intersection of validity periods
- New timeline segments are created at each boundary change
- Null handling for periods where one object has no valid data

> [!NOTE]
> SQL samples are provided as-is. See [Disclaimer](xref:disclaimer).

[!code-sql[](joining-two-time-variant-objects-snippet-1.sql)]
