/*******************************************************************************
 * Data Engine Thinking
 *******************************************************************************
 *
 * Purpose:
 *   - SQL example for Design Pattern - Data Vault - Simple Date Math (Joining two Time-Variant Tables).
 *
 * Disclaimer:
 *   - See disclaimer.md in the repository root.
 *
 ******************************************************************************/

SELECT 
 B.PRODUCT_NAME,
 C.CHANNEL_KEY,
(CASE
   WHEN B.EFFECTIVE_DATE > D.EFFECTIVE_DATE
   THEN B.EFFECTIVE_DATE
   ELSE D.EFFECTIVE_DATE
 END) AS EFFECTIVE_DATE, -- greatest of the two effective dates
(CASE
   WHEN B.EXPIRY_DATE < D.EXPIRY_DATE
   THEN B.EXPIRY_DATE
   ELSE D.EXPIRY_DATE
 END) AS EXPIRY_DATE -- smallest of the two expiry dates
FROM HUB_PRODUCT A
JOIN SAT_PRODUCT B ON A.PRODUCT_SK=B.PRODUCT_SK
JOIN LINK_PRODUCT_CHANNEL C ON A.PRODUCT_SK=C.PRODUCT_SK
JOIN SAT_LINK_PRODUCT_CHANNEL D ON D.PRODUCT_CHANNEL_SK=C.PRODUCT_CHANNEL_SK
WHERE
(CASE
   WHEN B.EFFECTIVE_DATE > D.EFFECTIVE_DATE
   THEN B.EFFECTIVE_DATE
   ELSE D.EFFECTIVE_DATE
 END) -- greatest of the two effective dates
 <
(CASE
   WHEN B.EXPIRY_DATE < D.EXPIRY_DATE
   THEN B.EXPIRY_DATE
   ELSE D.EXPIRY_DATE -- smallest of the two expiry dates
 END)
