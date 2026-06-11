---
title: "Design Pattern - Generic - Persistent Staging Area"
---

## Purpose

This Design Pattern describes the Persistent Staging Area (PSA): an insert-only, time-stamped administration of all original transactions that have been presented to the data solution through its interfaces with operational systems, ordered by time of arrival.

## Motivation

Being insert-only, no information in the PSA is ever deleted or updated. This is how the PSA provides a historical record of all data that was ever presented to the data solution, in its raw form.

That record is what makes the rest of the solution refactorable: the events (transactions) can be reprocessed to 'replay history' in a deterministic way. Reprocessing — reinitialization — simply means running the input through the (updated) logic again to recalculate the output. The PSA is therefore an important component in virtualisation, disaster recovery, and reinitialisation when parts of the data solution have to be reloaded.

## Applicability

The PSA is an optional area within the staging layer, but strongly recommended. It is technology-agnostic: a PSA does not need to be a set of database tables — it can equally be a streaming topic or subscription, an archive of files, or any mix thereof. Its relatively simple structure also makes it straightforward to migrate between platforms.

## Structure

The PSA receives its data from the incoming interfaces (usually via the Landing Area) and stores it as-is, extended with the staging layer's standard attributes: the inscription timestamp, the record order, the source timestamp, the change data indicator, and a checksum for change detection.

There are two ways to approach PSA design, regardless of the technical platform:

* **Stacking** — receiving and storing snapshots.
* **Delta-based (transactional)** — receiving or deriving the data differential.

The delta-based PSA is the recommended approach, as it offers the most flexibility and scalability. Designed this way, the PSA closely aligns with the concept of an application-readable transaction log, which enables a data solution that operates fully in parallel: each data logistics process can run continuously and independently, while data remains consistently delivered — eventual consistency.

## Implementation guidelines

* Keep the PSA insert-only and the data raw. Transformation belongs downstream; the PSA's value is the unmodified record of what was received, when.
* Store the data delta rather than full snapshots where possible; where a source can only deliver full extracts, derive the delta on the way in (see the Landing Area patterns).
* Time-stamp and sequence everything: the inscription timestamp, record order, and source timestamp make the administration deterministic and replayable.
* Record logical deletes as transactions (a change data indicator), not as removals.
* Treat the PSA as the foundation for reprocessing: downstream layers should be reloadable from the PSA at any time, which keeps refactoring safe and cheap.

## Considerations and consequences

* The PSA grows indefinitely by design — it trades storage for the ability to deterministically reconstruct any downstream state. Storage-efficient platforms and formats mitigate the cost.
* Implementation is comparatively easy — it is a matter of storing received data as-is — but its presence has architectural weight: with a PSA, the integration and presentation layers become disposable and re-derivable.
* The insert-only nature aligns naturally with technologies where in-place updates are expensive or unsupported.

## Related patterns

* [Design Pattern - Generic - Landing Area](/patterns/design-patterns/design-pattern-generic-landing-area/)
* [Design Pattern - Generic - Initial Load and Reinitialization](/patterns/design-patterns/design-pattern-generic-initial-load-and-reinitialization/)
* [Design Pattern - Generic - Using Checksums for Row Comparison](/patterns/design-patterns/design-pattern-generic-using-checksums/)
* [Solution Pattern - SQL Server Family - Persistent Staging Area](/patterns/solution-patterns/solution-pattern-sql-server-family-persistent-staging-area/)
