/* Drop the table, if it exists */
IF OBJECT_ID('tempdb..#Customer') IS NOT NULL DROP TABLE #Customer

/* Create the customer table */
CREATE TABLE #Customer
(
   [INSCRIPTION_TIMESTAMP] datetime2(7)
  ,[INSCRIPTION_RECORD_ID] int
  ,[SOURCE_TIMESTAMP] datetime2(7)
  ,[CHANGE_DATA_INDICATOR] char(1)
  ,[AUDIT_TRAIL_ID] int
  ,[CHECKSUM] binary(16)
  ,[CustomerID] integer NOT NULL
  ,[CategoryID] varchar(100) NOT NULL
  ,[FavouriteColour] varchar(100) NULL
  ,[EffectiveDate] date NULL
)

INSERT INTO #Customer
SELECT
   [INSCRIPTION_TIMESTAMP] 
  ,[INSCRIPTION_RECORD_ID]
  ,[SOURCE_TIMESTAMP]
  ,[CHANGE_DATA_INDICATOR]
  ,[AUDIT_TRAIL_ID]
  ,HASHBYTES('MD5',
      ISNULL(RTRIM(CONVERT(NVARCHAR(MAX),[CustomerID])), 'N/A') + '#~!' +
      ISNULL(RTRIM(CONVERT(NVARCHAR(MAX),[CategoryID])), 'N/A') + '#~!' +
      ISNULL(RTRIM(CONVERT(NVARCHAR(MAX),[FavouriteColour])), 'N/A') + '#~!' +
      ISNULL(RTRIM(CONVERT(NVARCHAR(MAX),[EffectiveDate])), 'N/A') + '#~!'
   ) AS [CHECKSUM]
  ,[CustomerID]
  ,[CategoryID]
  ,[FavouriteColour]
  ,[EffectiveDate]
FROM
(
-- Record 1
SELECT
 CONVERT(DATETIME2(7),'2023-01-24 08:40:13')	AS [INSCRIPTION_TIMESTAMP]
,1												AS [INSCRIPTION_RECORD_ID]
,CONVERT(DATETIME2(7),'2023-01-22 18:00:00')	AS [SOURCE_TIMESTAMP]
,'C'											AS [CHANGE_DATA_INDICATOR]
,0												AS [AUDIT_TRAIL_ID]
,100											AS [CustomerID]
,'A'											AS [CategoryID]
,'Yellow'										AS [FavouriteColour]
,'2023-01-22'									AS [EffectiveDate]
UNION
-- Record 2
SELECT
 CONVERT(DATETIME2(7),'2023-03-30 01:40:00')	AS [INSCRIPTION_TIMESTAMP]
,1												AS [INSCRIPTION_RECORD_ID]
,CONVERT(DATETIME2(7),'2023-03-29 08:00:00')	AS [SOURCE_TIMESTAMP]
,'C'											AS [CHANGE_DATA_INDICATOR]
,0												AS [AUDIT_TRAIL_ID]
,100											AS [CustomerID]
,'A'											AS [CategoryID]
,'Orange'										AS [FavouriteColour]
,'2023-03-29'									AS [EffectiveDate]
UNION
-- Record 3
SELECT
 CONVERT(DATETIME2(7),'2023-06-22 07:00:00')	AS [INSCRIPTION_TIMESTAMP]
,1												AS [INSCRIPTION_RECORD_ID]
,CONVERT(DATETIME2(7),'2023-06-22 05:00:00')	AS [SOURCE_TIMESTAMP]
,'C'											AS [CHANGE_DATA_INDICATOR]
,0												AS [AUDIT_TRAIL_ID]
,100											AS [CustomerID]
,'A'											AS [CategoryID]
,'Purple'										AS [FavouriteColour]
,'2023-06-22'									AS [EffectiveDate]
) sub

SELECT * FROM #Customer

/* Category */

/* Drop the table, if it exists */
IF OBJECT_ID('tempdb..#Category') IS NOT NULL DROP TABLE #Category

/* Create the category table */
CREATE TABLE #Category
(
   [INSCRIPTION_TIMESTAMP] datetime2(7)
  ,[INSCRIPTION_RECORD_ID] int
  ,[SOURCE_TIMESTAMP] datetime2(7)
  ,[CHANGE_DATA_INDICATOR] char(1)
  ,[AUDIT_TRAIL_ID] int
  ,[CHECKSUM] binary(16)
  ,[CategoryID] varchar(100) NOT NULL
  ,[CategoryGroupID] varchar(100) NULL
  ,[CategoryName] varchar(100) NULL
  ,[EffectiveDate] date NULL
)

INSERT INTO #Category
SELECT
   [INSCRIPTION_TIMESTAMP] 
  ,[INSCRIPTION_RECORD_ID]
  ,[SOURCE_TIMESTAMP]
  ,[CHANGE_DATA_INDICATOR]
  ,[AUDIT_TRAIL_ID]
  ,HASHBYTES('MD5',
      ISNULL(RTRIM(CONVERT(NVARCHAR(MAX),[CategoryID])), 'N/A') + '#~!' +
      ISNULL(RTRIM(CONVERT(NVARCHAR(MAX),[CategoryGroupID])), 'N/A') + '#~!' +
      ISNULL(RTRIM(CONVERT(NVARCHAR(MAX),[CategoryName])), 'N/A') + '#~!' +
      ISNULL(RTRIM(CONVERT(NVARCHAR(MAX),[EffectiveDate])), 'N/A') + '#~!'
   ) AS [CHECKSUM]
  ,[CategoryID]
  ,[CategoryGroupID]
  ,[CategoryName]
  ,[EffectiveDate]
