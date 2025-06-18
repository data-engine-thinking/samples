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

/* Category Group*/

/* Drop the table, if it exists */
IF OBJECT_ID('tempdb..#CategoryGroup') IS NOT NULL DROP TABLE #CategoryGroup

/* Create the category group table */
CREATE TABLE #CategoryGroup
(
   [INSCRIPTION_TIMESTAMP] datetime2(7)
  ,[INSCRIPTION_RECORD_ID] int
  ,[SOURCE_TIMESTAMP] datetime2(7)
  ,[CHANGE_DATA_INDICATOR] char(1)
  ,[AUDIT_TRAIL_ID] int
  ,[CHECKSUM] binary(16)
  ,[CategoryGroupID] varchar(100) NOT NULL
  ,[CategoryGroupName] varchar(100) NULL
  ,[EffectiveDate] date NULL
)

INSERT INTO #CategoryGroup
SELECT
   [INSCRIPTION_TIMESTAMP] 
  ,[INSCRIPTION_RECORD_ID]
  ,[SOURCE_TIMESTAMP]
  ,[CHANGE_DATA_INDICATOR]
  ,[AUDIT_TRAIL_ID]
  ,HASHBYTES('MD5',
      ISNULL(RTRIM(CONVERT(NVARCHAR(MAX),[CategoryGroupID])), 'N/A') + '#~!' +
      ISNULL(RTRIM(CONVERT(NVARCHAR(MAX),[CategoryGroupName])), 'N/A') + '#~!'
   ) AS [CHECKSUM]
  ,[CategoryGroupID]
  ,[CategoryGroupName]
  ,[EffectiveDate]
FROM
(
-- Record 1
SELECT
 CONVERT(DATETIME2(7),'2017-01-01 00:00:00')	AS [INSCRIPTION_TIMESTAMP]
,1												AS [INSCRIPTION_RECORD_ID]
,CONVERT(DATETIME2(7),'2017-01-01 00:00:00')	AS [SOURCE_TIMESTAMP]
,'C'											AS [CHANGE_DATA_INDICATOR]
,0												AS [AUDIT_TRAIL_ID]
,'Group10'										AS [CategoryGroupID]
,'TopGroup'										AS [CategoryGroupName]
,'2017-01-01'									AS [EffectiveDate]
UNION
-- Record 2
SELECT
 CONVERT(DATETIME2(7),'2023-02-25 00:00:00')	AS [INSCRIPTION_TIMESTAMP]
,1												AS [INSCRIPTION_RECORD_ID]
,CONVERT(DATETIME2(7),'2023-02-25 00:00:00')	AS [SOURCE_TIMESTAMP]
,'C'											AS [CHANGE_DATA_INDICATOR]
,0												AS [AUDIT_TRAIL_ID]
,'Group10'										AS [CategoryGroupID]
,'TopGroupUpdated'								AS [CategoryGroupName]
,'2023-02-25'									AS [EffectiveDate]
) sub

SELECT * FROM #CategoryGroup

/* Join */
SELECT
  START_DATE_KEY AS EffectiveDate
 ,CustomerID
 ,FavouriteColour
 ,CategoryName
 ,CategoryGroupName
FROM
(
  SELECT
     *,
     LAG(ATTRIBUTE_CHECKSUM, 1, 0x00000000000000000000000000000000) OVER(PARTITION BY CustomerId ORDER BY START_DATE_KEY ASC) AS PREVIOUS_ATTRIBUTE_CHECKSUM
  FROM
  (
     SELECT
            *,
            ISNULL(RTRIM(CONVERT(VARCHAR(100),CustomerID)),'NA')+'|'+
            ISNULL(RTRIM(CONVERT(VARCHAR(100),FavouriteColour)),'NA')+'|' +
            ISNULL(RTRIM(CONVERT(VARCHAR(100),CategoryName)),'NA')+'|' +
            ISNULL(RTRIM(CONVERT(VARCHAR(100),CategoryGroupName)),'NA')+'|'
         AS ATTRIBUTE_CHECKSUM
	 FROM
	 (
			SELECT 
			     cust.CustomerID
				,cust.FavouriteColour
				,cat.CategoryName
				,grp.CategoryGroupName
				,TimeRanges.START_DATE_KEY
				,TimeRanges.END_DATE_KEY
			FROM
			(
				SELECT
					 CustomerID
					,EffectiveDate AS START_DATE_KEY
					,LEAD(EffectiveDate,1,'9999-12-31') OVER (PARTITION BY CustomerID ORDER BY EffectiveDate ASC) AS END_DATE_KEY
				FROM 
				(
					SELECT CustomerID, EffectiveDate FROM #Customer
					UNION
					SELECT CustomerId, #Category.EffectiveDate 
					FROM #Category 
					INNER JOIN #Customer ON #Customer.CategoryID = #Category.CategoryID
					UNION
					SELECT CustomerId, #CategoryGroup.EffectiveDate
					FROM #CategoryGroup 
					INNER JOIN #Category ON #CategoryGroup.CategoryGroupID = #Category.CategoryGroupID
					INNER JOIN #Customer ON #Category.CategoryID = #Customer.CategoryID
				) PIT
			) TimeRanges
			INNER JOIN 
				(       
					SELECT
					   EffectiveDate AS START_DATE_KEY
	                  ,LEAD(EffectiveDate,1,'9999-12-31') OVER (PARTITION BY CustomerId ORDER BY EffectiveDate ASC) AS END_DATE_KEY
	                  ,*
                    FROM #Customer
                ) cust
				ON TimeRanges.CustomerID = cust.CustomerID
			   AND cust.START_DATE_KEY <= TimeRanges.START_DATE_KEY
			   AND cust.END_DATE_KEY >= TimeRanges.END_DATE_KEY
			LEFT JOIN 
				(       
					SELECT
					   EffectiveDate AS START_DATE_KEY
	                  ,LEAD(EffectiveDate,1,'9999-12-31') OVER (PARTITION BY CategoryId ORDER BY EffectiveDate ASC) AS END_DATE_KEY
	                  ,*
                    FROM #Category
                ) cat
				ON cust.CategoryID = cat.CategoryID
			   AND cat.START_DATE_KEY <= TimeRanges.START_DATE_KEY
			   AND cat.END_DATE_KEY >= TimeRanges.END_DATE_KEY
			LEFT JOIN 
				(       
					SELECT
					   EffectiveDate AS START_DATE_KEY
	                  ,LEAD(EffectiveDate,1,'9999-12-31') OVER (PARTITION BY CategoryGroupId ORDER BY EffectiveDate ASC) AS END_DATE_KEY
	                  ,*
                    FROM #CategoryGroup
                ) grp
				ON cat.CategoryGroupId = grp.CategoryGroupId
			   AND grp.START_DATE_KEY <= TimeRanges.START_DATE_KEY
			   AND grp.END_DATE_KEY >= TimeRanges.END_DATE_KEY
		) sub
	) comparison
) final
WHERE ATTRIBUTE_CHECKSUM <> PREVIOUS_ATTRIBUTE_CHECKSUM
