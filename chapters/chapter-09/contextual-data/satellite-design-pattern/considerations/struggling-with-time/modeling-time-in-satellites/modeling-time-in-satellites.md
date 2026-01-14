# Modeling time in Satellites

Temporal modeling is a fundamental consideration when designing Satellites. The choice of temporal approach determines how historical data is captured, queried, and maintained throughout the lifecycle of the data solution.

Three primary approaches exist for modeling time in Satellites:

- **Nontemporal**: No historical tracking, only current state is maintained: [example](nontemporal.md).
- **Unitemporal**: Tracks history using inscription timestamps only: [example](unitemporal.md).
- **Bitemporal**: Tracks both inscription timestamps and business effective dates: [example](bitemporal.md).

The appropriate choice depends on business requirements, source system capabilities, and the need for temporal analysis and auditability.
