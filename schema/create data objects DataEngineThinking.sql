DROP TABLE IF EXISTS LDA.EntityClass ;

CREATE TABLE LDA.EntityClass(
     InscriptionTimestamp    DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
    ,InscriptionRecordID     BIGINT IDENTITY(1,1) NOT NULL
    ,SourceTimestamp         DATETIME2 NOT NULL
    ,ChangeDataIndicator     CHAR(1) NOT NULL
    ,AuditTrailID            BIGINT NOT NULL
    ,Checksum                NVARCHAR(MAX) NOT NULL
    ---
    ,ModelCode         nvarchar(100) NOT NULL
    ,EntityClassCode   nvarchar(100) NOT NULL
    --GUID              nvarchar(128) NOT NULL,
    ,EntityClassName   nvarchar(256) NULL
    --EntityType        nvarchar(50) NULL,
    --Stereotype        nvarchar(128) NULL,
    --Comment           nvarchar(1024) NULL,
    --Description       nvarchar(1024) NULL,
    --Annotation        nvarchar(4000) NULL,
    --DatabaseName      nvarchar(256) NULL,
    --SchemaName        nvarchar(256) NULL,
    --ArchitectureLayer nvarchar(100) NULL,
    --DbmsName          nvarchar(256) NULL
)

DROP TABLE IF EXISTS PSA.EntityClass;

CREATE TABLE PSA.EntityClass (
     InscriptionTimestamp    DATETIME2 NOT NULL
    ,InscriptionRecordID     BIGINT NOT NULL
    ,SourceTimestamp         DATETIME2 NOT NULL
    ,ChangeDataIndicator     CHAR(1) NOT NULL
    ,AuditTrailID            BIGINT NOT NULL
    ,Checksum                NVARCHAR(MAX) NOT NULL
    ---
    ,ModelCode         nvarchar(100) NOT NULL
    ,EntityClassCode   nvarchar(100) NOT NULL
    --GUID              nvarchar(128) NOT NULL,
    ,EntityClassName   nvarchar(256) NULL,
    --EntityType        nvarchar(50) NULL,
    --Stereotype        nvarchar(128) NULL,
    --Comment           nvarchar(1024) NULL,
    --Description       nvarchar(1024) NULL,
    --Annotation        nvarchar(4000) NULL,
    --DatabaseName      nvarchar(256) NULL,
    --SchemaName        nvarchar(256) NULL,
    --ArchitectureLayer nvarchar(100) NULL,
    --DbmsName          nvarchar(256) NULL
)

ALTER TABLE PSA.EntityClass
   ADD CONSTRAINT PK_PSA_EntityClass PRIMARY KEY CLUSTERED (ModelCode,EntityClassCode,InscriptionTimestamp,InscriptionRecordID);
