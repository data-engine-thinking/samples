-- DDL for table creation
DROP TABLE IF EXISTS FastChangeCoData;

CREATE TABLE FastChangeCoData (
    Surrogate_Key NVARCHAR(50),
    From_Timestamp DATETIME,
    Time_Compacter DATETIME
);

-- INSERT statements for the data
INSERT INTO FastChangeCoData (Surrogate_Key, From_Timestamp, Time_Compacter)
VALUES ('FastChangeCo\@|', '2025-02-03 22:01:52', '2025-02-03 22:55:45');

INSERT INTO FastChangeCoData (Surrogate_Key, From_Timestamp, Time_Compacter)
VALUES ('FastChangeCo\@|', '2025-02-03 22:01:54', '2025-02-03 22:55:45');

INSERT INTO FastChangeCoData (Surrogate_Key, From_Timestamp, Time_Compacter)
VALUES ('FastChangeCo\@|', '2025-02-03 22:55:45', '2025-02-03 22:55:45');

INSERT INTO FastChangeCoData (Surrogate_Key, From_Timestamp, Time_Compacter)
VALUES ('FastChangeCo\@|', '2025-02-03 23:01:54', '2025-02-03 23:25:10');

INSERT INTO FastChangeCoData (Surrogate_Key, From_Timestamp, Time_Compacter)
VALUES ('FastChangeCo\@|', '2025-02-03 23:25:00', '2025-02-03 23:25:10');

INSERT INTO FastChangeCoData (Surrogate_Key, From_Timestamp, Time_Compacter)
VALUES ('FastChangeCo\@|', '2025-02-03 23:25:10', '2025-02-03 23:25:10');

INSERT INTO FastChangeCoData (Surrogate_Key, From_Timestamp, Time_Compacter)
VALUES ('FastChangeCo\@|', '2025-02-04 10:00:00', '2025-02-04 10:00:00');

INSERT INTO FastChangeCoData (Surrogate_Key, From_Timestamp, Time_Compacter)
VALUES ('FastChangeCo\@|', '2026-06-01 12:35:00', '2026-06-01 12:35:00');
GO
SELECT *
FROM FastChangeCoData;

-- Frequncy Compacting

SELECT [Surrogate_Key],
    [From_Timestamp],
    [Time_Compacter] AS [Check_Time_Compacter],
FIRST_VALUE([From_Timestamp])
    OVER (PARTITION BY [Surrogate_Key],
          DATEPART(YEAR,[From_Timestamp]),
          DATEPART(MONTH,[From_Timestamp]),
          DATEPART(DAY,[From_Timestamp]),
          DATEPART(HOUR,[From_Timestamp])
          ORDER BY [From_Timestamp] DESC)
    AS [Time_Compacter]
FROM FastChangeCoData
;


SELECT DATEDIFF(MINUTE, '2025-01-01 16:59', '2025-01-01 17:01')

-- Continuous Gap Compacting

-- Organize the values within the selected frequency
-- Calculate the time difference with the next row (lead ascending)
SELECT * FROM
(SELECT [Surrogate_Key],
    [From_Timestamp],
    DATEDIFF (MINUTE,
    [From_Timestamp],
    LEAD([From_Timestamp])
    OVER (PARTITION BY [Surrogate_Key]
          ORDER BY [From_Timestamp])
) AS [Gap_Minutes]
FROM FastChangeCoData) t
WHERE [Gap_Minutes] >= 30
   OR [Gap_Minutes] IS NULL
;

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
