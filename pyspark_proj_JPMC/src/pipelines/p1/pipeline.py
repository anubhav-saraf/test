from pyspark.sql import *
from pyspark.sql.functions import *
from pyspark.sql.types import *
from pyspark_proj_JPMC.pipelines.p1.config.ConfigStore import *
from pyspark_proj_JPMC.pipelines.p1.graph import *

def pipeline(spark: SparkSession) -> None:
    df_single_record_mock = single_record_mock(spark)
    df_Reformat_1 = Reformat_1(spark, df_single_record_mock)

def main():
    spark = SparkSession.builder\
                .config("spark.default.parallelism", "4")\
                .config("spark.sql.legacy.allowUntypedScalaUDF", "true")\
                .enableHiveSupport()\
                .appName("Prophecy Pipeline")\
                .getOrCreate()
    Utils.initializeFromArgs(spark, parse_args())
    pipeline(spark)

if __name__ == "__main__":
    main()
