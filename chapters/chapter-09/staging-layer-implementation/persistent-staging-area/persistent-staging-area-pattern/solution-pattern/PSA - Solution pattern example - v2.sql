/*******************************************************************************
 * Data Engine Thinking
 *******************************************************************************
 *
 * Purpose:
 *   - PSA solution pattern example (version 2) for the persistent staging area pattern.
 *
 * Disclaimer:
 *   - See disclaimer.md in the repository root.
 *
 ******************************************************************************/

--------------------------------------------------------------------------------
-- PSA solution pattern
--INSERT INTO PSA.EntityClass (
--     InscriptionTimestamp
--    ,InscriptionRecordID
--    ,SourceTimestamp
--    ,ChangeDataIndicator
--    ,AuditTrailID
--    ,ModelCode
--    ,EntityClassCode
--    ,EntityClassName
--    ,Checksum
--)
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
                                ,lda.InscriptionTimestamp
                                ,lda.InscriptionRecordID) -- Missing in solution pattern example - Testcase (3)
        AS rownum
FROM LDA.EntityClass AS lda
LEFT OUTER JOIN PSA.EntityClass AS psa
    ON  lda.ModelCode = psa.ModelCode
    AND lda.EntityClassCode = psa.EntityClassCode
    AND lda.InscriptionTimestamp = psa.InscriptionTimestamp
    AND lda.InscriptionRecordID = psa.InscriptionRecordID
LEFT OUTER JOIN (
    SELECT
         psa.ModelCode
        ,psa.EntityClassCode
        ,psa.Checksum
        ,psa.ChangeDataIndicator
    FROM PSA.EntityClass AS psa
    INNER JOIN (
        SELECT -- Fixed maxInscriptionRecordID in solution pattern example - Testcase (2)
             InscriptionTimestamp AS maxInscriptionTimestamp
            ,MAX(InscriptionRecordID) OVER (PARTITION BY ModelCode
                                                        ,EntityClassCode
                                                        ,InscriptionTimestamp
                                            ORDER BY ModelCode
                                                    ,EntityClassCode
                                                    ,InscriptionTimestamp)
             AS maxInscriptionRecordID
            ,ROW_NUMBER() OVER (PARTITION BY ModelCode
                                            ,EntityClassCode
                                ORDER BY ModelCode
                                        ,EntityClassCode
                                        ,InscriptionTimestamp DESC)
             AS maxRownum
            ,ModelCode
            ,EntityClassCode
        FROM PSA.EntityClass
    ) AS maxpsa
        ON  psa.ModelCode            = maxpsa.ModelCode
        AND psa.EntityClassCode      = maxpsa.EntityClassCode
        AND psa.InscriptionTimestamp = maxpsa.maxInscriptionTimestamp
        AND psa.InscriptionRecordID  = maxpsa.maxInscriptionRecordID
        AND 1                        = maxpsa.maxRownum
    WHERE psa.ChangeDataIndicator != 'D'
) AS submaxpsa
    ON  lda.ModelCode       = submaxpsa.ModelCode
    AND lda.EntityClassCode = submaxpsa.EntityClassCode
WHERE psa.EntityClassCode IS NULL
  AND psa.ModelCode       IS NULL
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
--TRUNCATE TABLE PSA.EntityClass
-- Test cases:
-- 1) Same oldest record in LDA as max record in PSA not inserted
-- 2) maxInscriptionTimestamp and maxInscriptionRecordID do not corelate since a lower InscriptionTimestamp contains maxInscriptionRecordID
-- 3) rownum - if InscriptionRecordID not sorted in table
-- 4) reinsert deleted record


