from pyspark.sql import *
from pyspark.sql.functions import *
from pyspark.sql.types import *
from prophecy.utils import *
from pyspark_proj_JPMC.pipelines.p1.config.ConfigStore import *

def Reformat_1(spark: SparkSession, in0: DataFrame) -> DataFrame:
    return in0.select(col("id"), col("name"), lit(Config.test_config).alias("config_val"))
