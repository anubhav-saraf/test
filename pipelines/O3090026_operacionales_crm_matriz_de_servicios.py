from prophecy_pipeline_sdk.graph import *
from prophecy_pipeline_sdk.properties import *
args = PipelineArgs(
    label = "O3090026_operacionales_crm_matriz_de_servicios",
    version = 1,
    auto_layout = False,
    params = Parameters(ref_data_date_part = 20260824)
)

with Pipeline(args) as pipeline:
    o3090026_operacionales_crm_matriz_de_servicios__table_1 = Process(
        name = "O3090026_operacionales_crm_matriz_de_servicios__Table_1",
        properties = ModelTransform(modelName = "O3090026_operacionales_crm_matriz_de_servicios__Table_1"),
        input_ports = ["in_0", "in_1", "in_2", "in_3", "in_4", "in_5", "in_6", "in_7", "in_8", "in_9"]
    )

