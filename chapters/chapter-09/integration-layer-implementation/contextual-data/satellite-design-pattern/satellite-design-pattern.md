# Satellite design pattern

Satellites store the descriptive context and history for Hubs and Links. They capture the attributes that change over time, enabling full auditability and temporal analysis of business data.

Key characteristics of Satellites:

- Contains descriptive attributes and temporal metadata
- Tracks changes over time using inscription timestamps (unitemporal) or business effective dates (bitemporal)
- Supports record compacting to eliminate redundant data
- Can be split by rate of change, source system, or attribute grouping

This section covers the automation patterns for preparing and loading Satellites, including both unitemporal and bitemporal approaches.