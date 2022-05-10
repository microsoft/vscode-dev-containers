#!/bin/bash

mkdir -p $1/$2
cd $1/$2
cp $1/scripts/pyspark-template.py ./$2.py
cd ..
sed -i -E "s/workspaceFolder}(.*)/workspaceFolder}\/${2}\/${2}.py\",/g" $1/.vscode/launch.json

echo Project ${2} was created!! Add now your pyspark code to file \"${1}/${2}/${2}.py\" \(a template was generated\).
