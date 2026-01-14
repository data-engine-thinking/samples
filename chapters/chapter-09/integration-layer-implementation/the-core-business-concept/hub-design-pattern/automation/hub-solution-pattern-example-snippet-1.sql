/*******************************************************************************
 * Data Engine Thinking
 *******************************************************************************
 *
 * Purpose:
 *   - SQL example for Hub Solution pattern example.
 *
 * Disclaimer:
 *   - See disclaimer.md in the repository root.
 *
 ******************************************************************************/

INSERT INTO [Hub_Customer]
(
	[Customer_Sk],
	[Audit_Trail_Id],
	[Inscription_Timestamp],
	[Customer_Id]
)
SELECT
	COALESCE(TRIM(CONVERT(NVARCHAR(MAX), Customer_Id)), '~!@|N/A') + '\@|' AS [Customer_Sk],
	0 AS [Audit_Trail_Id],
	[Inscription_Timestamp],
	[Customer_Id]
FROM
(
	SELECT
		sub.*,
		ROW_NUMBER() OVER (PARTITION BY
		[Customer_Id]
		ORDER BY [Inscription_Timestamp]
	) AS Arrival_Order
	FROM
	(
		SELECT
			psa.[Code] AS [Customer_Id],
			psa.[Inscription_Timestamp]
		FROM [PSA_Sales] psa
		LEFT OUTER JOIN [Hub_Customer] hub
			ON psa.[Code] = hub.[Customer_Id]
		WHERE
			psa.[Code] IS NOT NULL AND hub.[Customer_Id] IS NULL
	) sub
) supersub
WHERE Arrival_Order = 1
