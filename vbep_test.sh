#!/bin/bash
set -e
echo "Install required package 📦📦📦"
pip install -r requirements.txt
# bq cp gavitalfield:DS_CDC.vbep gavitalfield:DS_CDC.vbep_test

bq query --use_legacy_sql=false '
CREATE or REPLACE TABLE `gavitalfield.DS_CDC.vbep_test`
OPTIONS(
  expiration_timestamp=TIMESTAMP_ADD(CURRENT_TIMESTAMP(), INTERVAL 365 DAY),
  description="Empty table with the same schema as CDC vbep"
) AS SELECT * FROM `gavitalfield.DS_CDC.vbep` WHERE 1=0'

echo "CDC table created for vbep_test with same schema ✅"

bq query --use_legacy_sql=false '
CREATE or REPLACE TABLE  `gavitalfield.DS_RAW.vbep_test`
OPTIONS(
  expiration_timestamp=TIMESTAMP_ADD(CURRENT_TIMESTAMP(), INTERVAL 365 DAY),
  description="Empty table with the same schema as CDC vbep"
) AS SELECT * FROM `gavitalfield.DS_RAW.vbep` WHERE 1=0'


echo "RAW table has been created for vbep_test with same schema ✅"

gsutil cp gs://gavitalfield-raw-sap-data-demo/ecc/vbep.parquet .

# these variable are passed into vbep_edit.py file
OF=$1
CID=$2
python vbep_edit.py --OF $OF --CID $CID
# python vbep_edit.py --OF D

gsutil cp vbep_test.parquet gs://gavitalfield-raw-sap-data-demo/ecc/
echo "File has been uploaded to GCS for vbep_test ✅"



bq load --replace --source_format=PARQUET gavitalfield:DS_RAW.vbep_test gs://gavitalfield-raw-sap-data-demo/ecc/vbep_test.parquet

echo "New RAW data LOADED for table vbep_test ✅"


bq query \
  --use_legacy_sql=false \
  "$(cat vbep_test.sql)"



echo -e "\n 🧹🧹🧹 After work cleaning 🧹🧹🧹"
rm vbep_test.parquet vbep.parquet

echo "⤵️ See the CDC in new dashboard 🏆"
echo "The link to the dashboard is: 'https://lookerstudio.google.com/u/0/reporting/c28e0e30-8cf8-4fd4-bd97-0a188a664e5b/page/tEnnC"
echo " "


# SELECT mandt, operation_flag FROM `gavitalfield.DS_RAW.vbep_test` where mandt = '100'