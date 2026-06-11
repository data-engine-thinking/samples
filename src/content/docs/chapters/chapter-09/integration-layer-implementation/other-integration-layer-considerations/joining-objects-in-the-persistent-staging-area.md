---
title: "Joining Objects in the Persistent Staging Area"
---

:::note[In the book]
This page is referenced in *Data Engine Thinking* (Chapter 9) via `dtng.link/8cfug`.
:::

Combining two time-variant objects from the persistent staging area means reconciling two independent timelines into one. Because either object can change on its own date, the combined result is assembled from both points of view and merged into a single, continuous timeline.

This approach is documented as the [Solution Pattern - SQL Server Family - Joining Objects in the Persistent Staging Area](/patterns/solution-patterns/solution-pattern-sql-server-family-joining-objects-in-the-persistent-staging-area/), including three runnable variants of the SQL.
