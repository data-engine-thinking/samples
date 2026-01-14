---
uid: design-pattern-data-vault-satellite
---

# Design Pattern - Data Vault - Satellite

## Purpose

This Design Pattern describes how to represent, or load data into, Satellite tables using Data Vault methodology.

## Motivation

Satellite tables contain the descriptive, time-variant context for a Hub or Link. They carry the changing attributes and record the full history needed for auditability and point-in-time reconstruction.

## Applicability

This pattern is applicable for loading data to Satellite tables from:

* The Landing Area into the Integration Area.
* The Integration Area into the Interpretation Area.

Interpretation Area Satellites may add business logic, but follow the same structural approach.

## Structure

The data logistics process can be described as a slowly changing dimension / history update of all attributes except the business key (which is stored in the Hub table). Most attribute values, including some of the data logistics process control values are copied from the Landing Area table. This includes:

- Inscription timestamp (used for the target effective timestamp and potentially the update timestamp attributes).
- Source Row Id.

### Optional attributes

The following attributes are commonly included in Satellite tables but are technically optional:

- **Record Source**: Can be derived from the Audit Trail Id via the control framework. Including it as a separate column provides query convenience but introduces redundancy.
- **Inscription Timestamp**: While recommended for auditability and temporal queries, this can be derived from the control framework if the Audit Trail Id is present.

The Audit Trail Id provides the essential link to the control framework, from which all process metadata can be obtained. Organizations typically include Inscription Timestamp directly in Satellites for efficient temporal querying, but this is a design choice.

## Implementation guidelines

* Multiple passes of the same source table or file are usually required: first to insert new keys in the Hub/Link, then to populate Satellites.
* Satellites are typically loaded with an insert-only SCD2 pattern: close the current record (set expiry), insert the new record with the new hash/checksum.
* Keep Satellite data logistics modular; separate insert and update branches if tool performance requires.
* Consider using checksums to detect attribute changes; avoid field-by-field comparisons where hashing is reliable.
* Maintain a dummy record per driving key to ensure complete timelines where required by downstream queries.

## Considerations and consequences

* Missing or duplicate effective/expiry dates lead to gaps/overlaps and incorrect time slicing; enforce timeline completeness.
* Excessive Satellite proliferation (too many small Satellites) can increase join complexity; balance attribute grouping with change frequency.
* Business logic in Interpretation Area Satellites should not alter raw history; keep transformations transparent and auditable.

## Related patterns

* [Design Pattern - Data Vault - Hub](xref:design-pattern-data-vault-hub).
* [Design Pattern - Data Vault - Link](xref:design-pattern-data-vault-link).
* [Design Pattern - Generic - Using checksums for row comparison](xref:design-pattern-generic-using-checksums).
* [Design Pattern - Generic - Assertion and State Timelines](xref:design-pattern-generic-assertion-and-state-timelines).
* [Design Pattern - Generic - Managing Multi-Temporality](xref:design-pattern-generic-managing-multi-temporality).
