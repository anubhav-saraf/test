from pyspark.sql import *
from pyspark.sql.functions import *
from pyspark.sql.types import *
from prophecy.utils import *
from pyspark_proj_JPMC.pipelines.p1.config.ConfigStore import *

def single_record_mock(spark: SparkSession, ) -> DataFrame:
    inDFs = []

    for var_name, var_value in dict(locals()).items():
        if var_value in inDFs:
            var_value.createOrReplaceTempView(var_name)

    return spark.sql("select 1 as id, \"abc\" as name")
