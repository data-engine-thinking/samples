---
title: "Design Pattern - Generic - Unitemporal Data"
---

## Purpose

This Design Pattern describes unitemporal data: data with a single timeline, which by default is the assertion timeline — the order in which changes were recorded by the data solution.

## Motivation

To understand how, and how often, values change — for example, tracking past and present addresses for a customer — a timeline must be added to the data. By recording a timestamp each time a change arrives, both the history of values and the frequency of change are captured.

A unitemporal data object adopts the assertion timeline, represented by the inscription timestamp: data changes are recorded in the order they arrive. This is the traditional way Satellites are documented in most Data Vault methodology.

## Applicability

This pattern applies when a single timeline is sufficient, and in particular:

* When source systems do not provide reliable business effective timestamps, making the assertion timeline the best available option.
* As the default temporal structure for tracking change history from the data solution's perspective.

## Structure

A unitemporal data object tracks change on the assertion timeline:

* The inscription timestamp marks the moment each record was persisted by the data solution.
* Changes are recorded in arrival order, supporting point-in-time queries based on when data was loaded.
* The primary key consists of the surrogate key, the inscription timestamp, and the inscription record identifier.

A state timestamp from the source may additionally be mapped, but in a unitemporal data object it is not part of the primary key and does not constitute a timeline — it is, in effect, just another descriptive attribute.

## Implementation guidelines

* Use the inscription timestamp (assertion timeline) as the single timeline. A data object can technically also be unitemporal on the state timeline — using the business timestamp instead of the inscription timestamp — but this is not recommended: it tightly couples the data solution to the operational system, so retrospectively modified or added state timestamps directly impact the solution.
* Include the inscription record identifier in the primary key, so multiple changes arriving with the same inscription timestamp remain uniquely identifiable.
* Be aware that arrival order does not necessarily match the order in which changes actually occurred in the business. A late-arriving older change can make the most recently loaded value appear to be the most current one.

## Considerations and consequences

* Unitemporal structures are simpler to implement and load than bitemporal ones, and they are sufficient when the load order is the only timeline of interest.
* Any questions about *when a value was valid in the business* — rather than when it was received — cannot be fully answered within a unitemporal data object. If state timestamps are carried as attributes, the state timeline they imply is not managed and may be incomplete (overlaps and gaps are not resolved).
* These bitemporal concerns do not disappear: in a unitemporal design they shift downstream, to be addressed when data is combined and delivered out of the integration layer. A bitemporal design resolves them upfront, when loading the data.

## Related patterns

* [Design Pattern - Generic - Nontemporal Data](/patterns/design-patterns/design-pattern-generic-nontemporal-data/)
* [Design Pattern - Generic - Bitemporal Data](/patterns/design-patterns/design-pattern-generic-bitemporal-data/)
* [Design Pattern - Generic - Assertion and State Timelines](/patterns/design-patterns/design-pattern-generic-assertion-and-state-timelines/)
* [Design Pattern - Data Vault - Satellite](/patterns/design-patterns/design-pattern-data-vault-satellite/)
* [Solution Pattern - SQL Server Family - Data Vault Satellite](/patterns/solution-patterns/solution-pattern-sql-server-family-data-vault-satellite/)
