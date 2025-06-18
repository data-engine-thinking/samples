# Referential integrity

Here's an example of an RI control written as a test:
```sql
BEGIN
  DECLARE @TestResult VARCHAR(10) = 'Fail';
  DECLARE @TestOutput VARCHAR(MAX);
  DECLARE @Issues INT = 0;

  BEGIN TRY
    SELECT @Issues = COUNT(*)
    FROM Satellite sat
    WHERE NOT EXISTS
    (
      SELECT 1 FROM Hub hub
      WHERE 1=1
       AND sat.<key> = hub.<key>
    )

    SET @TestOutput = CONVERT(VARCHAR(10),@Issues)+' issue(s) were found.'

    IF @Issues=0
    BEGIN
      SET @TestResult = 'Pass'
    END
  END TRY
  BEGIN CATCH
    SET @TestOutput = ERROR_MESSAGE();
    SET @TestResult = 'Fail'
  END CATCH

  SELECT @TestOutput AS [OUTPUT], @TestResult AS [RESULT]
END
```