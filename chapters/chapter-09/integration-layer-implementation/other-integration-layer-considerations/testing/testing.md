# Testing

Testing in the integration layer ensures data quality and consistency across all loaded entities. A robust testing framework validates that business rules are enforced and that data integrity is maintained throughout the loading process.

Key testing areas in the integration layer:

- **Notification**: Control framework notifications for monitoring and alerting: [example](notification.md).
- **Uniqueness**: Uniqueness controls to ensure business keys and surrogate keys remain unique: [example](uniqueness.md).
- **Completeness**: Completeness in temporality to verify all expected records are loaded: [example](completness.md).
- **Referential integrity**: Validation that all foreign key relationships are satisfied: [example](referential-integrity.md).