/*******************************************************************************
 * Data Engine Thinking
 *******************************************************************************
 *
 * Purpose:
 *   - Data type mapping fidelity: how careless target data types silently
 *     change values when data is loaded.
 *
 * Disclaimer:
 *   - See disclaimer.md in the repository root.
 *
 ******************************************************************************/

-- A TIME value gains a default date when cast to a timestamp, so it can only
-- be mapped to a target TIME data type (not a timestamp):
DECLARE @timeValue TIME = '09:15:22.33'
SELECT
     @timeValue
    ,CAST(@timeValue AS datetime2)

-- A high-precision floating point loses digits when forced into a fixed
-- NUMERIC. 26773e-22 is rounded when cast to NUMERIC(38,20):
DECLARE @floatNumber FLOAT = 26773e-22;
SELECT
     @floatNumber
    ,CAST(@floatNumber AS NUMERIC(38,20))

-- Parsing a text float with an explicit culture (e.g. a comma decimal
-- separator coming from a German-culture system):
SELECT TRY_PARSE(@nvarchcharfloatWithSemicolon AS FLOAT USING 'de-de')
