# Unitemporal

Unitemporal modeling tracks a single timeline: when data was recorded in the data solution. This is captured through the inscription timestamp, which marks the moment each record was persisted.

Key characteristics of unitemporal Satellites:

- Uses inscription timestamp as the primary temporal marker
- Tracks the history of how data changed from the data solution's perspective
- Simpler to implement than bitemporal approaches
- Suitable when business effective dates are not required or available
- Enables point-in-time queries based on when data was loaded

Unitemporal Satellites are the most common approach when source systems do not provide reliable business effective dates.