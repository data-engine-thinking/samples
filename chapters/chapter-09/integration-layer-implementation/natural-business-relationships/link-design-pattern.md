# Link design pattern

Links represent the Natural Business Relationships between Core Business Concepts (Hubs). They capture the many-to-many associations that exist in the business domain, such as the relationship between customers and orders, or products and suppliers.

Key characteristics of Links:

- Contains foreign keys to two or more Hubs
- Stores the relationship grain (the combination of business keys)
- Insert-only - relationships are never deleted, only end-dated via Link-Satellites
- Enables flexible modeling of complex business relationships

This section demonstrates the automation patterns for loading Link entities in the integration layer.