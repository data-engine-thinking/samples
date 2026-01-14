# Bitemporal

Bitemporal modeling tracks two independent timelines: the inscription timestamp (when data was recorded) and the business effective date (when the change actually occurred in the real world).

Key characteristics of bitemporal Satellites:

- Captures both technical and business time dimensions
- Enables "as-was" and "as-is" historical queries
- Supports correction of historical records without losing audit trail
- Handles late-arriving data by inserting records at their correct business time
- Provides complete temporal flexibility for regulatory and analytical requirements

Bitemporal Satellites are essential when source systems provide reliable business effective dates and when business requirements demand the ability to query data as it was known at any point in time.

Bitemporal modeling combines both the assertion timeline (inscription timestamp) and state timeline (source timestamp). For more details on these concepts, see [Assertion and State Timelines](xref:design-pattern-generic-assertion-and-state-timelines).