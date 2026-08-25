import prophecy_automate
from pyspark.sql import *
from pyspark.sql.functions import *
from pyspark.sql.types import *
from prophecy.utils import *
from pyspark_proj_JPMC.pipelines.p1.config.ConfigStore import *

def show_config_values(spark: SparkSession, in0: DataFrame) -> DataFrame:  # pragma: no cover
    in0.select("id", "config_val").show()
        
    return in0

    return out0
