#!/bin/bash

source $1/$2/conf/databricks-config.sh
echo Running pyspark code for project ${2} !!
cd $1/$2
dbx execute --cluster-id=$DATABRICKS_CLUSTER_ID --job=${2}-job --no-rebuild --no-package
cd ..
