# Preparing the Satellite

```sql
SELECT
    <compacting selection>
FROM
(
    SELECT
        <compacting preparation>
    FROM
    (
        SELECT
            <inner selection>
        FROM
    ) compacting_preparation
) compacting_selection
WHERE <compacting filter>
```