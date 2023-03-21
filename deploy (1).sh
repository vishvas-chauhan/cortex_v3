#!/bin/bash
# enable apis 
gcloud services enable bigquery.googleapis.com \
                       cloudbuild.googleapis.com \
                       composer.googleapis.com \
                       storage-component.googleapis.com \
                       cloudresourcemanager.googleapis.com
echo "Apis are enabled 🏆"
# clone the repo from cortex github

# git clone --recurse-submodules https://github.com/GoogleCloudPlatform/cortex-data-foundation
cd cortex-data-foundation
# Set project ID and bucket names
PROJECT_ID=gavitalfield
GCS_BUCKET=$PROJECT_ID-gcs-bucket
TGT_BUCKET=$PROJECT_ID-tgt-bucket
# RAW_BUCKET=$PROJECT_ID-raw-sap-data-demo


# Delete BigQuery datasets if they already exist
bq --project_id=$PROJECT_ID rm -f -r DS_CDC
bq --project_id=$PROJECT_ID rm -f -r DS_RAW
bq --project_id=$PROJECT_ID rm -f -r DS_REPORTING
bq --project_id=$PROJECT_ID rm -f -r DS_MODELS

# Delete GCS buckets if they already exist
gsutil rm -r gs://$GCS_BUCKET
gsutil rm -r gs://$TGT_BUCKET
# gsutil rm -r gs://$RAW_BUCKET
# Create BigQuery datasets
bq --project_id=$PROJECT_ID mk DS_CDC
bq --project_id=$PROJECT_ID mk DS_RAW
bq --project_id=$PROJECT_ID mk DS_REPORTING
bq --project_id=$PROJECT_ID mk DS_MODELS

# creating a bucket for raw data
# gsutil mb -p $PROJECT_ID -l US gs://$RAW_BUCKET
# gsutil cp -r gs://kittycorn-test-harness-us-central1/ecc/ gs://$RAW_BUCKET

# Create GCS buckets
gsutil mb -p $PROJECT_ID -l US gs://$GCS_BUCKET
gsutil mb -p $PROJECT_ID -l US gs://$TGT_BUCKET

# Submit Cloud Build job
gcloud builds submit --project $PROJECT_ID \
--substitutions \
_PJID_SRC=$PROJECT_ID,_PJID_TGT=$PROJECT_ID,\
_DS_CDC=DS_CDC,\
_DS_RAW=DS_RAW,\
_DS_REPORTING=DS_REPORTING,\
_DS_MODELS=DS_MODELS,\
_GCS_BUCKET=$GCS_BUCKET,\
_TGT_BUCKET=$TGT_BUCKET,\
_TEST_DATA=true,\
_DEPLOY_CDC=true,\
_GEN_EXT=true,\
_DEPLOY_SAP=true,\
_DEPLOY_SFDC=false
