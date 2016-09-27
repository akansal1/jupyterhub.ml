import glob
import os
import sys

# See ipython-notebook-spark.py for cluster mode (YARN or Standalone)

spark_home = os.getenv('SPARK_HOME', None)
if not spark_home:
    raise ValueError('SPARK_HOME environment variable is not set')
sys.path.insert(0, os.path.join(spark_home, 'python'))
for lib in glob.glob(os.path.join(spark_home, 'python/lib/py4j-*-src.zip')):
    sys.path.insert(0, lib)

# TODO:  Build up $PYSPARK_SUBMIT_ARGS from...
#          --master $SPARK_HMASTER_HOST:$SPARK_MASTER_PORT
#          --jars $SPARK_SUBMIT_JARS
#          --repositories $SPARK_SUBMIT_REPOSITORIES
#          --packages $SPARK_SUBMIT_PACKAGES
#          pyspark-shell <-- DON'T FORGET THIS!!
# PYSPARK_SUBMIT_ARGS=" --master $SPARK_MASTER_HOST:$SPARK_MASTER_PORT pyspark-shell"

os.environ['PYSPARK_SUBMIT_ARGS']='--master spark://spark.datasticks.com:7077 --packages com.amazonaws:aws-java-sdk:1.10.34,org.apache.hadoop:hadoop-aws:2.6.0,databricks:tensorframes:0.2.3-s_2.10 --jars /root/lib/jpmml-sparkml-package-1.0-SNAPSHOT.jar --py-files /root/lib/jpmml.py pyspark-shell'

execfile(os.path.join(spark_home, 'python/pyspark/shell.py'))
