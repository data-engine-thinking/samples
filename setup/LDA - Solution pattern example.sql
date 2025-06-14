
SELECT 'INSERT INTO LDA.EntityClass (SourceTimestamp,ChangeDataIndicator,AuditTrailID,ModelCode,EntityClassCode,EntityClassName)
VALUES (SYSUTCDATETIME(), ''C'', -56, ''' + ModelCode + ''',''' + EntityClassCode + ''',''' + EntityClassName + ''')'
FROM TEDAMOH-ExMeX-Release-Feature.MetadataZone.EntityClass
WHERE ModelCode = 'CoreLayerforShortcutObjects'

SELECT *
FROM TEDAMOH-ExMeX-Release-Feature.MetadataZone.EntityClass

--------------------------------------------------------------------------------
-- Part 1
-- Empty target data object
TRUNCATE TABLE LDA.EntityClass;

-- Reset InscriptionRecordID

-- Simulate FOJ (tbd)
INSERT INTO LDA.EntityClass (SourceTimestamp,ChangeDataIndicator,AuditTrailID,ModelCode,EntityClassCode,EntityClassName,Checksum)
VALUES (SYSUTCDATETIME(), 'C', -56, 'CoreLayerforShortcutObjects','HubShorty','Hub Shorty','Hub Shorty')
INSERT INTO LDA.EntityClass (SourceTimestamp,ChangeDataIndicator,AuditTrailID,ModelCode,EntityClassCode,EntityClassName,Checksum)
VALUES (SYSUTCDATETIME(), 'C', -56, 'CoreLayerforShortcutObjects','SatShorty','Sat Shorty','Sat Shorty')
INSERT INTO LDA.EntityClass (SourceTimestamp,ChangeDataIndicator,AuditTrailID,ModelCode,EntityClassCode,EntityClassName,Checksum)
VALUES (SYSUTCDATETIME(), 'C', -56, 'CoreLayerforShortcutObjects','SatShortyMainframe','Sat Shorty Mainframe','Sat Shorty Mainframe')

SELECT *
FROM LDA.EntityClass;
--------------------------------------------------------------------------------
-- Part 2
-- Empty target data object
TRUNCATE TABLE LDA.EntityClass;

-- Reset InscriptionRecordID

-- Simulate FOJ (tbd)
INSERT INTO LDA.EntityClass (SourceTimestamp,ChangeDataIndicator,AuditTrailID,ModelCode,EntityClassCode,EntityClassName,Checksum)
VALUES (SYSUTCDATETIME(), 'D', -57, 'CoreLayerforShortcutObjects','SatShortyMainframe','Sat Shorty Mainframe','Sat Shorty Mainframe')


SELECT *
FROM LDA.EntityClass;
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- Part 3
-- Empty target data object
TRUNCATE TABLE LDA.EntityClass;

-- Reset InscriptionRecordID

-- Simulate FOJ (tbd)
-- Create InscriptionRecordID for same InscriptionTimestamp
-- Testcase (1)
-- Testcase (3)
SET IDENTITY_INSERT LDA.EntityClass ON;

INSERT INTO LDA.EntityClass (InscriptionRecordID,SourceTimestamp,ChangeDataIndicator,AuditTrailID,ModelCode,EntityClassCode,EntityClassName,Checksum)
VALUES (4,SYSUTCDATETIME(), 'C', -123, 'CoreLayerforShortcutObjects','HubShorty','Hub Shorty','Hub Shorty')
      ,(2,SYSUTCDATETIME(), 'C', -123, 'CoreLayerforShortcutObjects','HubShorty','Hub Shorty - sub ID','Hub Shorty - sub ID')
      ,(3,SYSUTCDATETIME(), 'C', -123, 'CoreLayerforShortcutObjects','SatShorty','Sat Shorty - C1','Sat Shorty - C1')
      ,(1,SYSUTCDATETIME(), 'C', -123, 'CoreLayerforShortcutObjects','HubShorty','Hub Shorty','Hub Shorty')
WAITFOR DELAY '00:00:03'
INSERT INTO LDA.EntityClass (InscriptionRecordID,SourceTimestamp,ChangeDataIndicator,AuditTrailID,ModelCode,EntityClassCode,EntityClassName,Checksum)
VALUES (5,SYSUTCDATETIME(), 'C', -123, 'CoreLayerforShortcutObjects','HubShorty','Hub Shorty - C1','Hub Shorty - C1')
WAITFOR DELAY '00:00:03'
INSERT INTO LDA.EntityClass (InscriptionRecordID,SourceTimestamp,ChangeDataIndicator,AuditTrailID,ModelCode,EntityClassCode,EntityClassName,Checksum)
VALUES (6,SYSUTCDATETIME(), 'C', -123, 'CoreLayerforShortcutObjects','HubShorty','Hub Shorty - C2','Hub Shorty - C2')

SET IDENTITY_INSERT LDA.EntityClass OFF;

SELECT *
FROM LDA.EntityClass;
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- Part 4
-- Testcase (4)
-- Empty target data object
TRUNCATE TABLE LDA.EntityClass;

-- Reset InscriptionRecordID

-- Simulate FOJ (tbd)
INSERT INTO LDA.EntityClass (SourceTimestamp,ChangeDataIndicator,AuditTrailID,ModelCode,EntityClassCode,EntityClassName,Checksum)
VALUES (SYSUTCDATETIME(), 'C', -144, 'CoreLayerforShortcutObjects','SatShortyMainframe','Sat Shorty Mainframe','Sat Shorty Mainframe')


SELECT *
FROM LDA.EntityClass;
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
-- Part 5
-- Testcase (2)
-- Empty target data object
TRUNCATE TABLE LDA.EntityClass;

-- Reset InscriptionRecordID

-- Simulate FOJ (tbd)
INSERT INTO LDA.EntityClass (SourceTimestamp,ChangeDataIndicator,AuditTrailID,ModelCode,EntityClassCode,EntityClassName,Checksum)
VALUES (SYSUTCDATETIME(), 'C', -358, 'CoreLayerforShortcutObjects','SatShortyMainframe','Sat Shorty Mainframe','Sat Shorty Mainframe')
      ,(SYSUTCDATETIME(), 'C', -358, 'CoreLayerforShortcutObjects','HubShorty','Hub Shorty - C3','Hub Shorty - C3')


SELECT *
FROM LDA.EntityClass;
--------------------------------------------------------------------------------
