# Snapshots

Snapshots capture the state of data at specific points in time, providing a frozen view of entities for a given moment. Unlike timelines which track continuous change, snapshots represent discrete temporal observations.

Key considerations when working with snapshots:

- Determining appropriate snapshot frequency (daily, weekly, monthly)
- Balancing storage costs against analytical requirements
- Managing snapshot granularity for different use cases

This section covers patterns for working with snapshots in the presentation layer:

- **Granularity and redundancy**: Strategies for managing snapshot detail levels: [example](granularity-and-redundancy.md).
- **Fidelity**: Ensuring snapshot accuracy and consistency: [example](fidelity.md).
