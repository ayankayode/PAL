SET SCHEMA PAL;

-- cleanup
DROP TYPE PAL_T_DF_DATA;
DROP TYPE PAL_T_DF_PARAMS;
DROP TYPE PAL_T_DF_RESULTS;
DROP TYPE PAL_T_DF_STATS;
DROP TABLE PAL_DF_SIGNATURE;
CALL SYSTEM.AFL_WRAPPER_ERASER ('PAL_DF');
DROP TABLE DF_RESULTS;
DROP TABLE DF_STATS;

-- PAL setup
CREATE TYPE PAL_T_DF_DATA AS TABLE (VALUE DOUBLE);
CREATE TYPE PAL_T_DF_PARAMS AS TABLE (NAME VARCHAR(60), INTARGS INTEGER, DOUBLEARGS DOUBLE, STRINGARGS VARCHAR (100));
CREATE TYPE PAL_T_DF_RESULTS AS TABLE (NAME VARCHAR(50), VALUE VARCHAR(100));
CREATE TYPE PAL_T_DF_STATS AS TABLE (NAME VARCHAR(50), VALUE DOUBLE);

CREATE COLUMN TABLE PAL_DF_SIGNATURE (ID INTEGER, TYPENAME VARCHAR(100), DIRECTION VARCHAR(100));
INSERT INTO PAL_DF_SIGNATURE VALUES (1, 'PAL.PAL_T_DF_DATA', 'in');
INSERT INTO PAL_DF_SIGNATURE VALUES (2, 'PAL.PAL_T_DF_PARAMS', 'in');
INSERT INTO PAL_DF_SIGNATURE VALUES (3, 'PAL.PAL_T_DF_RESULTS', 'out');
INSERT INTO PAL_DF_SIGNATURE VALUES (4, 'PAL.PAL_T_DF_STATS', 'out');

GRANT SELECT ON PAL_DF_SIGNATURE TO SYSTEM;
CALL SYSTEM.AFL_WRAPPER_GENERATOR ('PAL_DF', 'AFLPAL', 'DISTRFIT', PAL_DF_SIGNATURE);

-- app setup
CREATE COLUMN TABLE DF_RESULTS LIKE PAL_T_DF_RESULTS;
CREATE COLUMN TABLE DF_STATS LIKE PAL_T_DF_STATS;

-- app runtime
DROP TABLE #DF_PARAMS;
CREATE LOCAL TEMPORARY COLUMN TABLE #DF_PARAMS LIKE PAL_T_DF_PARAMS;
INSERT INTO #DF_PARAMS VALUES ('DISTRIBUTIONNAME', null, null, 'WEIBULL'); -- Normal, Gamma, Weibull, Uniform
INSERT INTO #DF_PARAMS VALUES ('OPTIMAL_METHOD', 0, null, null); -- 0: max likelihood, 1: median rank (Weibull only)

TRUNCATE TABLE DF_RESULTS;
TRUNCATE TABLE DF_STATS;

CALL _SYS_AFL.PAL_DF (FAILURES, #DF_PARAMS, DF_RESULTS, DF_STATS) WITH OVERVIEW;

SELECT * FROM DF_RESULTS;
SELECT * FROM DF_STATS;
