---
title: "Design Patterns"
sidebar:
  order: 1
---

:::note[In the book]
This page is referenced in *Data Engine Thinking* (Chapter 9) via `dtng.link/o85bw`.
:::

The Persistent Staging Area (PSA) is an insert-only, time-stamped administration of all original transactions presented to the data solution, ordered by time of arrival — the historical record that makes downstream layers reloadable and refactorable. Its design rationale and structure are documented in the [Design Pattern - Generic - Persistent Staging Area](/patterns/design-patterns/design-pattern-generic-persistent-staging-area/).