FROM
(
-- Record 1
SELECT
 CONVERT(DATETIME2(7),'2018-01-01 00:00:00')	AS [INSCRIPTION_TIMESTAMP]
,1												AS [INSCRIPTION_RECORD_ID]
,CONVERT(DATETIME2(7),'2018-01-01 00:00:00')	AS [SOURCE_TIMESTAMP]
,'C'											AS [CHANGE_DATA_INDICATOR]
,0												AS [AUDIT_TRAIL_ID]
,'A'											AS [CategoryID]
,'Group10'										AS [CategoryGroupID]
,'FirstCategoryName'							AS [CategoryName]
,'2018-01-01'									AS [EffectiveDate]
UNION
-- Record 2
SELECT
 CONVERT(DATETIME2(7),'2020-01-01 00:00:00')	AS [INSCRIPTION_TIMESTAMP]
,1												AS [INSCRIPTION_RECORD_ID]
,CONVERT(DATETIME2(7),'2020-01-01 00:00:00')	AS [SOURCE_TIMESTAMP]
,'C'											AS [CHANGE_DATA_INDICATOR]
,0												AS [AUDIT_TRAIL_ID]
,'A'											AS [CategoryID]
,'Group10'										AS [CategoryGroupID]
,'SecondCategoryName'							AS [CategoryName]
,'2020-01-01'									AS [EffectiveDate]
UNION
-- Record 3
SELECT
 CONVERT(DATETIME2(7),'2023-02-01 00:00:00')	AS [INSCRIPTION_TIMESTAMP]
,1												AS [INSCRIPTION_RECORD_ID]
,CONVERT(DATETIME2(7),'2023-02-01 00:00:00')	AS [SOURCE_TIMESTAMP]
,'C'											AS [CHANGE_DATA_INDICATOR]
,0												AS [AUDIT_TRAIL_ID]
,'A'											AS [CategoryID]
,'Group10'										AS [CategoryGroupID]
,'ThirdCategoryName'							AS [CategoryName]
,'2023-02-01'									AS [EffectiveDate]
UNION
-- Record 4
SELECT
 CONVERT(DATETIME2(7),'2024-01-01 00:00:00')	AS [INSCRIPTION_TIMESTAMP]
,1												AS [INSCRIPTION_RECORD_ID]
,CONVERT(DATETIME2(7),'2024-01-01 00:00:00')	AS [SOURCE_TIMESTAMP]
,'C'											AS [CHANGE_DATA_INDICATOR]
,0												AS [AUDIT_TRAIL_ID]
,'A'											AS [CategoryID]
,'Group10'										AS [CategoryGroupID]
,'FourthCategoryName'							AS [CategoryName]
,'2024-01-01'									AS [EffectiveDate]
) sub

SELECT * FROM #Category

/* Join Query */

SELECT 
	 *
	,LEAD(EffectiveDate,1,'9999-12-31') OVER (PARTITION BY CustomerId ORDER BY EffectiveDate ASC) AS EffectiveBeforeDate
FROM 
(
/* Customer perspective*/
SELECT
  cust.EffectiveDate
 ,cust.INSCRIPTION_TIMESTAMP
 ,cust.SOURCE_TIMESTAMP
 ,cust.AUDIT_TRAIL_ID
 ,cust.INSCRIPTION_RECORD_ID
 ,cust.CHANGE_DATA_INDICATOR
 ,cust.CustomerID
 ,cust.FavouriteColour 
 ,cat.CategoryID
 ,cat.CategoryName
FROM #Customer cust
LEFT JOIN
(
       SELECT
        EffectiveDate AS START_DATE_KEY
	   ,LEAD(EffectiveDate,1,'9999-12-31') OVER (PARTITION BY CategoryId ORDER BY EffectiveDate ASC) AS END_DATE_KEY
	   ,*
       FROM #Category
) cat
ON cust.CategoryID = cat.CategoryId       
AND cust.EffectiveDate >= cat.START_DATE_KEY AND cust.EffectiveDate < cat.END_DATE_KEY 

UNION ALL
 
/* Category perspective*/
SELECT
  cat.EffectiveDate
 ,cat.INSCRIPTION_TIMESTAMP
 ,cat.SOURCE_TIMESTAMP
 ,cat.AUDIT_TRAIL_ID
 ,cat.INSCRIPTION_RECORD_ID
 ,cat.CHANGE_DATA_INDICATOR
 ,cust.CustomerID
 ,cust.FavouriteColour 
 ,cat.CategoryID
 ,cat.CategoryName
FROM #Category cat
INNER JOIN
(
       SELECT
        EffectiveDate AS START_DATE_KEY
	   ,LEAD(EffectiveDate,1,'9999-12-31') OVER (PARTITION BY CustomerId ORDER BY EffectiveDate ASC) AS END_DATE_KEY
	   ,*
       FROM #Customer 
) cust
ON cat.CategoryID = cust.CategoryID 
AND cat.EffectiveDate >= cust.START_DATE_KEY AND cat.EffectiveDate < cust.END_DATE_KEY  
) final
ORDER BY 1
