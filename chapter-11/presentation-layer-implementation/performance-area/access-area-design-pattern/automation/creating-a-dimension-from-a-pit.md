# Creating a dimension from a PIT

```sql
SELECT
  -- Dimension key
  ROW_NUMBER() OVER
  (ORDER BY
    [sat1].[Inscription_Timestamp],
    [sat1].[Inscription_Record_Id],
    [PIT_Sales].[State_From_Timestamp],
    [PIT_Sales].[Customer_Code]
  ) AS [Customer_Key],

  -- Time periods
  [PIT_Sales].[State_From_Timestamp] AS [From_Timestamp],
  LEAD([PIT_Sales].[State_From_Timestamp],1,'9999-12-31')
    OVER (
       PARTITION BY [PIT_Sales].[Customer_Surrogate_Key]
           ORDER BY [PIT_Sales].[State_From_Timestamp] ASC
   ) AS [Before_Timestamp],

  -- Descriptive columns
  [PIT_Sales].[Customer_Code] AS [Identifier],
  [sat1].[Customer_First_Name] AS [First_Name],
  [sat1].[Customer_Birth_Date] AS [Birth_Date],
  [sat2].[Customer_Contact_Number] AS [Contact_Number],
  [sat2].[Customer_Email_Address] AS [Email_Address],
  [sat2].[Customer_Contact_Preferences] AS [Contact_Preference]
FROM PIT_Sales

— Join Satellite1: Customer Details Sales
LEFT JOIN [Sat_Customer_Details_Sales] sat1
	ON PIT_Sales.Sat_Customer_Details_Sales_Customer_Surrogate_Key = sat1.Customer_Surrogate_Key
   AND PIT_Sales.Sat_Customer_Details_Sales_Inscription_Timestamp = sat1.Inscription_Timestamp
   AND PIT_SALES.Sat_Customer_Details_Sales_Inscription_Record_Id = sat1.Inscription_Record_Id

-- Join Satellite 2: Customer Details Contact
LEFT JOIN [Sat_Customer_Details_Contact] sat2
	ON PIT_Sales.Sat_Customer_Details_Contact_Customer_Surrogate_Key = sat1.Customer_Surrogate_Key
   AND PIT_Sales.Sat_Customer_Details_Contact_Inscription_Timestamp = sat1.Inscription_Timestamp
   AND PIT_SALES.Sat_Customer_Details_Contact_Inscription_Record_Id = sat1.Inscription_Record_Id
```