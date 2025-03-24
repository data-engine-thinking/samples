# Loading an unitemporal Satellite

```sql
INSERT INTO [Sat Customer]
(
    [CUSTOMER_SK],
    [Audit_Trail_Id],
    [Inscription_Timestamp],
    [Inscription_Record_Id],
    [Change_Data_Indicator],
    [Checksum],
    [State_From_Timestamp],
    [CUSTOMER_FIRST_NAME],
    [CUSTOMER_DATE_OF_BIRTH]
)
SELECT
    […]
FROM
(
    SELECT
    compacting_selection.[CUSTOMER_SK],
    Compacting_selection.[Audit_Trail_Id],
    compacting_selection.[Inscription_Timestamp],
    compacting_selection.[Inscription_Record_Id],
    compacting_selection.[Change_Data_Indicator],
    compacting_selection.[Checksum],
    compacting_selection.[State_From_Timestamp],
    compacting_selection.[CUSTOMER_FIRST_NAME],
    compacting_selection.[CUSTOMER_DATE_OF_BIRTH],
    CAST(ROW_NUMBER() OVER (
        PARTITION BY compacting_selection.[CUSTOMER_SK]
        ORDER BY compacting_selection.[CUSTOMER_SK],
                 compacting_selection.[Inscription_Timestamp],
                 compacting_selection.[Inscription_Record_Id]
    ) AS INT) AS KEY_ROW_NUMBER,
    target_object.[Checksum] AS [Lookup_Checksum],
    target_object.[Change_Data_Indicator] AS [Lookup_Change_Data_Indicator]
    FROM
    (
        <compacting selection>
    ) compacting_selection
    -- Prevent reprocessing
    LEFT OUTER JOIN [Sat Customer] target_object
        ON compacting_selection.[CUSTOMER_SK] = target_object.[CUSTOMER_SK]
        AND compacting_selection.[Inscription_Timestamp] = target_object.[Inscription_Timestamp]
        AND compacting_selection.[Inscription_Record_Id] = target_object.[Inscription_Record_Id]
    WHERE satellite.[CUSTOMER_SK] IS NULL
) final
-- Change merging
WHERE
(   KEY_ROW_NUMBER = 1
    AND (( [Checksum] != [Lookup_Checksum] )
        -- The checksums are different
        OR ( [Checksum] = [Lookup_Checksum]
         AND [Change_Data_Indicator] != [Lookup_Change_Data_Indicator])
        -- The checksums are the same but the CDC is different
        )
)
OR
(-- It's not the most recent change in the set, so the record can be inserted as-is
    KEY_ROW_NUMBER != 1)
```