# prompt = '<|fim_prefix|>' + prefix_code + '<|fim_suffix|>' + suffix_code + '<|fim_middle|>'
import json
from pathlib import Path

def trans_data(path, save_path):
    with open(path, encoding="utf-8") as f:
        data = json.load(f)
    result = []

    for d in data:
        prefix_code = d["prefix"]
        suffix_code = d["suffix"]
        middle_code = d["middle"]

        prompt = '<|fim_prefix|>' + prefix_code + '<|fim_suffix|>' + suffix_code + '<|fim_middle|>'

        result.append({
            "instruction": prompt,
            "input": "",
            "output": middle_code,
            "chunk_id": d["chunk_id"],
            "file_index": d["file_index"],
            "file_name": d["file_name"],
            "score": d["score"],
            "mode": d["mode"],
        })

    with open(save_path, "w", encoding="utf-8") as f:
        f.write(json.dumps(result, indent=4, ensure_ascii=False))


if __name__ == "__main__":
    script_dir = Path(__file__).parent
    trans_data(script_dir / r'D:/UserData/Desktop/LORA-MAT/6-creat_train_datas/split_result/train.json', script_dir / r'./code_train.json')
    trans_data(script_dir / r'D:/UserData/Desktop/LORA-MAT/6-creat_train_datas/split_result/test.json', script_dir / r'./code_test.json')