/*******************************************************************************
 * Data Engine Thinking
 *******************************************************************************
 *
 * Purpose:
 *   - SQL example for Completeness in temporality.
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
    WITH OrderedRanges AS
    (
      SELECT
        <Surrogate Key>,
        INSCRIPTION_TIMESTAMP,
        INSCRIPTION_BEFORE_TIMESTAMP,
        LAG(INSCRIPTION_BEFORE_TIMESTAMP) OVER
        (
          PARTITION BY <Surrogate Key>
          ORDER BY <Surrogate Key>, INSCRIPTION_TIMESTAMP
        ) AS PREVIOUS_INSCRIPTION_BEFORE_TIMESTAMP
      FROM Satellite sat
    )
    ,Evaluation AS
    (
      SELECT
        <Surrogate Key>,
        INSCRIPTION_TIMESTAMP,
        INSCRIPTION_BEFORE_TIMESTAMP,
        PREVIOUS_INSCRIPTION_BEFORE_TIMESTAMP,
        CASE
          WHEN PREVIOUS_INSCRIPTION_BEFORE_TIMESTAMP IS NOT NULL
               AND INSCRIPTION_TIMESTAMP > PREVIOUS_INSCRIPTION_BEFORE_TIMESTAMP THEN 'Gap'
          WHEN PREVIOUS_INSCRIPTION_BEFORE_TIMESTAMP IS NOT NULL
               AND INSCRIPTION_TIMESTAMP < PREVIOUS_INSCRIPTION_BEFORE_TIMESTAMP THEN 'Overlap'
          ELSE 'No Issue'
        END AS TEMPORAL_INCONSISTENCY_ISSUE
      FROM OrderedRanges
      WHERE
        (PREVIOUS_INSCRIPTION_BEFORE_TIMESTAMP IS NOT NULL
         AND INSCRIPTION_TIMESTAMP > PREVIOUS_INSCRIPTION_BEFORE_TIMESTAMP)
        OR
        (PREVIOUS_INSCRIPTION_BEFORE_TIMESTAMP IS NOT NULL
         AND INSCRIPTION_TIMESTAMP < PREVIOUS_INSCRIPTION_BEFORE_TIMESTAMP)
    )
    SELECT @Issues = COUNT(*)
    FROM Evaluation

    SET @TestOutput = CONVERT(VARCHAR(10),@Issues)+' issues were found.';

    IF @Issues=0
      BEGIN
        SET @TestResult = 'Pass'
      END
  END TRY
  BEGIN CATCH
    SET @TestOutput = ERROR_MESSAGE();
    SET @TestResult = 'Fail - technical error'
  END CATCH

  SELECT @TestOutput AS [OUTPUT], @TestResult AS [RESULT];
END
