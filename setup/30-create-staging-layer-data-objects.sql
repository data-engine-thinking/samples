/*******************************************************************************
 * Data Engine Thinking
 *******************************************************************************
 *
 * Purpose:
 *   - Create sample staging layer data objects (LDA and PSA) used by the examples.
 *
 * Disclaimer:
 *   - See disclaimer.md in the repository root.
 *
 ******************************************************************************/

-- Entity Class
DROP TABLE IF EXISTS [LDA].[EntityClass];

CREATE TABLE [LDA].[EntityClass]
(
     InscriptionTimestamp       DATETIME2(7)			NOT NULL DEFAULT SYSUTCDATETIME()
    ,InscriptionRecordID        BIGINT IDENTITY(1,1)	NOT NULL
    ,SourceTimestamp            DATETIME2(7)			NOT NULL
    ,ChangeDataIndicator        CHAR(1)					NOT NULL
    ,AuditTrailID               BIGINT					NOT NULL
    ,[Checksum]                 BINARY(40)				NOT NULL
    ,ModelCode                  NVARCHAR(100)			NULL
    ,EntityClassCode            NVARCHAR(100)			NULL
    ,EntityClassName            NVARCHAR(256)			NULL
);

-- PSA
DROP TABLE IF EXISTS [PSA].[EntityClass];

CREATE TABLE [PSA].[EntityClass]
(
     InscriptionTimestamp       DATETIME2(7)	NOT NULL
    ,InscriptionRecordID        BIGINT			NOT NULL
    ,SourceTimestamp            DATETIME2(7)	NOT NULL
    ,ChangeDataIndicator        CHAR(1)			NOT NULL
    ,AuditTrailID               BIGINT			NOT NULL
    ,[Checksum]                 BINARY(40)		NOT NULL
    ,ModelCode                  NVARCHAR(128)	NOT NULL
    ,EntityClassCode            NVARCHAR(128)	NOT NULL
    ,EntityClassName            NVARCHAR(128)	NOT NULL
);

ALTER TABLE [PSA].[EntityClass]
   ADD CONSTRAINT [PK_PSA_EntityClass] PRIMARY KEY CLUSTERED (ModelCode,EntityClassCode,InscriptionTimestamp,InscriptionRecordID);

-- Supplier
DROP TABLE IF EXISTS [LDA].[Supplier];

CREATE TABLE [LDA].[Supplier]
(
    SupplierID BIGINT,
    Name NVARCHAR(MAX),
    ContactName NVARCHAR(MAX),
    Email NVARCHAR(MAX),
    Phone NVARCHAR(MAX),
    Address NVARCHAR(MAX)
);

-- Returns
DROP TABLE IF EXISTS [LDA].[Returns];

CREATE TABLE [LDA].[Returns]
(
    ReturnID BIGINT,
    OrderID BIGINT,
    ReturnDate DATETIME2,
    Reason NVARCHAR(MAX)
);

-- Order
DROP TABLE IF EXISTS LDA.[Order];

CREATE TABLE LDA.[Order]
(
    OrderID BIGINT,
    CustomerID BIGINT,
    OrderDate DATETIME2,
    TotalAmount DECIMAL(10, 2),
    Status NVARCHAR(MAX),
    SourceCreationDate DATETIME2
);

CREATE TABLE PSA.[Order] (
    OrderID BIGINT,
    CustomerID BIGINT,
    OrderDate DATETIME2,
    TotalAmount DECIMAL(10, 2),
    Status NVARCHAR(MAX),
    SourceCreationDate DATETIME2,
    [Checksum] BINARY(20),
    [Inscription Timestamp] DATETIME2 NOT NULL,
    [Inscription Record Id] INTEGER NOT NULL,
    [Source Timestamp] DATETIME2 NOT NULL,
    [Change Data Indicator] CHAR(1) NOT NULL,
    [Audit Trail Id] BIGINT NOT NULL
);

-- Product
DROP TABLE IF EXISTS LDA.Product;

CREATE TABLE LDA.Product
(
    ProductID BIGINT,
    Name NVARCHAR(MAX),
    Description NVARCHAR(MAX),
    Category NVARCHAR(MAX),
    Price DECIMAL(10, 2),
    StockQuantity BIGINT,
    SupplierID BIGINT,
    ValidFrom DATETIME2,
    ValidTo DATETIME2,
    SourceCreationDate DATETIME2
);

CREATE TABLE PSA.Product
(
    ProductID BIGINT,
    Name NVARCHAR(MAX),
    Description NVARCHAR(MAX),
    Category NVARCHAR(MAX),
    Price DECIMAL(10, 2),
    StockQuantity BIGINT,
    SupplierID BIGINT,
    ValidFrom DATETIME2,
    ValidTo DATETIME2,
    SourceCreationDate DATETIME2,
    [Checksum] BINARY(20),
    [Inscription Timestamp] DATETIME2 NOT NULL,
    [Inscription Record Id] INTEGER NOT NULL,
    [Source Timestamp] DATETIME2 NOT NULL,
    [Change Data Indicator] CHAR(1) NOT NULL,
    [Audit Trail Id] BIGINT NOT NULL
);

-- Customer
DROP TABLE IF EXISTS [LDA].[Customer];
DROP TABLE IF EXISTS [PSA].[Customer];

CREATE TABLE [LDA].[Customer] 
(
    -- Data solution default columns
    [Inscription Timestamp] DATETIME2 DEFAULT SYSUTCDATETIME() NOT NULL,
    [Inscription Record Id] INTEGER IDENTITY(1,1) NOT NULL,
    [Source Timestamp] DATETIME2 NOT NULL,
    [Audit Trail Id] BIGINT NOT NULL,
    -- Data columns from source
    CustomerID BIGINT,
    FirstName NVARCHAR(MAX),
    LastName NVARCHAR(MAX),
    Email NVARCHAR(MAX),
    Phone NVARCHAR(MAX),
    Street NVARCHAR(MAX),
    PostalCode NVARCHAR(MAX),
    City NVARCHAR(MAX),
    SourceCreationDate DATETIME2,
);

CREATE TABLE [PSA].[Customer]
(
    -- Data solution default columns
    [Inscription Timestamp] DATETIME2 NOT NULL,
    [Inscription Record Id] INTEGER NOT NULL,
    [Source Timestamp] DATETIME2 NOT NULL,
    [Change Data Indicator] CHAR(1) NOT NULL,
    [Audit Trail Id] BIGINT NOT NULL,
    [Checksum] BINARY(20),
    -- Data columns from source
    CustomerID BIGINT NOT NULL,
    FirstName NVARCHAR(MAX),
    LastName NVARCHAR(MAX),
    Email NVARCHAR(MAX),
    Phone NVARCHAR(MAX),
    Street NVARCHAR(MAX),
    PostalCode NVARCHAR(MAX),
    City NVARCHAR(MAX),
    SourceCreationDate DATETIME2
);

ALTER TABLE [PSA].[Customer]
   ADD CONSTRAINT PK_PSA_Customer PRIMARY KEY CLUSTERED (CustomerID,[Inscription Timestamp],[Inscription Record Id]);


