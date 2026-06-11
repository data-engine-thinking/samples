---
title: "Design Patterns"
sidebar:
  order: 1
---

:::note[In the book]
This page is referenced in *Data Engine Thinking* (Chapter 9) via `dtng.link/sqyik` and `dtng.link/30s91`.
:::

The Satellite stores the descriptive context and history for Hubs and Links: the attributes that change over time, enabling full auditability and temporal analysis of business data. Its design rationale and structure are documented in the [Design Pattern - Data Vault - Satellite](/patterns/design-patterns/design-pattern-data-vault-satellite/).

## Modeling time in Satellites

Temporal modeling is a fundamental consideration when designing Satellites. The choice of temporal approach determines how historical data is captured, queried, and maintained throughout the lifecycle of the data solution. Three primary approaches exist, each documented as a design pattern:

- [Design Pattern - Generic - Nontemporal Data](/patterns/design-patterns/design-pattern-generic-nontemporal-data/): no historical tracking, only current state is maintained.
- [Design Pattern - Generic - Unitemporal Data](/patterns/design-patterns/design-pattern-generic-unitemporal-data/): tracks history using inscription timestamps only.
- [Design Pattern - Generic - Bitemporal Data](/patterns/design-patterns/design-pattern-generic-bitemporal-data/): tracks both inscription and state timestamps.

The appropriate choice depends on business requirements, source system capabilities, and the need for temporal analysis and auditability. For a detailed explanation of the underlying temporal concepts, see [Assertion and State Timelines](/patterns/design-patterns/design-pattern-generic-assertion-and-state-timelines/).
