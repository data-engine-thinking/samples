/*******************************************************************************
 * Data Engine Thinking
 *******************************************************************************
 *
 * Purpose:
 *   - SQL example for Continuous Gap Compacting.
 *
 * Disclaimer:
 *   - See disclaimer.md in the repository root.
 *
 ******************************************************************************/

-- DDL for table creation
DROP TABLE IF EXISTS FastChangeCoData;

CREATE TABLE FastChangeCoData
(
  Surrogate_Key NVARCHAR(50),
  From_Timestamp DATETIME,
  Satellite_1_Value NVARCHAR(50),
  Satellite_2_Value NVARCHAR(50)
);

-- INSERT statements for the data
INSERT INTO FastChangeCoData (Surrogate_Key, From_Timestamp, Satellite_1_Value, Satellite_2_Value)
VALUES ('FastChangeCo\@|', '2025-02-03 22:01:52', 'Satellite 1 change 1', NULL);

INSERT INTO FastChangeCoData (Surrogate_Key, From_Timestamp, Satellite_1_Value, Satellite_2_Value)
VALUES ('FastChangeCo\@|', '2025-02-03 22:01:54', 'Satellite 1 change 2', NULL);

INSERT INTO FastChangeCoData (Surrogate_Key, From_Timestamp, Satellite_1_Value, Satellite_2_Value)
VALUES ('FastChangeCo\@|', '2025-02-03 22:55:45', 'Satellite 1 change 2', 'Satellite 2 change 1');

INSERT INTO FastChangeCoData (Surrogate_Key, From_Timestamp, Satellite_1_Value, Satellite_2_Value)
VALUES ('FastChangeCo\@|', '2025-02-03 23:01:54', 'Satellite 1 change 3', 'Satellite 2 change 1');

INSERT INTO FastChangeCoData (Surrogate_Key, From_Timestamp, Satellite_1_Value, Satellite_2_Value)
VALUES ('FastChangeCo\@|', '2025-02-03 23:25:00', 'Satellite 1 change 3', 'Satellite 2 change 2');

INSERT INTO FastChangeCoData (Surrogate_Key, From_Timestamp, Satellite_1_Value, Satellite_2_Value)
VALUES ('FastChangeCo\@|', '2025-02-03 23:25:10', 'Satellite 1 change 3', 'Satellite 2 change 3');

INSERT INTO FastChangeCoData (Surrogate_Key, From_Timestamp, Satellite_1_Value, Satellite_2_Value)
VALUES ('FastChangeCo\@|', '2025-02-04 10:00:00', 'Satellite 1 change 4', 'Satellite 2 change 3');

INSERT INTO FastChangeCoData (Surrogate_Key, From_Timestamp, Satellite_1_Value, Satellite_2_Value)
VALUES ('FastChangeCo\@|', '2026-06-01 12:35:00', 'Satellite 1 change 4', 'Satellite 2 change 4');
GO
SELECT *
FROM FastChangeCoData;

-- Continuous Gap Compacting

-- Organize the values within the selected frequency
-- Calculate the time difference with the next row (lead ascending)
SELECT * FROM
(
  SELECT 
    [Surrogate_Key],
    [From_Timestamp],
    DATEDIFF (
	  MINUTE,
      [From_Timestamp],
      LEAD([From_Timestamp])
        OVER (PARTITION BY [Surrogate_Key]
          ORDER BY [From_Timestamp])
      ) AS [Gap_Minutes]
  FROM FastChangeCoData
) t
WHERE [Gap_Minutes] >= 30
   OR [Gap_Minutes] IS NULL
;

/*
SELECT [Surrogate_Key],
       [From_Timestamp],
       LEAD([From_Timestamp]) OVER (
                       PARTITION BY [Surrogate_Key]
                       ORDER BY [From_Timestamp])
        AS Lead_From_Timestamp,
       DATEDIFF (MINUTE,
                 [From_Timestamp],
                 LEAD([From_Timestamp]) OVER (
                       PARTITION BY [Surrogate_Key]
                       ORDER BY [From_Timestamp])
       )
FROM FastChangeCoData
*/
