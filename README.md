# LoRA-MAT 🎯

使用 LoRA 技术微调 Qwen3.5-4B-Base 模型，用于 **MATLAB 代码填充任务** (Fill-in-the-Middle, FIM)。

## ✨ 特性

- 🔧 **LoRA 高效微调** - 低秩 adaptation，无需全参数训练
- 📊 **自动化评估** - 分层抽样 + 多维度评分（字符相似度、关键词覆盖、行命中率）
- 📈 **评估报告** - CSV / JSON / 文本摘要三种输出格式
- 🎯 **针对 MATLAB** - 内置 MATLAB 关键词和内置函数词表

## 📁 项目结构

```
LoRA-MAT/
├── my_qwen3_lora.yaml      # 训练配置文件
├── test_inference_model.py # 评估推理脚本
├── train_data/             # 训练数据
│   └── code_train.json
├── eval_results/            # 评估输出结果
└── saves_model/             # 保存的 LoRA 权重
```


## 🔧 数据清洗流程

项目使用多阶段数据处理流水线：

| 阶段 | 脚本 | 说明 |
|------|------|------|
| 1️⃣ 清洗 | `1-clean_data/preclean_data.py` | 读取 .m 文件，删除注释行，过滤短文本 |
| 2️⃣ 分析 | `2-data_analysis_and_scoring/` | 统计分析数据分布与质量评分 |
| 3️⃣ 过滤 | `3-filtrate_files/filtered_file.py` | 按规则过滤低质量文件 |
| 4️⃣ 分割 | `4-split_datas/split_data.py` | 划分训练/验证集 |
| 5️⃣ 分析 | `5-datablocks_analysis_and_scoring/` | 数据块级别分析与评分 |
| 6️⃣ 构建 | `6-creat_train_datas/` | 生成 FIM 格式训练数据 |



## 🚀 快速开始

### 1️⃣ 环境准备

```bash
# 克隆项目后安装依赖
pip install transformers peft torch
```

### 2️⃣ 训练模型

```bash
llamafactory-cli train my_qwen3_lora.yaml
```

### 3️⃣ 评估模型

```bash
python test_inference_model.py
```

## 📊 评估指标

| 指标 | 权重 | 说明 |
|------|------|------|
| 字符相似度 | 45% | 序列匹配比率 |
| 关键词覆盖 | 35% | MATLAB 关键词命中率 |
| 行命中率 | 20% | 输出行匹配率 |

### 评分等级

- 🟢 **优秀**: ≥80 分
- 🟡 **良好**: 60-80 分
- 🟠 **较差**: 40-60 分
- 🔴 **很差**: <40 分

## ⚙️ 训练配置 (my_qwen3_lora.yaml)

```yaml
model_name_or_path: /path/to/Qwen3.5-4B-Base
finetuning_type: lora
lora_rank: 64
lora_alpha: 128
lora_target: all
per_device_train_batch_size: 2
gradient_accumulation_steps: 16
learning_rate: 1.0e-4
num_train_epochs: 3
```
## 训练Loos曲线

<img width="640" height="480" alt="training_loss" src="https://github.com/user-attachments/assets/f6842546-7188-4187-b1bd-a0e09c86677d" />

## 📝 许可证

MIT License
