/*******************************************************************************
 * Data Engine Thinking
 *******************************************************************************
 *
 * https://dataenginethinking.com/
 *
 * Purpose:
 *   - Create sample data objects
 *
 * This code is provided as is, without warranty of any kind. 
 * Use it at your own risk. We make no guarantees about its suitability, reliability, or accuracy.
 * We are not responsible for any damages or issues that may arise from using, modifying, or distributing this code.
 *
 ******************************************************************************/
 
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