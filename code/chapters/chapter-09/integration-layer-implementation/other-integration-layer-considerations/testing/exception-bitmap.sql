/*******************************************************************************
 * Data Engine Thinking
 *******************************************************************************
 *
 * Purpose:
 *   - Exception (error) bitmap: encode the outcome of multiple checks into a
 *     single integer (one bit per check), then decode it with a bitwise join.
 *
 * Disclaimer:
 *   - See disclaimer.md in the repository root. These are illustrative
 *     fragments; placeholders such as <reject_tablename> must be substituted.
 *
 ******************************************************************************/

-- Each check is evaluated as a single bit (1 when the error is detected).
-- For example, scenario 2 ('no customer for transaction'):
CASE Error_Bit_2
  WHEN (Transaction_ID IS NOT NULL
        AND Customer_ID IS NULL)
  THEN 1
  ELSE 0
END

-- Assuming the other checks follow similar logic (or default to 0), the full
-- bitmap is calculated and stored as a single integer value:
COALESCE(Error_Bit_1,0) * 1 +
COALESCE(Error_Bit_2,0) * 2 +
COALESCE(Error_Bit_3,0) * 4 +
COALESCE(Error_Bit_4,0) * 8 +
COALESCE(Error_Bit_5,0) * 16 +
COALESCE(Error_Bit_6,0) * 32 +
COALESCE(Error_Bit_7,0) * 64 +
COALESCE(Error_Bit_8,0) * 128

-- A 'bitwise join' decodes the integer back into every error for a record:
SELECT
  reject.*,
  error_table.description
FROM
  <reject_tablename> reject,
  ERROR_CODE_REFERENCE error_table
WHERE BITAND
(
  reject.error_code, error_table.bit_mask_value
) = error_table.bit_mask_value
