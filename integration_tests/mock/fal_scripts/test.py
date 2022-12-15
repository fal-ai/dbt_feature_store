from fal.typing import *
import pandas as pd

assert context.current_model
model_name = context.current_model.name

df: pd.DataFrame = ref(model_name)

df.to_json(f"temp/{model_name}.json", date_format='epoch', double_precision=0, orient='values')
