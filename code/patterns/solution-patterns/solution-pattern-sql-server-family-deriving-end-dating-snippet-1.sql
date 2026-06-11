/*******************************************************************************
 * Data Engine Thinking
 *******************************************************************************
 *
 * Purpose:
 *   - Deriving the before timestamp at runtime ('on the fly').
 *
 * Disclaimer:
 *   - See disclaimer.md in the repository root.
 *
 ******************************************************************************/

-- The LEAD window function selects the from timestamp of the next record for
-- the same key, in order of the timeline. When no next record exists, the
-- high-end default '9999-12-31' indicates the absence of a before timestamp.

SELECT
    [Customer_Sk],
    [State_From_Timestamp],
    LEAD([State_From_Timestamp], 1, '9999-12-31')
      OVER (PARTITION BY [Customer_Sk]
            ORDER BY [State_From_Timestamp]) AS [State_Before_Timestamp],
    [Customer_First_Name],
    [Customer_Date_Of_Birth]
FROM [Sat_Customer];
