/*******************************************************************************
 * Data Engine Thinking
 *******************************************************************************
 *
 * Purpose:
 *   - Create sample integration layer data objects (Hub and Satellites).
 *
 * Disclaimer:
 *   - See disclaimer.md in the repository root.
 *
 ******************************************************************************/

-- Drop objects
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Hub_Customer]') AND type in (N'U'))
DROP TABLE [dbo].[Hub_Customer]

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Sat_Customer_Details_Contact]') AND type in (N'U'))
DROP TABLE [dbo].[Sat_Customer_Details_Contact]
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Sat_Customer_Details_Sales]') AND type in (N'U'))
DROP TABLE [dbo].[Sat_Customer_Details_Sales]
GO

CREATE TABLE [dbo].[Hub_Customer](
	[Customer_Surrogate_Key] [binary](20) NOT NULL,
	[Audit_Trail_Id] [int] NOT NULL,
	[Customer_Code] [nvarchar](max) NOT NULL,
 CONSTRAINT [PK_HUB_CUSTOMER] PRIMARY KEY NONCLUSTERED 
(
	[Customer_Surrogate_Key] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[Sat_Customer_Details_Contact](
	[Customer_Surrogate_Key] [binary](20) NOT NULL,
	[Inscription_Timestamp] [datetime2](7) NOT NULL,
	[Inscription_Record_Id] [int] NOT NULL,
	[State_From_Timestamp] [datetime2](7) NULL,
	[State_Before_Timestamp] [datetime2](7) NULL,
	[Audit_Trail_Id] [int] NULL,
	[Customer_Contact_Number] [varchar](MAX) NULL,
	[Customer_Email_Address] [varchar](max) NULL,
	[Customer_Contact_Preferences] [varchar](MAX) NULL,
 CONSTRAINT [PK_SAT_CUSTOMER2] PRIMARY KEY CLUSTERED 
(
	[Customer_Surrogate_Key] ASC,
	[Inscription_Timestamp] ASC,
	[Inscription_Record_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[Sat_Customer_Details_Sales](
	[Customer_Surrogate_Key] [binary](16) NOT NULL,
	[Inscription_Timestamp] [datetime2](7) NOT NULL,
	[Inscription_Record_Id] [int] NOT NULL,
	[State_From_Timestamp] [datetime2](7) NULL,
	[State_Before_Timestamp] [datetime2](7) NULL,
	[Audit_Trail_Id] [int] NULL,
	[Customer_First_Name] [varchar](100) NULL,
	[Customer_Birth_Date] [binary](16) NULL,
 CONSTRAINT [PK_SAT_CUSTOMER] PRIMARY KEY CLUSTERED 
(
	[Customer_Surrogate_Key] ASC,
	[Inscription_Timestamp] ASC,
	[Inscription_Record_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

-- Data
INSERT INTO [dbo].[Hub_Customer]
           ([Customer_Surrogate_Key]
           ,[Audit_Trail_Id]
           ,[Customer_Code])
     VALUES
		   (
			(SELECT HASHBYTES('SHA1', 'Roelant')),	1,	'Roelant'
		   ),
		   (
			(SELECT HASHBYTES('SHA1', 'Dirk')),	1,	'Dirk'
		   )
;

