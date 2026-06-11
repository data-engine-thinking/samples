---
title: "Solution Patterns"
sidebar:
  order: 2
---

:::note[In the book]
This page is referenced in *Data Engine Thinking* (Chapter 9) via `dtng.link/d8bgw` and `dtng.link/57mbg`.
:::

The Satellite load is documented as the [Solution Pattern - SQL Server Family - Data Vault Satellite](/patterns/solution-patterns/solution-pattern-sql-server-family-data-vault-satellite/).

Deriving the before timestamp that closes each time period — end-dating — is documented separately as the [Solution Pattern - SQL Server Family - Deriving End-Dating](/patterns/solution-patterns/solution-pattern-sql-server-family-deriving-end-dating/), covering both runtime derivation and closing persisted time periods.

The pages in this section show the individual steps as runnable examples:

- [Preparing the Satellite](/chapters/chapter-09/integration-layer-implementation/context/preparing-the-satellite/)
- [Loading a Unitemporal Satellite](/chapters/chapter-09/integration-layer-implementation/context/loading-a-unitemporal-satellite/)
- [Loading a Bitemporal Satellite](/chapters/chapter-09/integration-layer-implementation/context/loading-a-bitemporal-satellite/)
