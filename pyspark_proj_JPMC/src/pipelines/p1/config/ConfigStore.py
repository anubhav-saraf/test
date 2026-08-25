from pyspark.sql import SparkSession
from prophecy.config.utils import *
from .Config import Config as ConfigClass
Config: ConfigClass = ConfigClass()


class Utils:
    @staticmethod
    def initializeFromArgs(spark: SparkSession, args):
        global Config
        Config.updateSpark(spark)
        _prophecy_project_parameter_set = getattr(args, "projectConfInstance", None)
        if _prophecy_project_parameter_set in {"uat_set"}:
            args.projectConfInstance = None
        else:
            _prophecy_project_parameter_set = None
        conf = parse_config(args)
        Config.update(_prophecy_project_parameter_set = _prophecy_project_parameter_set, **conf)
