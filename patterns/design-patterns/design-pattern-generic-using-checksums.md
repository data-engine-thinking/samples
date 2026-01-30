---
uid: design-pattern-generic-using-checksums
---

# Design Pattern - Generic - Using checksums for row comparison

## Purpose

This Design Pattern aims to clarify and support the implementation of checksum values for record comparisons.

## Motivation

When comparing a record, or a part of a record, in a database table or file with another one, each column can be compared individually to determine if there are differences between the two records. A checksum provides the same functionality, but by comparing a single value that represents the record's contents.

Checksums can provide a performance and maintenance efficient method for detecting changes. A fundamental design principle of the data logistics Framework is restartability and the general ability for data logistics to be run at any time. A key design decision to support this principle is the implementation of multiple change detection mechanisms to avoid duplicate inserts, for instance when data logistics is executed multiple times for the same source set.

Also known as:

* Delta detection.
* Hash-based change detection (CRC, hash bytes).

## Applicability

This pattern is applicable to any data logistics process that performs record comparisons against historical records. In some cases it may be required to calculate the checksum in the Landing Area as well, for instance as part of a Full Outer Join interface or Disaster Recovery for native CDC.

## Structure

Checksums are typically created using a hashing algorithm. A hashing algorithm, also known as a cryptographic hash, provides a one-way encryption of its input values. 'Hashing,' the process of encrypting input data values into a hash value, is widely used to securely transfer data, assess data integrity, and authenticate. The recipient of a hash value can verify the data contents without actually having to view these. For instance, if you intend to send a bank account number without transferring the actual number, you can ‘hash’ the bank account details using a cryptographic hashing algorithm and send only the hashed value. The recipient can validate the contents by applying the same hash algorithm to the number they hold. If the hash values match, the sent data must contain the same value.

Similarly, a hash value is often used to ensure data integrity when sending a large amount of data, files, or binaries. By sending the data accompanied by the hash value, the recipient can ensure that all intended data arrived correctly by comparing the hash value to 

The key aspect regarding the role of record comparisons (with or without using checksums to achieve this) is to be aware of the role the Change Data Indicator plays. The possible scenarios are listed in the table below:

| Process | Approach | Reasoning |
|---------|----------|-----------|
| Source-to-Staging (e.g., Full Outer Join or Disaster Recovery) | Checksum is created and stored in the Landing Area table. | The checksum does not need to be recalculated from Staging to History as the full outer join process will always correctly identify the Change Data Indicator. In case of a Logical Delete, all attributes will retain their last known value (copied from the Persistent Staging Area table) - thus the checksum will be calculated with these values. |
| Source to Staging (CDC, push or pull) | No checksums are required. | Other interfaces rely on load windows to select the delta sets. |
| Staging to History | If the checksum is available in the Landing Area the value can be copied into the Persistent Staging Area. Otherwise the checksum is calculated based on the source attributes. | Checksum values can be identical between inserts/updates and records that have been identified as a logical delete. Therefore record comparison must include the Change Data Indicator. If the checksums are different or the checksums are the same but the Change Data Indicator is different, continue the SCD2 operation. If the checksums are identical and the Change Data Indicator is the same as well, discard (filter). |
| Staging to Integration | The checksum is always calculated within the Staging to Integration data logistics process based on the necessary attributes in the Landing Area table. This also requires the Change Data Indicator to be part of the checksum attributes. | The comparison is executed based on the new checksum and the existing Integration Area checksum. As with the Staging to History process the Change Data Indicator is evaluated to identify Logical Deletes, but in this scenario this happens as part of the checksum creation (i.e. source attributes and the Change Data Indicator will be the new checksum). |

## Implementation guidelines

* Decide where to compute checksums: at ingestion for change capture (FOJ, CDC recovery) and/or before integration for SCD2 detection.
* Include the Change Data Indicator when comparing checksums to distinguish logical deletes from unchanged values.
* Normalize inputs (trimming, case handling, date formats, NULL placeholders) before hashing to avoid false deltas.
* Pick algorithms based on collision risk and storage: don't overdo the strength of the algorithm. In most cases SHA1 for integration if more than sufficient.
* Fall back to attribute-by-attribute comparison if the platform lacks stable hashing or collision risk is unacceptable.
* Store checksums as persisted columns to speed comparison and aid troubleshooting.

## Considerations and consequences

* Hash collisions, while rare with strong algorithms, are possible; critical datasets may require periodic reconciliation beyond checksums.
* Poor input normalization can inflate change rates and load times; standardize before hashing.
* Overuse of wide hashes increases storage and bandwidth; balance precision and cost.

## Related patterns

* [Design Pattern - Data Vault - Loading Satellite tables](xref:design-pattern-data-vault-satellite).