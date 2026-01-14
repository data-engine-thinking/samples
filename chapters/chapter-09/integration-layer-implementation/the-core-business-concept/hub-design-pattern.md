# Hub design pattern

The Hub is the foundational entity in Data Vault modeling, representing the Core Business Concept (CBC). Hubs store the unique business keys that identify entities in the business domain, such as customers, products, or orders.

Key characteristics of Hubs:

- Contains only the business key and metadata (inscription timestamp, record source)
- Never changes once loaded - insert-only
- Provides a stable anchor point for all related Satellites and Links
- Enables parallel loading from multiple source systems

This section demonstrates the automation patterns for loading Hub entities in the integration layer.