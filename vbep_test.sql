MERGE `gavitalfield.DS_CDC.vbep_test` AS T
USING (
  WITH
    S0 AS (
      SELECT * FROM `gavitalfield.DS_RAW.vbep_test`
      WHERE recordstamp >= (
        SELECT IFNULL(MAX(recordstamp), TIMESTAMP('1940-12-25 05:30:00+00'))
        FROM `gavitalfield.DS_CDC.vbep_test`)
    ),
    -- To handle occasional dups from SLT connector
    S1 AS (
      SELECT * EXCEPT(row_num)
      FROM (
        SELECT *, ROW_NUMBER() OVER (PARTITION BY VBELN, MANDT, ETENR, POSNR, recordstamp ORDER BY recordstamp) AS row_num
        FROM S0
      )
      WHERE row_num = 1
    ),
    T1 AS (
      SELECT VBELN, MANDT, ETENR, POSNR, MAX(recordstamp) AS recordstamp
      FROM `gavitalfield.DS_RAW.vbep_test`
      WHERE recordstamp >= (
        SELECT IFNULL(MAX(recordstamp), TIMESTAMP('1940-12-25 05:30:00+00'))
        FROM `gavitalfield.DS_CDC.vbep_test`)
      GROUP BY VBELN, MANDT, ETENR, POSNR
    )
  SELECT S1.*
  FROM S1
  INNER JOIN T1
    ON S1.`VBELN` = T1.`VBELN` AND S1.`MANDT` = T1.`MANDT` AND S1.`ETENR` = T1.`ETENR` AND S1.`POSNR` = T1.`POSNR`
      AND S1.recordstamp = T1.recordstamp
  ) AS S
ON S.`VBELN` = T.`VBELN` AND S.`MANDT` = T.`MANDT` AND S.`ETENR` = T.`ETENR` AND S.`POSNR` = T.`POSNR`
-- ## CORTEX-CUSTOMER You can use "`is_deleted` = true" condition along with "operation_flag = 'D'",
-- if that is applicable to your CDC set up.
WHEN NOT MATCHED AND IFNULL(S.operation_flag, 'I') != 'D' THEN
  INSERT (`mandt`,`wmeng`)
  VALUES (`mandt`, `wmeng`)
WHEN MATCHED AND S.operation_flag = 'D' THEN
  DELETE
WHEN MATCHED AND S.operation_flag = 'U' THEN
  UPDATE SET T.`mandt` = S.`mandt`, T.`wmeng` = S.`wmeng`;