import os
import pandas as pd

def new_read_data(dir_path, output_csv_path):
    files = os.listdir(dir_path)

    data_list = []
    for file in files:
        if file.endswith(".m"):
            try:
                with open(os.path.join(dir_path, file), "r", encoding="utf-8") as f:
                    content = f.read()
                    content = content.strip()

                    # 删除以 % 开头的行
                    lines = content.splitlines()
                    lines = [line for line in lines if not line.lstrip().startswith("%")]
                    content = "\n".join(lines).strip()

                    if len(content) > 20:
                        data_list.append({"filename": file, "content": content})
            except Exception:
                continue
    
    df = pd.DataFrame(data_list)
    print(len(df))
    df.to_csv(output_csv_path, index=False, encoding="utf-8", escapechar='\\')

if __name__ == "__main__":
    new_read_data("source_data", "1-clean_data/data.csv")