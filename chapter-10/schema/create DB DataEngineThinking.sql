/*

.SYNOPSIS
    Create database for FastChangeCo MVP

.DESCRIPTION
    Create database for FastChangeCo MVP with all schemas needed
    Optional: Assign user to database

.NOTES
    (C) 2024 Dirk Lerner
    File Name      : create DB DataEngineThinking.sql
    Prerequisite   : MS SQL Server
    Author         : Dirk Lerner
    Version        : 1.0.0
    Date           : 20240609

*/

USE [master]
GO
ALTER DATABASE [DataEngineThinking] SET SINGLE_USER WITH ROLLBACK IMMEDIATE
DROP DATABASE IF EXISTS [DataEngineThinking]
GO

CREATE DATABASE [DataEngineThinking]
COLLATE Latin1_General_CS_AS;
GO

ALTER DATABASE [DataEngineThinking] SET MULTI_USER
ALTER DATABASE [DataEngineThinking] SET RECOVERY SIMPLE WITH NO_WAIT
GO

USE [DataEngineThinking]
GO
CREATE SCHEMA Source;
GO
CREATE SCHEMA PSA;
GO
CREATE SCHEMA LDA;
GO

-- Optional: Assign user to database

DECLARE @database   NVARCHAR(120) = '[DataEngineThinking]';
DECLARE @SQL        NVARCHAR(MAX);
DECLARE @user       NVARCHAR(20);

SET @user  = 'Dirk';

SET @SQL = '
/* check if exists and drop */
IF database_principal_id(''' + @user + ''') IS NOT NULL
    DROP USER [' + @user + '];

CREATE USER [' + @user + '] FOR LOGIN [' + @user + '];
;
ALTER ROLE [db_datareader] ADD MEMBER [' + @user + '];
ALTER ROLE [db_datawriter] ADD MEMBER [' + @user + '];
ALTER ROLE [db_ddladmin] ADD MEMBER [' + @user + '];
GRANT EXECUTE TO [' + @user + '];
GRANT CONTROL ON DATABASE::' + @database + ' TO [' + @user + '];
'

PRINT @SQL;
EXEC(@SQL);
;
