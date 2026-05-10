import json
import random

from tqdm import tqdm
from transformers import AutoTokenizer

random.seed(824)

tokenizer = AutoTokenizer.from_pretrained("/data/ftc/codegeex3-6b-infilling-1218-v1",trust_remote_code=True)
with open("/data/ftc/split_data/split/split_result/test_java.json",encoding="utf-8") as f1:
    all_data1 = f1.readlines()

with open("/data/ftc/split_data/split/split_result/test_vue.json",encoding="utf-8") as f2:
    all_data2 = f2.readlines()

all_data = all_data1 + all_data2
random.shuffle(all_data)

new_data = []
for data in tqdm(all_data[:]):
    # if len(data)<200:
    #     continue
    data = json.loads(data)
    prefix = data["prefix"]
    middle = data["middle"]
    suffix = data["suffix"]

    # t1 = tokenizer.encode(prefix,add_special_tokens=False)
    # t2 = tokenizer.encode(middle,add_special_tokens=False)
    # t3 = tokenizer.encode(suffix,add_special_tokens=False)

    t1,t2,t3 = tokenizer.batch_encode_plus([prefix,middle,suffix],add_special_tokens=False)["input_ids"]


    l1,l2,l3 = len(t1) ,len(t2) , len(t3)

    i = 0
    while len(t1) + len(t2) + len(t3) > 1250:  # 2048+512
        if i >= 3 :
            i = -999
            break
        if len(t3) >= len(t1) :
            t3 = t3[ : len(t3)//2]
        else:
            t1 = t1[len(t1)//2:]

        i += 1
    if i == -999:
        print("hah")
        continue
    if len(t1) != l1:
        data["prefix"] = tokenizer.decode(t1)
    if len(t3) != l3:
        data["suffix"] = tokenizer.decode(t3)


    # len_data = len(tokenizer.encode(data,add_special_tokens=False))

    # if len_data > 2500:  # 2048+512
    #     # print(len_data)
    #     continue
    new_data.append(json.dumps(data,ensure_ascii=False))

test_rate = 0.12

test_data = new_data[:int(len(new_data)*test_rate)]
train_data = new_data[int(len(new_data)*test_rate):]

with open("/data/ftc/split_data/split/split_result/train.json","w",encoding="utf-8") as f1:
    f1.write("\n".join(train_data))
with open("/data/ftc/split_data/split/split_result/test.json", "w", encoding="utf-8") as f2:
    f2.write("\n".join(test_data))

print(f"总长度：{len(all_data)}")
print(f"训练集长度：{len(train_data)}")
print(f"测试集长度：{len(test_data)}")