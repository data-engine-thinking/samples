# Joining two time-variant objects

```sql
WITH Sat1 AS (SELECT 'Lo Stagnone\@|' AS SK
,'2025-04-11' AS InscriptionTimsetamp
,'2025-04-10' AS StateFromTimestamp
,'2025-04-11' AS StateBeforeTimestamp
,'Not good' AS WindCondition
UNION ALL
SELECT 'Lo Stagnone\@|'
,'2025-04-13'
,'2025-04-11'
,'2025-04-14'
,'Great'
UNION ALL
SELECT 'Lo Stagnone\@|'
,'2025-04-14'
,'2025-04-14'
,'9999-12-31'
,'Extrem'
)
,Sat2 AS (
SELECT 'Lo Stagnone\@|' AS SK
,'2025-04-11' AS InscriptionTimsetamp
,'2025-04-10' AS StateFromTimestamp
,'2025-04-12' AS StateBeforeTimestamp
,'Sunny' AS Weather
UNION ALL
SELECT 'Lo Stagnone\@|'
,'2025-04-12'
,'2025-04-12'
,'2025-04-13'
,'Partly cloudy'
UNION ALL
SELECT 'Lo Stagnone\@|'
,'2025-04-13'
,'2025-04-13'
,'2025-04-14'
,'Cloudy'
UNION ALL
SELECT 'Lo Stagnone\@|'
,'2025-04-14'
,'2025-04-14'
,'9999-12-31'
,'Rain'

)
SELECT
  Sat1.SK, -- Hub Key
  (CASE
     WHEN Sat1.StateFromTimestamp > Sat2.StateFromTimestamp
     THEN Sat1.StateFromTimestamp
     ELSE Sat2.StateFromTimestamp
  END) AS StateFromTimestamp, -- Greatest of the two from timestamps
  (CASE
     WHEN Sat1.StateBeforeTimestamp < Sat2.StateBeforeTimestamp
     THEN Sat1.StateBeforeTimestamp
     ELSE Sat2.StateBeforeTimestamp
  END) AS StateBeforeTimestamp, -- Smallest of the two before timestamps
  Weather
  ,WindCondition
FROM Sat2
INNER JOIN Sat1
    ON Sat1.SK = sat2.SK
WHERE
 (CASE
   WHEN Sat1.StateFromTimestamp > Sat2.StateFromTimestamp
   THEN Sat1.StateFromTimestamp
   ELSE Sat2.StateFromTimestamp
  END) -- Greatest of the two from timestamps
<
 (CASE
   WHEN Sat1.StateBeforeTimestamp < Sat2.StateBeforeTimestamp
   THEN Sat1.StateBeforeTimestamp
   ELSE Sat2.StateBeforeTimestamp
  END) -- Smallest of the two before timestamps
```