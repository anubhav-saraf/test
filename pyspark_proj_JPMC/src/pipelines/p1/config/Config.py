from prophecy.config import ConfigBase
from pyspark.sql.functions import expr


class Config(ConfigBase):

    def __init__(self, test_config: str=None, **kwargs):
        self.spark = None
        self.test_config = None

    def update(self, test_config: str=None, _prophecy_project_parameter_set: str=None, **kwargs):
        prophecy_spark = self.spark

        if _prophecy_project_parameter_set == "uat_set":
            self.test_config = test_config or "string 1"
        else:
            self.test_config = test_config or "string 1"
