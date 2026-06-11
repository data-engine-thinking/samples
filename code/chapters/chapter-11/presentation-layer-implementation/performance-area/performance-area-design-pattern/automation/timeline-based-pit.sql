/*******************************************************************************
 * Data Engine Thinking
 *******************************************************************************
 *
 * Purpose:
 *   - SQL example for Performance Area Solution Pattern Example.
 *
 * Disclaimer:
 *   - See disclaimer.md in the repository root.
 *
 ******************************************************************************/

DECLARE @AssertionSnapshotTimestamp DATETIME2(7) = SYSUTCDATETIME();
DECLARE @StateSnapshotTimestamp DATETIME2(7) = CAST('2025-02-25' AS DATETIME2(7));

SELECT
  -- New snapshot timestamp
  @StateSnapshotTimestamp AS [Snapshot_Timestamp],
  -- Hub surrogate key(s)
  Hub.[Customer_Surrogate_Key]  AS [Hub_Customer_Customer_Surrogate_Key],
  -- Pointer Satellite 1
  Sat1.[Customer_Surrogate_Key] AS [Sat_Customer_Details_Sales_Customer_Surrogate_Key],
  Sat1.[Inscription_Timestamp]  AS [Sat_Customer_Details_Sales_Inscription_Timestamp],
  Sat1.[Inscription_Record_Id]  AS [Sat_Customer_Details_Sales_Inscription_Record_Id],
  Sat1.[State_From_Timestamp]   AS [Sat_Customer_Details_Sales_From_Timestamp],
  -- Pointer Satellite 2
  Sat2.[Customer_Surrogate_Key] AS [Sat_Customer_Details_Contact_Customer_Surrogate_Key],
  Sat2.[Inscription_Timestamp]  AS [Sat_Customer_Details_Contact_Inscription_Timestamp],
  Sat2.[Inscription_Record_Id]  AS [Sat_Customer_Details_Contact_Inscription_Record_Id],
  Sat2.[State_From_Timestamp]   AS [Sat_Customer_Details_Contact_From_Timestamp],
  -- Optional columns
  Hub.[Customer_Code]
FROM [Hub_Customer] Hub
LEFT JOIN [Sat_Customer_Details_Sales] sat1
ON
  -- Assertion timeline
  sat1.[Inscription_Timestamp] <= @AssertionSnapshotTimestamp
  -- State timeline
  AND sat1.[State_From_Timestamp]   <= @StateSnapshotTimestamp
  AND sat1.[State_Before_Timestamp] >  @StateSnapshotTimestamp
LEFT JOIN [Sat_Customer_Details_Contact] sat2
ON
  -- Assertion timeline
  sat2.[Inscription_Timestamp] <= @AssertionSnapshotTimestamp
  -- State timeline
  AND sat2.[State_From_Timestamp]   <= @StateSnapshotTimestamp
  AND sat2.[State_Before_Timestamp] >  @StateSnapshotTimestamp
