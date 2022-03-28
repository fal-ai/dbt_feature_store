import io

model_name = context.current_model.name

output = f"Model name: {model_name}\n"

df = ref(context.current_model.name)
output += df.to_string()

f = open(f"temp/{model_name}", "w")
f.write(output)
f.close()
