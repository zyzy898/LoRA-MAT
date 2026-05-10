from transformers import AutoTokenizer
import json, numpy as np

tokenizer = AutoTokenizer.from_pretrained("/hy-tmp/my-project/train_model/Qwen3.5-4B")

with open("/hy-tmp/my-project/train_data/code_train.json") as f:
    data = json.load(f)

lengths = []
for item in data:
    text = item.get("instruction", "") + item.get("output", "")
    lengths.append(len(tokenizer.encode(text)))

print(f"平均: {np.mean(lengths):.0f}")
print(f"90%分位: {np.percentile(lengths, 90):.0f}")
print(f"95%分位: {np.percentile(lengths, 95):.0f}")
print(f"最大: {max(lengths)}")