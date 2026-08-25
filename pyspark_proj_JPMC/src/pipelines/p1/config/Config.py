from prophecy.config import ConfigBase
from pyspark.sql.functions import expr


class Config(ConfigBase):

    def __init__(self, **kwargs):
        self.spark = None

    def update(self, **kwargs):
        prophecy_spark = self.spark
