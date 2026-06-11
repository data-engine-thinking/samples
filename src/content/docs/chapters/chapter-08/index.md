---
title: "Chapter 8 - Metadata, Automation, Code Generation"
---

This section contains the sample code related to chapter 8 of Data Engine Thinking: metadata, automation, and code generation.

## Sections

- [Automating Delivery](/chapters/chapter-08/automating-delivery/)

## Equivalent Load Patterns

Templates give you the freedom to express the same design in your own preferred syntax. Because the templates are independent from the design metadata, the same metadata can be rendered into different — but equivalent — code: the data model stays stable while the generated logic can change gradually and improve incrementally, without impacting the design of the data logistics overall.

Both queries below load only the new rows and return the same result set — one with `NOT EXISTS`, the other with a `LEFT OUTER JOIN`. They use the same values from the design metadata, applied in a different way by a different template.

:::note
SQL samples are provided as-is. See [disclaimer](/disclaimer/)
:::

```sql file=<rootDir>/chapters/chapter-08/equivalent-load-patterns.sql
```
