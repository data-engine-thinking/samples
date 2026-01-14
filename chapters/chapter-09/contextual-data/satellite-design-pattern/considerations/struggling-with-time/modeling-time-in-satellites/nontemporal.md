# Nontemporal

Nontemporal modeling stores only the current state of data without maintaining historical versions. While this simplifies storage and querying, it sacrifices the ability to track changes over time.

Key characteristics of nontemporal approaches:

- Stores only the most recent version of each record
- No inscription timestamp tracking for historical queries
- Lower storage requirements compared to temporal approaches
- Suitable for reference data that rarely changes
- Does not support point-in-time analysis or audit requirements

Nontemporal approaches are generally discouraged in Data Vault implementations, as they contradict the core principle of maintaining complete historical context. However, they may be appropriate for specific use cases where history is genuinely not required.