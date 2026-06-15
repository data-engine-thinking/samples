---
title: "Compacting in the Presentation Layer"
---

:::note[In the book]
This page is referenced in *Data Engine Thinking* (Chapter 11) via `dtng.link/a8j0r`.
:::

Compacting in the presentation layer eliminates redundant records where attribute values remain unchanged across consecutive time periods. This reduces storage requirements and improves query performance while preserving temporal accuracy.

Compacting is typically applied after joining time-variant objects, as the join operation often creates segments with identical attribute values that can be consolidated.

The two approaches are documented as the [Solution Pattern - SQL Server Family - Functional Compacting](/patterns/solution-patterns/solution-pattern-sql-server-family-functional-compacting/).
