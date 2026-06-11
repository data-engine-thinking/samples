---
title: "Test Generation Templates"
---

:::note
SQL samples are provided as-is. See [disclaimer](/disclaimer/)
:::

The testing checks are generated from the design metadata using Handlebars templates, so a single template produces the test SQL for every applicable data object. Each template selects the first occurrence of each mapping (`{{#if @first}}`) because, for these checks, only the target data object is needed and it is the same across all mappings in the list.

## Referential integrity

Confirms every Satellite row has a matching parent (Hub or Link) record, by counting rows for which no related key exists:

```handlebars file=<rootDir>/chapters/chapter-09/integration-layer-implementation/other-integration-layer-considerations/testing/referential-integrity-test.handlebars
```

## Temporal consistency

Detects gaps and overlaps between consecutive time ranges for the same key, by comparing each record's timestamp with the previous one:

```handlebars file=<rootDir>/chapters/chapter-09/integration-layer-implementation/other-integration-layer-considerations/testing/temporal-consistency-test.handlebars
```
