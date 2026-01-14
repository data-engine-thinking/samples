/*******************************************************************************
 * Data Engine Thinking
 *******************************************************************************
 *
 * Purpose:
 *   - SQL example for Solution pattern example.
 *
 * Disclaimer:
 *   - See disclaimer.md in the repository root.
 *
 ******************************************************************************/

INSERT INTO <Persistent Staging Table> (<Columns>)
SELECT <Columns>, Lookup_Checksum, Lookup_Change_Data_Indicator, Key_Row_Number, <Framework Columns>
FROM
(
  SELECT
    LDA.<Columns>
    COALESCE(maxsub.[Lookup_Checksum],'N/A') AS [Lookup_Checksum],
    COALESCE(maxsub.[Change_Data_Indicator],'C') AS [Lookup_Change_Data_Indicator],
    ROW_NUMBER() OVER
		(
			PARTITION BY LDA.<Natural Key(s)> ORDER BY LDA.<Natural Key(s)>, LDA.[Inscription_Timestamp], LDA.[Inscription_Timestamp]
		) AS [Key_Row_Number]
  FROM <Landing Area Table> LDA
  -- Prevent reloading already processed data
  LEFT OUTER JOIN <PSA Table> PSA
	ON PSA.<Natural Key(s)> = LDA.<Natural Key(s)>
	AND PSA.[Inscription_Timestamp] = LDA.[Inscription_Timestamp]
	AND PSA.[Inscription_Record_Id] = LDA.[Inscription_Record_Id]
  -- Query the most recently arrived PSA record which is not logically deleted.
  LEFT OUTER JOIN
  (
    SELECT
      A.<Natural Key(s)>,
      A.[Lookup_Checksum] AS [Lookup_Lookup_Checksum],
      A.[Change_Data_Indicator] AS [Lookup_Change_Data_Indicator]
    FROM <Persistent Staging Table> A
    JOIN
	(
      SELECT
		<Natural Key(s)>,
        [Inscription_Timestamp] AS [Max_Inscription_Timestamp],
        MAX([Inscription_Record_Id]) OVER (PARTITION BY <Natural Key(s), [Inscription_Timestamp] ORDER BY <Natural Key(s), [Inscription_Timestamp]) AS [Max_Inscription_Record_Id],
        ROW_NUMBER() OVER (PARTITION BY <Natural Key(s) ORDER BY <Natural Key(s), [Inscription_Timestamp] DESC) AS [Max_RowNum]
      FROM <Persistent Staging Table>
    ) C
        ON A.<Natural Key(s)> = C.<Natural Key(s)>
       AND A.[Inscription_Timestamp] = C.[Max_Inscription_Timestamp]
       AND A.[Inscription_Record_Id] = C.[Max_Inscription_Record_Id]
       AND 1 = C.[Max_RowNum]
    WHERE A.[Lookup_Change_Data_Indicator] != 'D'
  ) maxsub
	ON LDA.<Natural Key(s)> = maxsub.<Natural Key(s)>
  WHERE PSA.<Natural Key(s)> IS NULL
) sub
WHERE
	[Key_Row_Number] != 1
	OR
	(
		[Key_Row_Number] = 1 AND
		(
			([Checksum] != [Lookup_Checksum]) OR
			(
				[Checksum] = [Lookup_Lookup_Checksum] AND
				[Change_Data_Indicator] != [Lookup_Change_Data_Indicator]
			)
		)
	)
