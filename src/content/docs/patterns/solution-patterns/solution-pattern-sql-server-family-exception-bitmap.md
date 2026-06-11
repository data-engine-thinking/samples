---
title: "Solution Pattern - SQL Server Family - Exception Bitmap"
---

## Purpose

This Solution Pattern shows how to record the outcome of multiple data quality checks in a single integer — an exception bitmap — and how to decode that integer back into the individual exceptions using a bitwise join.

## Motivation

A traditional approach to data quality checking separates erroneous records into reject tables. This forces a single, central decision about what is acceptable: a record is either in or out.

An exception bitmap takes a different approach. The outcome of every check is encoded into one integer — one bit per check — and stored with the record. Records are not rejected; instead, each consuming party can decide which exceptions it considers acceptable, filtering on the bits that matter for its purpose.

## Applicability

This pattern applies wherever a set of data quality checks is evaluated per record and the results must travel with the data — for example, in the integration layer's testing framework. It is most useful when different consumers legitimately apply different quality standards to the same data.

## Structure

Each check is evaluated as a single bit, the bits are combined into one integer, and a bitwise join decodes the integer back into the individual exceptions:

* A check is expressed as a condition that yields `1` when the error is detected and `0` otherwise.
* Each check is assigned a fixed bit position; the bitmap is the sum of the detected bits weighted by their position values (1, 2, 4, 8, …).
* A reference table maps each bit mask value to the description of the check.
* The bitwise join compares the stored bitmap against each bit mask in the reference table, returning one row per detected exception.

```sql file=<rootDir>/patterns/solution-patterns/solution-pattern-sql-server-family-exception-bitmap-snippet-1.sql
```

## Implementation guidelines

* Assign each check a fixed, documented bit position, and never reuse a position for a different check — the stored bitmaps are only interpretable as long as the positions remain stable.
* Maintain the checks and their bit positions in a reference table (bit mask value plus description), so the decoding join and any reporting derive from one place.
* Generate the per-check expressions and the weighted sum from metadata, so adding a check means adding a metadata entry and a bit position rather than rewriting the statement.
* The bitwise AND syntax varies by platform: the example uses a `BITAND`-style function; on SQL Server the `&` operator performs the same comparison (`reject.error_code & error_table.bit_mask_value`).
* A value of `0` means the record passed every check, which makes filtering for clean records trivial.

## Considerations and consequences

* The integer's width bounds the number of checks: 8 bits are shown in the example; an `INT` accommodates 31 checks and a `BIGINT` 63. Beyond that, multiple bitmap columns or a different encoding is needed.
* Because records are never rejected, downstream processes must actively apply their own acceptance filter — the pattern shifts responsibility for quality decisions to the consumers, which is its intent.
* New checks can be added without affecting existing data: historical bitmaps simply have the new bit unset. Reinterpreting history against new checks, however, requires re-evaluation.
* The bitmap records *that* a check failed, not the offending values themselves; detailed diagnosis still requires inspecting the record against the check definition.

## Related patterns

* [Design Pattern - Generic - Control Framework](/patterns/design-patterns/design-pattern-generic-control-framework/)
