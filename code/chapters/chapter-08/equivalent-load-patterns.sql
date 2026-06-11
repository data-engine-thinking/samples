/*******************************************************************************
 * Data Engine Thinking
 *******************************************************************************
 *
 * Purpose:
 *   - Two equivalent ways to load only the new rows, generated from the same
 *     design metadata. Both return the same result set; only the template
 *     that produced them differs.
 *
 * Disclaimer:
 *   - See disclaimer.md in the repository root.
 *
 ******************************************************************************/

-- Using NOT EXISTS:
INSERT INTO Products (ProductName, SalePrice)
SELECT PrdNm, PrdValue
FROM products src
WHERE NOT EXISTS
  (
    SELECT NULL FROM ProductMaster tgt WHERE src.PrdNm = tgt.ProductName
  )

-- Using a LEFT OUTER JOIN:
INSERT INTO ProductMaster (ProductName, SalePrice)
SELECT PrdNm, PrdValue
FROM products src
LEFT OUTER JOIN ProductMaster tgt ON src.PrdNm = tgt.ProductName
WHERE tgt.ProductName IS NULL
