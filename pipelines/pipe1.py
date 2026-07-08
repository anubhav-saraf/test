from prophecy_pipeline_sdk.graph import *
from prophecy_pipeline_sdk.properties import *
args = PipelineArgs(label = "pipe1", version = 1, auto_layout = False)

with Pipeline(args) as pipeline:
    pipe1__reformat_1 = Process(
        name = "pipe1__Reformat_1",
        properties = ModelTransform(modelName = "pipe1__Reformat_1"),
        input_ports = None
    )

