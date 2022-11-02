#!/bin/bash

mkdir -p spark_home
cd spark_home

wget https://dlcdn.apache.org/spark/spark-3.2.2/spark-3.2.2-bin-hadoop3.2.tgz
tar -xvzf spark-3.2.2-bin-hadoop3.2.tgz 

rm spark-3.2.2-bin-hadoop3.2.tgz
cd ..
