import os
import fire
import glob
import gzip
import random
import concurrent.futures
from typing import *
from tqdm.auto import tqdm
from infilling import InFilling
import json
from tqdm import tqdm
from transformers import AutoTokenizer



def stream_jsonl(filename: str):
    """
    Parses each jsonl line and yields it as a dictionary
    """
    if filename.endswith(".gz"):
        with open(filename, "rb") as gzfp:
            with gzip.open(gzfp, "rt") as fp:
                for line in fp:
                    # if any(not x.isspace() for x in line):
                    yield json.loads(line)
    else:
        with open(filename, "r",encoding="utf-8") as fp:
            datas = json.load(fp)
            print(len(datas))
        try :
            for data in datas:
                yield data
        except:
            yield None


def choose_mode(modes, weights):
    return random.choices(modes, weights, k=1)[0]

def get_all_file_paths(directory):
    file_paths = []  # List to store file paths
    for root, directories, files in os.walk(directory):
        for filename in files:
            # Join the two strings to form the full filepath.
            filepath = os.path.join(root, filename)
            if filepath.endswith(".json"):
                file_paths.append(filepath)  # Add it to the list.
    return file_paths

def process(obj):
    chosen_mode = choose_mode(modes, weights)

    results = InFilling(obj['content'], obj['language'], chosen_mode,times[chosen_mode])
    if len(results) == 0:
        return []
    contents = []
    for prefix,middle,suffix in results:
        # print(chosen_mode)
        content = {
            "chunk_id":obj["chunk_id"],
            "file_index":obj["file_index"],
            "file_name":obj["file_name"],
            "score":obj["score"],
            "language": obj['language'],
            "prefix": prefix,
            "middle": middle,
            "suffix": suffix,
            "mode":chosen_mode
        }
        contents.append(content)
    return contents


def process_file(file_path):
    global split_dir, strategy

    print(f"Processing {file_path}")

    name = os.path.basename(file_path)
    save_name = os.path.join(split_dir, f"{name}")
    
    with open(save_name, "w",encoding="utf-8") as f_out:
        data = stream_jsonl(file_path)
        for d in data:
            if d:
                # result = json.dumps( process(d),ensure_ascii=False)
                results = process(d)
                if len(results) != 0:
                    for result in results:
                        result = json.dumps(result,ensure_ascii=False)
                        f_out.write(result + "\n")

    
def main(num_workers: int = 1):
    global data_dir,split_dir,strategy
    data_list = get_all_file_paths(data_dir)
    print(data_list)
    with concurrent.futures.ThreadPoolExecutor(max_workers=num_workers) as executor:

        # 使用list comprehension来启动每个线程并获取结果
        results = [result for result in executor.map(process_file, data_list)] # data_list每个元素做process_file

def split_train_test():
    train_file = "train.json"
    test_file = "test.json"
    if not os.path.exists(result_dir):
        os.makedirs(result_dir)

    files = os.listdir(split_dir)
    tokenizer = AutoTokenizer.from_pretrained(os.path.join(os.path.dirname(__file__), "tokenizer_file"), trust_remote_code=True)

    all_data = []
    for split_file in files:
        split_file = os.path.join(split_dir, split_file)
        with open(split_file, encoding="utf-8") as f:
            all_data += f.readlines()
    random.shuffle(all_data)

    new_data = []
    for data in tqdm(all_data[:]):
        # if len(data)<200:
        #     continue
        data = json.loads(data)
        prefix = data["prefix"]
        middle = data["middle"]
        suffix = data["suffix"]


        t1, t2, t3 = tokenizer([prefix, middle, suffix], add_special_tokens=False, return_attention_mask=False)["input_ids"]

        l1, l2, l3 = len(t1), len(t2), len(t3)

        i = 0
        while len(t1) + len(t2) + len(t3) > 1000:  # 2048+512
            if i >= 10:
                i = -999
                break
            if len(t3) >= len(t1):
                t3 = t3[: len(t3) // 2]
            else:
                t1 = t1[len(t1) //2 :]

            i += 1
        if i == -999:
            continue
        if len(t1) != l1:
            data["prefix"] = tokenizer.decode(t1)
        if len(t3) != l3:
            data["suffix"] = tokenizer.decode(t3)

        data["prefix"] = data["prefix"].strip("\n")
        data["suffix"] = data["suffix"].strip("\n")
        data["middle"] = data["middle"].strip("\n")

        # print(data["middle"])
        # print("*"*100)
        new_data.append(data)
        # if len(new_data)>1000:
        #     break

    test_data = new_data[:int(len(new_data) * test_rate)]
    train_data = new_data[int(len(new_data) * test_rate):]

    with open(os.path.join(result_dir,train_file), "w", encoding="utf-8") as f1:
        json.dump(train_data,f1,ensure_ascii=False,indent=4)
    with open(os.path.join(result_dir,test_file), "w", encoding="utf-8") as f2:
        json.dump(test_data,f2,ensure_ascii=False,indent=4)

    print(f"总长度：{len(all_data)}")
    print(f"训练集长度：{len(train_data)}")
    print(f"测试集长度：{len(test_data)}")
    get_sameples()

def get_sameples():
    f2 = open(os.path.join(result_dir,"samples.txt"), "w", encoding="utf-8")
    with open(os.path.join(result_dir,"train.json"), "r", encoding="utf-8") as f:
        all_data = json.loads(f.read())
    for data in all_data[:200]:
            f2.write("*" * 200 + "\n")
            # data = eval(data)
            f2.write("*" * 30 + "prefix:" + "*" * 30 + "\n")
            f2.write(data["prefix"] + "\n")


            f2.write("*" * 30 + "middle:" + str(len(data["middle"])) + f" mode:{data['mode']}" + "*" * 30 + '\n')
            f2.write(data["middle"] + "\n")


            f2.write("*" * 30 + "suffix:" + "*" * 30 + "\n")
            f2.write(data["suffix"] + '\n')


    f2.close()

if __name__ == "__main__":

    data_dir = "D:\\UserData\\Desktop\\LORA-MAT\\5-datablocks_analysis_and_scoring\\5.2-datablock_scoring"
    split_dir = "6-creat_train_datas/split_temp"

    strategy = 0
    result_dir = "6-creat_train_datas/split_result"
    if os.path.exists(result_dir) == False:
        os.mkdir(result_dir)

    test_rate = 0.05

    random.seed(824)

    if not os.path.exists(split_dir):
        os.makedirs(split_dir)
    modes = [0,1,2,3,4,5,6]
    times = [1, 1, 1, 1, 1, 1,0]

    if strategy == 0:
        weights = [1, 0, 1, 1, 1, 1,0]
        fire.Fire(main)
    else:
        all_weights = [
            [1, 0, 0, 0, 0, 0],
            [0, 1, 0, 0, 0, 0],
            [0, 0, 1, 0, 0, 0],
            [0, 0, 0, 1, 0, 0],
            [0, 0, 0, 0, 1, 0],
            [0, 0, 0, 0, 0, 1]
        ]

        for i in range(len(modes)):
            weights = all_weights[i]
            fire.Fire(main)

    split_train_test()

    # modes     提供切分的模式，无需修改
    # weights   每种模式的权重
    # times     选中每种模式，生成的样例数量

    # mode0 ：  简单的按照长度切分，有可能切开某一个单词
    # mode1 ：  按照函数块、循环块切分
    # mode2 ：  按照单行切分
    # mode3 ：  按照括号切分
    # mode4 ：  按照多行切分
    # mode5 ：  没有suffix的切分   
    # mode6 :   没有prefix

