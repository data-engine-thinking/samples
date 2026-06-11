---
title: "Design Pattern - Generic - Landing Area"
---

## Purpose

This Design Pattern describes the Landing Area (LDA): the first area of the data solution where new data is encountered. The Landing Area receives — or infers — the data delta from a source interface, aligns it to the data solution conventions, and temporarily stores it together with the necessary audit details, so that it can be merged into the Persistent Staging Area (PSA) or used by further downstream processes.

## Motivation

The staging layer is responsible for the physical movement of data from external operational platforms onto the data solution platform, and for preparing that data for further processing. The Landing Area is the entry point of this layer.

Receiving new data in a dedicated, standardized area decouples the many source interfaces — each with its own options and limitations — from the rest of the architecture. Every interface can be captured, aligned, and audited in a consistent way before the data is handed off downstream.

## Applicability

This pattern applies to the source-to-staging loading processes, where data first arrives from an operational system or interface. Implementing a Landing Area is optional: when it is present, it is the first area to receive new data and meets most of the fundamental data logistics requirements. When no Landing Area is implemented, the Persistent Staging Area takes on this role.

## Structure

The Landing Area is intended to be **transient**: the detected data delta is held only briefly, until it has been processed downstream. This is a *truncate and insert* pattern — each execution overwrites the data delta from the previous run, so the 'old' data delta is removed as soon as a 'new' data delta is received by the interface.

This behavior is specific to each individual incoming interface. Every interface independently produces a new data delta that replaces the existing one for that interface, manages its own wait states and processing windows, and operates independently of the others. This independence allows for parallel processing and reduces dependencies between interfaces.

A Landing Area data object contains the same columns as the incoming source data. In addition, the following data solution columns are added:

* **Inscription timestamp** — the date and time the data arrived in the data solution.
* **Inscription record id** — the order in which the data was received by the interface that detected and ingested the change records.
* **Source timestamp** — the moment the change took place in the operational system, captured as closely as possible.
* **Change data indicator** — whether a record is a change (insert or update), or was detected as a logical delete.
* **Audit Trail Id** — a reference to the data logistics control framework instance of the process that added the data.

## Implementation guidelines

* Populate the Landing Area with data logistics processes that receive or infer the data delta for each interface.
* Use a truncate-and-insert approach, where a new execution replaces the previous data delta for that interface.
* Add the data solution audit columns (inscription timestamp, inscription record id, source timestamp, change data indicator, and audit trail id) alongside the original source columns.
* Let each incoming interface manage its own processing window, so interfaces can run in parallel and independently of one another.
* Maintain the data delta until it has been fully committed to all downstream areas; only then should the next Landing Area process for that interface run.

## Considerations and consequences

Because the Landing Area is transient, there is a risk that a data delta is lost if it is overwritten before it has been committed downstream. The staging layer orchestration must therefore protect the data delta until it has been fully committed to all downstream locations. Only once every downstream area has committed the delta should the next Landing Area process prepare a new one.

If this is not enforced, a data delta may be overwritten before it is processed. This causes data loss and a difference in content between the operational systems and the data solution. Recovering from this situation requires a full comparison between the data solution and the source, resetting the delta extract timestamp on a pull interface, or restoring an earlier database backup.

It is possible to store the incoming data as-is in a separate archive, such as a file store. In this reference architecture, however, the Persistent Staging Area fulfills that role.

## Related patterns

* [Fundamental Data Logistics Requirements](/patterns/design-patterns/design-pattern-generic-fundamental-data-logistics-requirements/)
* [Handling Flat Files](/patterns/design-patterns/design-pattern-generic-handling-flat-files/)
* [Loading Landing Area Tables Using Record Condensing](/patterns/design-patterns/design-pattern-generic-loading-landing-area-tables-using-row-compacting/)
