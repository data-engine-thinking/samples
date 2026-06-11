/*******************************************************************************
 * Data Engine Thinking
 *******************************************************************************
 *
 * Purpose:
 *   - Closing time periods when the before timestamp is persisted.
 *
 * Disclaimer:
 *   - See disclaimer.md in the repository root.
 *
 ******************************************************************************/

-- Each record receives the from timestamp of the next record for the same
-- key as its before timestamp; the most recent record keeps the high-end
-- default '9999-12-31'. The filter limits the update to periods that are
-- open, or no longer consistent with the timeline.

UPDATE sat
SET [State_Before_Timestamp] = drv.[New_State_Before_Timestamp]
FROM [Sat_Customer] sat
JOIN
(
    SELECT
        [Customer_Sk],
        [State_From_Timestamp],
        LEAD([State_From_Timestamp], 1, '9999-12-31')
          OVER (PARTITION BY [Customer_Sk]
                ORDER BY [State_From_Timestamp]) AS [New_State_Before_Timestamp]
    FROM [Sat_Customer]
) drv
    ON  sat.[Customer_Sk] = drv.[Customer_Sk]
    AND sat.[State_From_Timestamp] = drv.[State_From_Timestamp]
WHERE COALESCE(sat.[State_Before_Timestamp], '9999-12-31') != drv.[New_State_Before_Timestamp];
