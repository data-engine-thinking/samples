/*******************************************************************************
 * Data Engine Thinking
 *******************************************************************************
 *
 * Purpose:
 *   - SQL example for Loading an bitemporal Satellite.
 *
 * Disclaimer:
 *   - See disclaimer.md in the repository root.
 *
 ******************************************************************************/

WITH
NewRecords AS
(
    SELECT […]
    (
        <compacting selection>
    )
    LEFT JOIN
        <prevent reprocessing>
)
, ExistingRight
(
    All new records, and all records from the target object with overlapping time periods
    SELECT […] FROM <NewRecords>
    UNION
    SELECT […] FROM <target data object with overlaps>

)
, PreserveRightPartOfExistingRecords AS
(
    -- Duplicate the existing record, preserving the right portion
    SELECT
         NewRecords.[CUSTOMER_SK]
        -- Use the new inscription timestamp and record id
        ,NewRecords.[Inscription_Timestamp]
        ,NewRecords.[Inscription_Record_Id]
        -- Replace the existing state from timestamp with new state before timestamp
        ,COALESCE(NewRecords.State_Before_Timestamp,'9999-12-31') AS [State_From_Timestamp]
        -- Keep the existing state before timestamp
        ,ExistingRight.[State_Before_Timestamp]
        -- Map the available existing data
        ,ExistingRight.<columns>
        -- Order the records - Only the most recent record is of interest
        ,ROW_NUMBER()
            OVER (PARTITION BY ExistingRight.[CODE]
                              ,NewRecords.[State_Before_Timestamp] -- New State From Timestamp
            ORDER BY ExistingRight.[Inscription_Timestamp] DESC
                    ,ExistingRight.[Inscription_Record_Id] DESC)
            AS rownum
    FROM <NewRecords>
    JOIN <ExistingRight>
        ON NewRecords.[CUSTOMER_SK] = ExistingRight.[CUSTOMER_SK]
    WHERE
        -- Compare only with previous records
        NewRecords.[Inscription_Timestamp] > ExistingRight.[Inscription_Timestamp]
       -- Find Allen Relationship (right)
    AND COALESCE(NewRecords.State_Before_Timestamp,'9999-12-31') > ExistingRight.[State_From_Timestamp]
    AND COALESCE(NewRecords.State_Before_Timestamp,'9999-12-31') < ExistingRight.[State_Before_Timestamp]
)
, ExistingLeft
(
    SELECT […] FROM <PreserveRightPartOfExistingRecords>
    UNION
    SELECT […] FROM <NewRecords>
    UNION
    SELECT […] FROM <target data object with overlaps>
)
, PreserveLeftPartOfExistingRecords AS
(
    -- Duplicate the existing record, preserving the left portion
    SELECT
         NewRecords.[CUSTOMER_SK]
        -- Use new inscription timestamp and record id
        ,NewRecords.[Inscription_Timestamp]
        ,NewRecords.[Inscription_Record_Id]
        -- Keep the existing state before timestamp
        ,ExistingLeft.[State_From_Timestamp] AS [State_From_Timestamp]
        -- Replace the existing state before timestamp with new state from timestamp
        ,NewRecords.[State_From_Timestamp] AS [State_Before_Timestamp]
        -- Map the available existing data
        ,ExistingLeft. <available columns>
        ,[…]
        -- Order the records - Only the most recent record is of interest
        ,ROW_NUMBER()
            OVER (PARTITION BY ExistingLeft.[CODE]
                              ,NewRecords.State_From_Timestamp    -- New State Before Timestamp
            ORDER BY ExistingLeft.[Inscription_Timestamp] DESC
                    ,ExistingLeft.[Inscription_Record_Id] DESC)
            AS rownum
    FROM <NewRecords>
    JOIN <ExistingLeft>
        ON NewRecords.[CUSTOMER_SK] = ExistingLeft.[CUSTOMER_SK]
    WHERE
    -- Compare only with previous records
        NewRecords.Inscription_Timestamp > ExistingLeft.Inscription_Timestamp
    -- Find Allen Relationship (left)
    AND NewRecords.State_From_Timestamp  > ExistingLeft.State_From_Timestamp
    AND NewRecords.State_From_Timestamp  < ExistingLeft.State_Before_Timestamp
)
INSERT INTO <target data object>
(
    <column list>
)
SELECT <PreserveLeftPartOfExistingRecords>
WHERE rownum = 1
UNION
SELECT <PreserveRightPartOfExistingRecords>
WHERE rownum = 1
UNION
SELECT <NewRecords>