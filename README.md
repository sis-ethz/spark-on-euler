# spark-on-euler

Scripts to run Spark on Euler.

#### Setup

1. Install Spark on Euler using the script `get_spark.sh`. This will download and unpack spark in `./spark_home`.
2. run `./setup.sh` to create local dirs used by spark

#### Run Spark

To setup a spark cluster on Euler, you need to the following steps:

- First start a master node using the script `start_master.sh`.
- Once the node is up and running, you can start the web GUI by forwarding port 8080 on euler to your local machine,
  using
  `ssh -N -L 8080:<master_node>:8080 euler`. In your browser, go to `localhost:8080` to see the web GUI.
- To start workers, use the script `start_worker.sh`. You can start as many worker nodes as you want by changing
  the `#SBATCH --array=1-<num_workers>` pragma.
- Once the workers have successfully started, you will see them under the workers tab in the web GUI. 