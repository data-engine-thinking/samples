# Design metadata example

```sql
TRUNCATE <LDA Data Object>

WITH LDA AS
(
  SELECT
    <Columns>
   ,[Checksum]
  FROM <Source Data Object>
),
PSA AS
(
  SELECT * FROM
  ( SELECT
      <Columns>
     ,[Checksum]
     ,<Row Order>
    FROM <PSA Data Object>
  ) psa
  WHERE psa <Row Order> = <most recent record> AND Change_Data_Indicator != 'D'
)
INSERT INTO <LDA Data Object>
SELECT
  CASE
     WHEN LDA.<Key> IS NULL THEN PSA.<Columns>
     ELSE LDA.<Columns>
  END AS <Columns>,
  CASE
    WHEN LDA.<Key> IS NULL THEN 'D'
    WHEN PSA.<Key> IS NULL THEN 'C'
    WHEN LDA.<Key> IS NOT NULL
        AND PSA.<Key> IS NOT NULL
        AND LDA.[Checksum] != PSA.[Checksum]
        THEN 'C'
    ELSE 'No Change'
  END AS Change_Data_Indicator
FROM LDA
FULL OUTER JOIN PSA ON PSA.<Key> = LDA.<Key>
WHERE Change_Data_Indicator != 'No Change'
```