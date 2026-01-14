# Compacting in the presentation layer

Compacting in the presentation layer eliminates redundant records where attribute values remain unchanged across consecutive time periods. This reduces storage requirements and improves query performance while preserving temporal accuracy.

Key compacting approaches:

- **Continuous gap compacting**: Merges adjacent periods with identical values
- **Frequency compacting**: Reduces granularity to a specified interval

Compacting is typically applied after joining time-variant objects, as the join operation often creates segments with identical attribute values that can be consolidated.