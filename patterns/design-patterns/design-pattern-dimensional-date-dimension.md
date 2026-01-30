---
uid: design-pattern-dimensional-date-dimension
---

# Design Pattern - Dimensional Model - Date Dimension

## Purpose

This Design Pattern describes the positioning, structure and purpose of Data Solution reference information, specifically the Date Dimension.

## Motivation

Data Solutions typically require a separate dataset to resolve common descriptions or codes (descriptive information). The reference data provides additional context for the information that is sourced from the various operational systems. Reference data is typically a description of a code where the code itself is provided by the system but the description is not provided directly.

Also known as:

* User-managed data.
* Sourcing text files.

## Applicability

This pattern is applicable for the Integration Layer only.

## Structure

The key design decision is to define whether the reference data is tracked for changes over time; in other words, whether the table is modelled as Type 1 (current state only) or Type 2 (history-tracked).

## Implementation guidelines

* Maintain a clear landing directory per source system for reference data.
* Ensure each source directory has an archive to retain received files.

## Considerations and consequences

* Choosing not to copy data types from file definitions requires explicit checks and conversions in the data logistics process later.
* Known uses: none documented.

## Related patterns

* [Design Pattern 015 - Generic - Loading Landing Area tables](xref:design-pattern-staging-layer-landing-area).
