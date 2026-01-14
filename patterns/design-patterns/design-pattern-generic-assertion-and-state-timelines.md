---
uid: design-pattern-generic-assertion-and-state-timelines
---

# Design Pattern - Generic - Assertion and State Timelines

## Purpose

This design pattern explains the distinction between the assertion timeline and the state timeline, which forms the foundation for bitemporal data modeling.

## Motivation

When tracking data history, there are two fundamentally different questions we might ask:

1. **When did we learn about this?** (Assertion timeline)
2. **When did this actually happen?** (State timeline)

These two timelines are independent and serve different purposes. Understanding their distinction is essential for building data solutions that support auditability, regulatory compliance, and accurate historical analysis.

## Applicability

This pattern applies whenever:

- Historical data must be tracked for audit or compliance purposes.
- Late-arriving data or corrections must be handled without losing the original record.
- Point-in-time queries are required ("What did we know as of date X?").
- Business effective dates differ from when data was received.

## Structure

### Assertion Timeline (Technical Time)

The assertion timeline records **when data was inscribed into the data solution**. This is captured through the **inscription timestamp**.

Key characteristics:

- Immutable once set - the inscription timestamp never changes.
- Represents the data solution's perspective of when information arrived.
- Also known as: transaction time, system time, technical time.
- Used for: audit trails, regulatory compliance, system recovery.

Example: A customer address change is processed on January 15th. The inscription timestamp is January 15th, regardless of when the customer actually moved.

### State Timeline (Business Time)

The state timeline records **when something actually occurred in the real world**. This is captured through the **source timestamp** or business effective date.

Key characteristics:

- Represents the real-world perspective of when a change happened.
- May arrive late (after the actual event occurred).
- Also known as: valid time, business time, effective time.
- Used for: business reporting, analytics, understanding actual event sequences.

Example: A customer moved on January 1st but notified the company on January 15th. The source timestamp is January 1st (when they moved), while the inscription timestamp is January 15th (when we learned about it).

### Combining Both: Bitemporal Data

When both timelines are tracked together, the data is **bitemporal**. This enables powerful queries such as:

- **As-is queries**: What is the current state of the data?
- **As-was queries**: What did we know about the data at a specific point in the past?
- **As-of queries**: What was the actual state of the business at a specific point in time?
- **As-was-as-of queries**: What did we believe the business state was at time X, based on what we knew at time Y?

## Implementation Guidelines

### Unitemporal Implementation

For simpler requirements, track only the assertion timeline:

| Column | Description |
|--------|-------------|
| Inscription Timestamp | When the record was inscribed into the data solution |
| Expiry Timestamp | When the record was superseded (optional, for SCD2) |

### Bitemporal Implementation

For full temporal flexibility, track both timelines:

| Column | Description |
|--------|-------------|
| Inscription Timestamp | When the record was inscribed (assertion timeline) |
| Source Timestamp | When the change occurred in the real world (state timeline) |
| Expiry Timestamp | When the record was superseded on the assertion timeline |

### Timeline Integrity

- The assertion timeline must be monotonically increasing within a single data logistics execution.
- The state timeline may have gaps, overlaps, or out-of-order entries (reflecting real-world data arrival patterns).
- Late-arriving data creates new assertion timeline entries but may insert into historical positions on the state timeline.

## Considerations and Consequences

- **Storage**: Bitemporal data requires more storage than unitemporal approaches.
- **Complexity**: Queries against bitemporal data are more complex but more powerful.
- **Source system limitations**: Not all source systems provide reliable business effective dates; in such cases, unitemporal modeling may be the only option.
- **Corrections**: Bitemporal modeling handles corrections gracefully by creating new assertion records without modifying history.

## Related Patterns

- [Design Pattern - Generic - Managing Multi-Temporality](xref:design-pattern-generic-managing-multi-temporality).
- [Design Pattern - Data Vault - Satellite](xref:design-pattern-data-vault-satellite).
- [Design Pattern - Generic - Types of History](xref:design-pattern-generic-types-of-history).
