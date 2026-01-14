/*******************************************************************************
 * Data Engine Thinking
 *******************************************************************************
 *
 * Purpose:
 *   - SQL example for Creating A Fact Object.
 *
 * Disclaimer:
 *   - See disclaimer.md in the repository root.
 *
 ******************************************************************************/

SELECT

  -- Date Dimension Key
  CONVERT(CHAR(8), sat.Transaction_Timestamp, 112) AS Transaction_Date_Key,

  -- Runtime-generated dimension keys (if not persisted in PIT)
  ROW_NUMBER() OVER (
    PARTITION BY PIT.Customer_Surrogate_Key
    ORDER BY PIT.State_From_Timestamp
  ) AS Customer_Key,

  ROW_NUMBER() OVER (
    PARTITION BY PIT.Product_Surrogate_Key
    ORDER BY PIT.State_From_Timestamp
  ) AS Product_Key,

  -- Aggregated metric
  COUNT(sat.Quantity_Sold) AS Quantity_Sold,

FROM PIT_Customer_Sale_Transactions PIT

-- Join to the Satellite providing the metric and timestamp
LEFT JOIN Sat_Product_Sale_Transaction sat
  ON PIT.Sat_Product_Sale_Transaction_Surrogate_Key = sat.Customer_Surrogate_Key
  AND PIT.Sat_Product_Sale_Transaction_Inscription_Timestamp = sat.Inscription_Timestamp
  AND PIT.Sat_Product_Sale_Transaction_Inscription_Record_Id = sat.Inscription_Record_Id

GROUP BY
  PIT.Customer_Surrogate_Key,
  PIT.Product_Surrogate_Key,
  CONVERT(CHAR(8), sat.Transaction_Timestamp, 112)
