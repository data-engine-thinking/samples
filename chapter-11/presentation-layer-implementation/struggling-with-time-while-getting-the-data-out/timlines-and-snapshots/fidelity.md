# Fidelity

```sql
WITH [Sample] AS
(
  SELECT '100\@|' AS SURROGATE_KEY,
         NULL AS COLUMN_VALUE,
         CONVERT(DATETIME2(7),'1900-01-01') AS FROM_TIMESTAMP,
         CONVERT(DATETIME2(7),'2025-02-01') AS BEFORE_TIMESTAMP
  UNION
  SELECT '100\@|' AS SURROGATE_KEY,
         'A' AS COLUMN_VALUE,
         CONVERT(DATETIME2(7),'2025-02-01') AS FROM_TIMESTAMP,
         CONVERT(DATETIME2(7),'2025-02-15') AS BEFORE_TIMESTAMP
  UNION
  SELECT '100\@|' AS SURROGATE_KEY,
         'B' AS COLUMN_VALUE,
         CONVERT(DATETIME2(7),'2025-02-15') AS FROM_TIMESTAMP,
         CONVERT(DATETIME2(7),'2025-03-20') AS BEFORE_TIMESTAMP
  UNION
  SELECT '100\@|' AS SURROGATE_KEY,
         'C' AS COLUMN_VALUE,
         CONVERT(DATETIME2(7),'2025-03-20') AS FROM_TIMESTAMP,
         CONVERT(DATETIME2(7),'2025-09-20') AS BEFORE_TIMESTAMP
  UNION
  SELECT '100\@|' AS SURROGATE_KEY,
         'D' AS COLUMN_VALUE,
         CONVERT(DATETIME2(7),'2025-09-20') AS FROM_TIMESTAMP,
         CONVERT(DATETIME2(7),'9999-12-31') AS BEFORE_TIMESTAMP
)
,[Dates] AS
(
    -- Create a list of 12 months (end-of-month timestamps)
    SELECT [Snapshot Timestamp] = EOMONTH(CONVERT(DATETIME2(7),'2025-01-31'))
    UNION ALL
    SELECT [Snapshot Timestamp] = EOMONTH(DATEADD(MONTH, 1, [Snapshot Timestamp]))
    FROM DATES
    WHERE [Snapshot Timestamp] < CONVERT(DATETIME2(7),'2025-12-31')
)
,[Snapshots] AS
(
  SELECT * FROM [Sample]
  JOIN [Dates]
   ON  [Snapshot Timestamp] >= FROM_TIMESTAMP
   AND [Snapshot Timestamp] < BEFORE_TIMESTAMP
)
,[Checksum_CTE] AS
(
  -- Create a checksum for record comparison
  SELECT
    HASHBYTES('SHA1',
      COALESCE(TRIM(CONVERT(NVARCHAR(MAX),COLUMN_VALUE)), '~!@|N/A') + '\@|'
    ) AS [Checksum],
    *
  FROM Snapshots
)
,[PreviousChecksum] AS
(
  -- Query the previous checksum using LAG()
  SELECT
    SURROGATE_KEY,
    COLUMN_VALUE,
    FROM_TIMESTAMP,
    [Checksum],
    LAG([Checksum])
    OVER (PARTITION BY SURROGATE_KEY
          ORDER BY FROM_TIMESTAMP)
    AS [Previous_Checksum]
  FROM [Checksum_CTE]
),
Compacting AS
(
  -- Remove redundant records
  SELECT
    SURROGATE_KEY,
    COLUMN_VALUE,
    FROM_TIMESTAMP,
    [Checksum],
    [Previous_Checksum]
  FROM PreviousChecksum
  WHERE [Previous_Checksum] IS NULL OR [Checksum] != [Previous_Checksum]
)
-- Display the final results
SELECT
    SURROGATE_KEY,
    COLUMN_VALUE,
    FROM_TIMESTAMP,
    LEAD(FROM_TIMESTAMP,1,'9999-12-31')
    OVER (PARTITION BY SURROGATE_KEY
          ORDER BY FROM_TIMESTAMP ASC)
    AS BEFORE_TIMESTAMP
FROM Compacting
```