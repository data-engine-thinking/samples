# Creating a dimension from integration layer objects

```sql
SELECT
  <Final column formatting and aliasing>
FROM
(
  SELECT
    <Checksum comparison>
  FROM
  (
    SELECT
      <Checksum preparation>
    FROM
    (
      SELECT
        <Integration layer column selection>
      FROM
      (
        SELECT
          <Derive time periods>
        FROM
        (
          <Combine all from timestamp values>
        ) Timestamps
      ) Timeperiods
      JOIN <Integration layer objects>
    ) Timelines
  ) Calculate_Checksum
) Final
WHERE <Checksum comparison filter>
```