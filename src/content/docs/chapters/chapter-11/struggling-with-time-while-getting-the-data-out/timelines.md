---
title: "Timelines"
---

:::note[In the book]
This page is referenced in *Data Engine Thinking* (Chapter 11) via `dtng.link/4pgg7`.
:::

Timelines represent the temporal evolution of data through a series of time-bounded intervals. When presenting data from the integration layer, timelines must be carefully managed to ensure accurate historical representation.

Key considerations when working with timelines:

- Aligning temporal boundaries across multiple time-variant objects
- Preserving temporal integrity when joining entities with different change frequencies
- Managing timeline gaps and overlaps during data consolidation

This section covers patterns for working with timelines in the presentation layer:

- **Joining two time-variant objects**: [example](/chapters/chapter-11/struggling-with-time-while-getting-the-data-out/joining-two-time-variant-objects/).
- **Combining multiple time-variant objects**: [example](/chapters/chapter-11/struggling-with-time-while-getting-the-data-out/combining-multiple-time-variant-objects/).
- **Compacting in the presentation layer**: [example](/chapters/chapter-11/struggling-with-time-while-getting-the-data-out/compacting-in-the-presentation-layer/).
