/*******************************************************************************
 * Data Engine Thinking
 *******************************************************************************
 *
 * Purpose:
 *   - Create or reset the sample database, set collation and recovery, and create PSA/LDA schemas and a sample user.
 *
 * Disclaimer:
 *   - See disclaimer.md in the repository root.
 *
 ******************************************************************************/

USE [master]
GO

DROP DATABASE IF EXISTS [DataEngineThinking]
GO

CREATE DATABASE [DataEngineThinking]
COLLATE Latin1_General_CS_AS;
GO

ALTER DATABASE [DataEngineThinking] SET RECOVERY SIMPLE WITH NO_WAIT
GO

USE [DataEngineThinking]
GO
CREATE SCHEMA [PSA];
GO
CREATE SCHEMA [LDA];
GO

DECLARE @database   NVARCHAR(120) = '[DataEngineThinking]';
DECLARE @SQL        NVARCHAR(MAX);
DECLARE @user       NVARCHAR(20);

SET @user  = 'DataEngineThinker';

SET @SQL = '
/* Create the sample login and user. */

IF NOT EXISTS (SELECT * FROM sys.sql_logins WHERE name = N''DataEngineThinker'')
    CREATE LOGIN [DataEngineThinker] WITH PASSWORD = N''DefaultPassword123!'';

IF database_principal_id(''' + @user + ''') IS NOT NULL
    DROP USER [' + @user + '];

CREATE USER [' + @user + '] FOR LOGIN [' + @user + '];
ALTER ROLE [db_datareader] ADD MEMBER [' + @user + '];
ALTER ROLE [db_datawriter] ADD MEMBER [' + @user + '];
ALTER ROLE [db_ddladmin] ADD MEMBER [' + @user + '];
GRANT EXECUTE TO [' + @user + '];
GRANT CONTROL ON DATABASE::' + @database + ' TO [' + @user + '];
'

PRINT @SQL;
EXEC(@SQL);

