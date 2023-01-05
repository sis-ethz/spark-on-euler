#!/bin/bash

#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=32
#SBATCH --output="./logs/slurm_%j_%n.out"
#SBATCH --error="./logs/slurm_%j_%n.err"
#SBATCH --time=00:40:00
#SBATCH --job-name=s-cluster
#SBATCH --array=1-2  # change this to 1-<n_workers> to spawn n_workers workers

# load moules
module load jdk
module load python/3.7.4

CLASS="org.apache.spark.deploy.worker.Worker"

# setup dirs for logging
LOGS_DIR="$(pwd)/logs/spark-worker-$SLURM_ARRAY_TASK_ID_$(hostname)"
mkdir -p "$LOGS_DIR"

# set spark env variables
export SPARK_ROOT
SPARK_ROOT=$(pwd)/spark_home/spark-3.2.3-bin-hadoop3.2

export SPARK_HOME=$SPARK_ROOT
export SPARK_WORKER_DIR=$LOGS_DIR
export SPARK_LOCAL_DIRS=$LOGS_DIR
export SPARK_MASTER_PORT=7077
export SPARK_MASTER_WEBUI_PORT=8080
export SPARK_WORKER_CORES=$SLURM_CPUS_PER_TASK
export SPARK_DAEMON_MEMORY=2G
export SPARK_WORKER_MEM=30G

source "$SPARK_ROOT/sbin/spark-config.sh"
source "$SPARK_ROOT/bin/load-spark-env.sh"

# read master node address
MASTER_FILE=$(ls -I "spark-*" -I "app-*" -t "$(pwd)"/logs/spark-master/ | head -1)
SPARK_MASTER_NODE=$(cat "$(pwd)"/logs/spark-master/"$MASTER_FILE")

# spawn worker
echo "Starting worker $SLURM_ARRAY_TASK_ID on node: $(hostname); master node: $SPARK_MASTER_NODE"
"$SPARK_ROOT/bin/spark-class" $CLASS "$SPARK_MASTER_NODE"
