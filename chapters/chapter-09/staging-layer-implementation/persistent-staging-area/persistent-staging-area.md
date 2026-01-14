# Persistent staging area pattern

The Persistent Staging Area (PSA) provides a historical archive of all data that has entered the data solution. Unlike the Landing Area which is transient, the PSA retains data indefinitely, enabling full auditability and the ability to reload downstream layers.

Key characteristics of the Persistent Staging Area:

- Maintains complete history of all source data changes
- Captures inscription timestamps and record sources for traceability
- Supports delta detection through change data capture mechanisms
- Enables reprocessing and recovery scenarios
- Provides a foundation for late-arriving data handling

This section covers the patterns for implementing and managing Persistent Staging Area tables.