#!/bin/bash

# Inspired by: https://github.com/vtsynergy/SparkLeBLAST/blob/be16f5d5733a11d5a126dfac33230e2fcd338275/start_spark_slurm.sbatch 

#SBATCH --nodes=3
#SBATCH --ntasks=3
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=24
#SBATCH --output="logs/%j.out"
#SBATCH --error="logs/%j.err"
#SBATCH --time=24:00:00
#SBATCH --exclusive
#SBATCH --job-name=spark-cluster

# This section will be run when started by sbatch
if [ "$1" != 'srunning' ]; then
    this=$0

    module load jdk
    module load python/3.7.4

    export sparkLogs=logs/spark-master
    export sparkTmp=tmp/spark-master
    mkdir -p "$sparkLogs" "$sparkTmp"

    export SPARK_ROOT=$(pwd)/spark_home/spark-3.2.2-bin-hadoop3.2
    export SPARK_HOME=$SPARK_ROOT
    export SPARK_WORKER_DIR=$sparkLogs
    export SPARK_LOCAL_DIRS=$sparkLogs
    export SPARK_MASTER_PORT=7077
    export SPARK_MASTER_WEBUI_PORT=8080
    export SPARK_WORKER_CORES=$SLURM_CPUS_PER_TASK
    export SPARK_DAEMON_MEMORY=$(( $SLURM_MEM_PER_CPU * $SLURM_CPUS_PER_TASK / 2 ))m
    export SPARK_MEM=$SPARK_DAEMON_MEMORY
    
    # Assuming we are running on Euler because dirctories are shared
    script="$(pwd)/start_spark.sh"
    srun "$script" 'srunning'
# If run by srun, then decide by $SLURM_PROCID whether we are master or worker

else
    source "$SPARK_ROOT/sbin/spark-config.sh"
    source "$SPARK_ROOT/bin/load-spark-env.sh"
    if [ $SLURM_PROCID -eq 0 ]; then
        export SPARK_MASTER_IP=$(hostname)
        MASTER_NODE=$(scontrol show hostname $SLURM_NODELIST | head -n 1)

        # The saved IP address + port is necessary alter for submitting jobs
        echo "spark://$SPARK_MASTER_IP:$SPARK_MASTER_PORT" > "$sparkLogs/${SLURM_JOBID}_spark_master"

        "$SPARK_ROOT/bin/spark-class" org.apache.spark.deploy.master.Master \
            --ip $SPARK_MASTER_IP                                           \
            --port $SPARK_MASTER_PORT                                       \
            --webui-port $SPARK_MASTER_WEBUI_PORT
    
    else
    # fi
        # ulimit -m 31100000
        # $(scontrol show hostname) is used to convert e.g. host20[39-40]
        # to host2039 this step assumes that SLURM_PROCID=0 corresponds to 
        # the first node in SLURM_NODELIST !
        MASTER_NODE=spark://$(scontrol show hostname $SLURM_NODELIST | head -n 1):7077
        "$SPARK_ROOT/bin/spark-class" org.apache.spark.deploy.worker.Worker $MASTER_NODE
    fi
fi
