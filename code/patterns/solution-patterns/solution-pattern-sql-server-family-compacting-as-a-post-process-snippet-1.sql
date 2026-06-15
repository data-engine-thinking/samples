/*******************************************************************************
 * Data Engine Thinking
 *******************************************************************************
 *
 * Purpose:
 *   - Record compacting as a post-process: because the data is already stored,
 *     the column scope and timeline order are known, so redundant rows can be
 *     removed in a single pass.
 *
 * Disclaimer:
 *   - See disclaimer.md in the repository root. Placeholders such as <Key>,
 *     <Column 1> and <table_name> must be substituted.
 *
 ******************************************************************************/

WITH
CompactingCTE AS
(
  SELECT
    HASHBYTES('SHA1',
      COALESCE(TRIM(CONVERT(NVARCHAR(MAX), <Key>)), '~!@|N/A') + '\@|' +
      COALESCE(TRIM(CONVERT(NVARCHAR(MAX), <Column 1>)), '~!@|N/A') + '\@|' +
      COALESCE(TRIM(CONVERT(NVARCHAR(MAX), <Column 2>)), '~!@|N/A') + '\@|'
    ) AS [Checksum],
    *
  FROM <table_name>
),
Subselect AS
(
  SELECT
    *,
    LAG([Checksum]) OVER (PARTITION BY <Key> ORDER BY <Key>,<Timestamp>) AS [Next_Checksum],
    LAG([Change_Data_Indicator]) OVER (PARTITION BY <Key> ORDER BY <Key>,<Timestamp>) AS [Next_Change_Data_Indicator]
  FROM CompactingCTE
)
DELETE FROM Subselect
WHERE [Checksum] = [Next_Checksum]
AND [Change_Data_Indicator] = [Next_Change_Data_Indicator];
