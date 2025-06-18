# Solution Pattern Example - PSA

```sql
--------------------------------------------------------------------------------
-- PSA solution pattern
-- Version in book
INSERT INTO PSA.EntityClass (
     InscriptionTimestamp
    ,InscriptionRecordID
    ,SourceTimestamp
    ,ChangeDataIndicator
    ,AuditTrailID
    ,ModelCode
    ,EntityClassCode
    ,EntityClassName
    ,Checksum
)
SELECT
     InscriptionTimestamp
    ,InscriptionRecordID
    ,SourceTimestamp
    ,ChangeDataIndicator
    ,AuditTrailID
    ,ModelCode
    ,EntityClassCode
    ,EntityClassName
    ,Checksum
FROM (
SELECT
     lda.InscriptionTimestamp
    ,lda.InscriptionRecordID
    ,lda.SourceTimestamp
    ,lda.ChangeDataIndicator
    ,lda.AuditTrailID -- take from LDA for better testing
    ,lda.ModelCode
    ,lda.EntityClassCode
    ,lda.EntityClassName
    ,lda.Checksum
    ,COALESCE(submaxpsa.Checksum, 'N/A') AS submaxpsaChecksum
    ,COALESCE(submaxpsa.ChangeDataIndicator, 'C') AS submaxpsaChangeDataIndicator -- Better indicator value due to datatype missmatch - Testcase (4)
    ,ROW_NUMBER() OVER (PARTITION BY lda.ModelCode
                                    ,lda.EntityClassCode
                        ORDER BY lda.ModelCode
                                ,lda.EntityClassCode
                                ,lda.InscriptionTimestamp)
        AS rownum
FROM LDA.EntityClass AS lda
  -- Prevent reprocessing
LEFT OUTER JOIN PSA.EntityClass AS psa
    ON  lda.ModelCode = psa.ModelCode
    AND lda.EntityClassCode = psa.EntityClassCode
    AND lda.InscriptionTimestamp = psa.InscriptionTimestamp
    AND lda.InscriptionRecordID = psa.InscriptionRecordID
  -- Most recently arrived PSA record
LEFT OUTER JOIN (
    SELECT
         psa.ModelCode
        ,psa.EntityClassCode
        ,psa.Checksum
        ,psa.ChangeDataIndicator
    FROM PSA.EntityClass AS psa
    INNER JOIN
        (
        SELECT
             MAX(InscriptionTimestamp) AS maxInscriptionTimestamp
            ,MAX(InscriptionRecordID) AS maxInscriptionRecordID
            ,ModelCode
            ,EntityClassCode
        FROM PSA.EntityClass
        GROUP BY ModelCode
                ,EntityClassCode
    ) AS maxpsa
        ON  psa.ModelCode            = maxpsa.ModelCode
        AND psa.EntityClassCode      = maxpsa.EntityClassCode
        AND psa.InscriptionTimestamp = maxpsa.maxInscriptionTimestamp
        AND psa.InscriptionRecordID  = maxpsa.maxInscriptionRecordID
    WHERE psa.ChangeDataIndicator != 'D' -- Don't re-compare already deleted rows.
) AS submaxpsa
    ON  lda.ModelCode       = submaxpsa.ModelCode
    AND lda.EntityClassCode = submaxpsa.EntityClassCode
WHERE psa.EntityClassCode IS NULL   -- Prevent reprocessing
  AND psa.ModelCode       IS NULL  -- Prevent reprocessing
) AS psalda
WHERE
    -- all subsequent changes fo a bk
    rownum != 1 OR
    -- check on first/oldest change for a bk
    (rownum = 1 AND (
        (Checksum != submaxpsaChecksum) OR
        (Checksum  = submaxpsaChecksum AND ChangeDataIndicator != submaxpsaChangeDataIndicator))
        )
;

SELECT *
FROM PSA.EntityClass
ORDER BY ModelCode,EntityClassCode, InscriptionTimestamp, InscriptionRecordID
;
--------------------------------------------------------------------------------
-- Test cases:
-- 1) Same oldest record in LDA as max record in PSA not inserted
-- 2) maxInscriptionTimestamp and maxInscriptionRecordID do not corelate since a lower InscriptionTimestamp contains maxInscriptionRecordID
-- 3) rownum - if InscriptionRecordID not sorted in table
-- 4) reinsert deleted record
```
