/*******************************************************************************
 * Data Engine Thinking
 *******************************************************************************
 *
 * Purpose:
 *   - SQL example for Preparing the Satellite.
 *
 * Disclaimer:
 *   - See disclaimer.md in the repository root.
 *
 ******************************************************************************/

SELECT
    <compacting selection>
FROM
(
    SELECT
        <compacting preparation>
    FROM
    (
        SELECT
            <inner selection>
        FROM
    ) compacting_preparation
) compacting_selection
WHERE <compacting filter>
