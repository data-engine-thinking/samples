/*******************************************************************************
 * Data Engine Thinking
 *******************************************************************************
 *
 * Purpose:
 *   - Structure for creating a dimension directly from integration layer
 *     objects, as a layered (virtual) statement.
 *
 * Disclaimer:
 *   - See disclaimer.md in the repository root. This is an illustrative
 *     structure; placeholders in angle brackets are generated from metadata.
 *
 ******************************************************************************/

SELECT
  <Final column formatting and aliasing>
FROM
(
  SELECT
    <Checksum comparison>
  FROM
  (
    SELECT
      <Checksum preparation>
    FROM
    (
      SELECT
        <Integration layer column selection>
      FROM
      (
        SELECT
          <Derive time periods>
        FROM
        (
          <Combine all from timestamp values>
        ) Timestamps
      ) Timeperiods
      JOIN <Integration layer objects>
    ) Timelines
  ) Calculate_Checksum
) Final
WHERE <Checksum comparison filter>
