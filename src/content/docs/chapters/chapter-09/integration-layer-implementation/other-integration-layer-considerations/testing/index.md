---
title: "Testing"
---

:::note[In the book]
This page is referenced in *Data Engine Thinking* (Chapter 9) via `dtng.link/7lgql`.
:::

Testing in the integration layer ensures data quality and consistency across all loaded entities. A robust testing framework validates that business rules are enforced and that data integrity is maintained throughout the loading process.

Key testing areas in the integration layer:

- **Uniqueness**: Uniqueness controls to ensure business keys and surrogate keys remain unique: [example](/chapters/chapter-09/integration-layer-implementation/other-integration-layer-considerations/testing/uniqueness/).
- **Completeness**: Completeness in temporality to verify all expected records are loaded: [example](/chapters/chapter-09/integration-layer-implementation/other-integration-layer-considerations/testing/completness/).
- **Referential integrity**: Validation that all foreign key relationships are satisfied: [example](/chapters/chapter-09/integration-layer-implementation/other-integration-layer-considerations/testing/referential-integrity/).

Recording the outcome of multiple checks in a single integer — so each consumer can apply its own quality standard — is documented as the [Solution Pattern - SQL Server Family - Exception Bitmap](/patterns/solution-patterns/solution-pattern-sql-server-family-exception-bitmap/).
