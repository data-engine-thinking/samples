/*******************************************************************************
 * Data Engine Thinking
 *******************************************************************************
 *
 * Purpose:
 *   - SQL example for Uniqueness.
 *
 * Disclaimer:
 *   - See disclaimer.md in the repository root.
 *
 ******************************************************************************/

BEGIN
    DECLARE @TestResult VARCHAR(10) = 'Fail';
    DECLARE @TestOutput VARCHAR(MAX);
    DECLARE @Issues INT = 0;

    BEGIN TRY
        SELECT @Issues = DUPLICATE_COUNT
        FROM
        (
            SELECT
                <business key(s)>,
                COUNT(*) AS DUPLICATE_COUNT
            FROM Hub
            GROUP BY
                <business key(s)>
            HAVING COUNT(*)>1
        ) sub

        SET @TestOutput = CONVERT(VARCHAR(10),@Issues)+' issue(s) were found.';

        IF @Issues=0
        BEGIN
            SET @TestResult='Pass'
        END
    END TRY
    BEGIN CATCH
        SET @TestOutput = ERROR_MESSAGE();
        SET @TestResult='Fail'
    END CATCH

    SELECT @TestOutput AS [OUTPUT], @TestResult AS [RESULT];
END
