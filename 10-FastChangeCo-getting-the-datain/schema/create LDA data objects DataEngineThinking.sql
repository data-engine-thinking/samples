/*

.SYNOPSIS
    Create data objects for FastChangeCo MVP

.DESCRIPTION
    Create data objects for FastChangeCo MVP

.NOTES
    (C) 2024 Dirk Lerner
    File Name      : create LDA data objects DataEngineThinking.sql
    Prerequisite   : MS SQL Server
    Author         : Dirk Lerner
    Version        : 1.0.0
    Date           : 20240609

*/

USE [DataEngineThinking]
DROP TABLE IF EXISTS LDA.Supplier;
DROP TABLE IF EXISTS LDA.Returns;
DROP TABLE IF EXISTS LDA.[Order];
DROP TABLE IF EXISTS LDA.Product;
DROP TABLE IF EXISTS LDA.Customer;

CREATE TABLE LDA.Customer (
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

/*
CREATE TABLE LDA.Product (
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


CREATE TABLE LDA.[Order] (
    OrderID BIGINT,
    CustomerID BIGINT,
    OrderDate DATETIME2,
    TotalAmount DECIMAL(10, 2),
    Status NVARCHAR(MAX),
    SourceCreationDate DATETIME2
);

CREATE TABLE LDA.Returns (
    ReturnID BIGINT,
    OrderID BIGINT,
    ReturnDate DATETIME2,
    Reason NVARCHAR(MAX)
);

CREATE TABLE LDA.Supplier (
    SupplierID BIGINT,
    Name NVARCHAR(MAX),
    ContactName NVARCHAR(MAX),
    Email NVARCHAR(MAX),
    Phone NVARCHAR(MAX),
    Address NVARCHAR(MAX)
);
 */
