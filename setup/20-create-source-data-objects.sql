/*******************************************************************************
 * Data Engine Thinking
 *******************************************************************************
 *
 * https://dataenginethinking.com/
 *
 * Purpose:
 *   - Create sample source data objects to integrate into the data solution
 *
 * This code is provided as is, without warranty of any kind. 
 * Use it at your own risk. We make no guarantees about its suitability, reliability, or accuracy.
 * We are not responsible for any damages or issues that may arise from using, modifying, or distributing this code.
 *
 ******************************************************************************/

USE [DataEngineThinking]

DROP TABLE IF EXISTS [Source].[Supplier];
DROP TABLE IF EXISTS [Source].[Returns];
DROP TABLE IF EXISTS [Source].[Order];
DROP TABLE IF EXISTS [Source].[Product];
DROP TABLE IF EXISTS [Source].[Customer];

-------------------------------------------------------------------------------
CREATE TABLE [Source].[Customer] (
    [CustomerID]            INT NOT NULL,
    [FirstName]             NVARCHAR(50),
    [LastName]              NVARCHAR(50),
    [Email]                 VARCHAR(100),
    [Phone]                 VARCHAR(20),
    [Street]                VARCHAR(100),
    [PostalCode]            VARCHAR(20),
    [City]                  VARCHAR(100),
    [SourceCreationDate]    DATETIME NOT NULL
);

ALTER TABLE [Source].[Customer]
   ADD CONSTRAINT [PK_Source_Customer] PRIMARY KEY CLUSTERED ([CustomerID], [SourceCreationDate]);

-------------------------------------------------------------------------------
CREATE TABLE [Source].[Product] (
    [ProductID] INT,
    [Name] VARCHAR(100),
    [Description] VARCHAR(255),
    [Category] VARCHAR(50),
    [Size] SMALLINT
    [Price] DECIMAL(10, 2),
    [StockQuantity] INT,
    [SupplierID] INT,
    [ValidFrom] DATETIME2,
    [ValidTo] DATETIME2,
    [SourceCreationDate] DATETIME
);

ALTER TABLE [Source].[Customer]
   ADD CONSTRAINT [PK_Source_Customer] PRIMARY KEY CLUSTERED ([CustomerID], [SourceCreationDate]);

-------------------------------------------------------------------------------
CREATE TABLE [Source].[Order] (
    OrderNumber BIGINT PRIMARY KEY,
    CustomerID  INT FOREIGN KEY REFERENCES [Source].[Customer](CustomerID),
    ProductID   INT FOREIGN KEY REFERENCES [Source].[Product](ProductID),
    OrderLineNumber TINYINT,
    OrderDate DATE,
    TotalGrossAmount DECIMAL(10, 2),
    TotalNetAmount DECIMAL(10, 2),
    VAT SMALLINT,
    LineDiscount DECIMAL(10, 2),
    LineQuantity DECIMAL(10, 2),
    ExpectedPaymentDate VARCHAR(100),
    ShipmentScheduleDate VARCHAR(100),
    Status VARCHAR(20),
    ShoppingCartSendTimestamp DATETIME2
);


ALTER TABLE [Source].[Order]
   ADD CONSTRAINT PK_Source_Order PRIMARY KEY CLUSTERED (OrderNumber, OrderLineNumber);

-------------------------------------------------------------------------------
CREATE TABLE [Source].[Returns] (
    ReturnID INT PRIMARY KEY,
    OrderNumber INT FOREIGN KEY REFERENCES [Source].[Order](OrderNumber),
    OrderLineNumber TINYINT,
    ReturnDate DATETIME,
    LineQuantity DECIMAL(10, 2),
    Reason VARCHAR(255)
);

ALTER TABLE [Source].[Returns]
   ADD CONSTRAINT [PK_Source_Returns] PRIMARY KEY CLUSTERED ([ReturnID]);
-------------------------------------------------------------------------------

CREATE TABLE [Source].[Supplier] (
    SupplierID INT PRIMARY KEY,
    Name VARCHAR(100),
    ContactName VARCHAR(100),
    Email VARCHAR(100),
    Phone VARCHAR(20),
    Address VARCHAR(255)
);
