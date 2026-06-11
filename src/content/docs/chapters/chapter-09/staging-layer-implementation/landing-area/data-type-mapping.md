---
title: "Data Type Mapping"
sidebar:
  order: 3
---

:::note
SQL samples are provided as-is. See [disclaimer](/disclaimer/)
:::

Careless target data types silently change values when data is loaded. A `TIME` value gains a default date when cast to a timestamp, so it can only be mapped to a target `TIME` type. A high-precision `FLOAT` loses digits when forced into a fixed `NUMERIC`. And a text float can fail to convert unless it is parsed with the culture it was produced in.

The examples below reproduce each case.

```sql file=<rootDir>/chapters/chapter-09/staging-layer-implementation/landing-area/data-type-mapping.sql
```
