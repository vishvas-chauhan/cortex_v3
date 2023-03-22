### This repo takes sample files from public sap bucket
 - To upload those file into your bucket 
```bash
PROJECT_ID=<project_id>
RAW_BUCKET=$PROJECT_ID-raw-sap-data-demo
# creating a bucket for raw data
gsutil mb -p $PROJECT_ID -l US gs://$RAW_BUCKET
gsutil cp -r gs://kittycorn-test-harness-us-central1/ecc/ gs://$RAW_BUCKET
```
#### Add the IAM role for a new service account 
###### <Project_number>.@cloudbuild.gserviceaccount.com
![cloud build IAM only](./iam_cloudbuild.jpg)
 - Then clone the repo 
 ```bash
 git clone --recurse-submodules https://github.com/GoogleCloudPlatform/cortex-data-foundation
 cd cortex-data-foundation
 ```

 - Then run deploy.sh file.
 ``` bash 
 chmod +x deploy.sh
 ./deploy.sh
```

 - You data will be ready into BiqQuery

### Now its time to make the test 
 - Test part will be done on adr6 file
 ```bash 
  chmod +x vbpe_test.sh
 ./vbep_test.sh
 ```
   - This will create copy of vbep parquet file into your bucket by editing operation flag. 
   - We create a raw Table in RAW dataset that gets the data as soon as data updates in GCS Raw bucket. 
   - Then we create an empty table in CDC dataset to detect the change based on some queries.
   - Then it will make some change into that file for client 100 and Put tag D or L in operation flag column.
   - It will upload the file into a new table
   - You will see following Row has been updated from the CDC table
   - Then it will generate a video for reporting 
   - You will see reporting Dashboard is showing accurate and updated data. 
 

