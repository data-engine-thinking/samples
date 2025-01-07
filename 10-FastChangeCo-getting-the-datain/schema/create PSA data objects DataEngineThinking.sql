/*

.SYNOPSIS
    Create data objects for FastChangeCo MVP

.DESCRIPTION
    Create data objects for FastChangeCo MVP

.NOTES
    (C) 2024 Dirk Lerner
    File Name      : create PSA data objects DataEngineThinking.sql
    Prerequisite   : MS SQL Server
    Author         : Dirk Lerner
    Version        : 1.0.0
    Date           : 20240609

*/

USE [DataEngineThinking]
DROP TABLE IF EXISTS PSA.Supplier;
DROP TABLE IF EXISTS PSA.Returns;
DROP TABLE IF EXISTS PSA.[Order];
DROP TABLE IF EXISTS PSA.Product;
DROP TABLE IF EXISTS PSA.Customer;

CREATE TABLE PSA.Customer (
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

ALTER TABLE PSA.Customer
   ADD CONSTRAINT PK_PSA_Customer PRIMARY KEY CLUSTERED (CustomerID,[Inscription Timestamp],[Inscription Record Id]);

/*
CREATE TABLE PSA.Product (
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
 */
