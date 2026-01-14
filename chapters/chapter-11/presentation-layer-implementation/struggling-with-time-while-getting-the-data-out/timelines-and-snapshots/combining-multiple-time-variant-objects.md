# Combining multiple time-variant objects

Combining multiple time-variant objects extends the principles of joining two objects to scenarios involving three or more temporal entities. This is common when building presentation layer views that aggregate data from multiple Satellites or other time-variant sources.

Key considerations when combining multiple time-variant objects:

- Timeline complexity increases with each additional object
- All temporal boundaries must be considered for segmentation
- Performance optimization becomes critical with many objects
- Consider using Point-In-Time (PIT) tables to pre-compute combinations

> [!NOTE]
> SQL samples are provided as-is. See [Disclaimer](xref:disclaimer).

[!code-sql[](combining-multiple-time-variant-objects-snippet-1.sql)]
