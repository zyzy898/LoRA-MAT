from transformers import AutoModelForCausalLM, AutoTokenizer
from peft import PeftModel
import torch
import json
import re
import random
import statistics
from difflib import SequenceMatcher

base_model_path = r"/hy-tmp/my-project/train_model/Qwen3.5-2B-base"
lora_path       = r"/hy-tmp/my-project/saves_model/Qwen3.5-2B-base-test/lora/sft"
test_data_path  = r"/hy-tmp/my-project/train_data/code_test.json"

BATCH_SIZE = 50
# ─────────────────────────────────────────────────────────────
# 过滤词表：MATLAB 关键字 + 极高频内置函数/变量名
# ─────────────────────────────────────────────────────────────

# MATLAB 语言关键字（iskeyword() 返回的保留字）
_MATLAB_KEYWORDS = {
    "break", "case", "catch", "classdef", "continue", "else",
    "elseif", "end", "for", "function", "global", "if", "otherwise",
    "parfor", "persistent", "return", "spmd", "switch", "try", "while",
}

# MATLAB 极高频内置函数 / 常量 / 通用变量名
_MATLAB_BUILTINS = {
    # 常量
    "true", "false", "pi", "inf", "Inf", "nan", "NaN", "eps",
    # 极高频函数
    "disp", "fprintf", "sprintf", "error", "warning",
    "size", "length", "numel", "zeros", "ones", "eye", "rand", "randn",
    "sum", "max", "min", "mean", "abs", "sqrt", "floor", "ceil", "round",
    "mod", "rem", "sign", "exp", "log", "log2", "log10",
    "find", "sort", "unique", "ismember", "any", "all",
    "struct", "cell", "fieldnames", "isfield", "rmfield",
    "strcmp", "strcmpi", "strcat", "strsplit", "num2str", "str2num", "str2double",
    "isempty", "isnumeric", "ischar", "islogical", "iscell", "isstruct",
    "nargin", "nargout", "varargin", "varargout",
    "figure", "plot", "hold", "grid", "xlabel", "ylabel", "title", "legend",
    "subplot", "axis", "xlim", "ylim", "clf", "close",
    "input", "load", "save", "fopen", "fclose", "fread", "fwrite", "fscanf",
    # 极高频短变量名（1-2字符）已在 _extract_keywords 中按长度过滤
}

IGNORE_WORDS = _MATLAB_KEYWORDS | _MATLAB_BUILTINS


def clean_output(text: str) -> str:
    """去除模型输出中可能混入的 Markdown 代码块标记和解释性句子。"""
    text = re.sub(r"```[\w]*\n?", "", text)
    text = re.sub(r"```", "", text)
    lines = text.strip().split("\n")
    clean_lines = []
    for line in lines:
        # 跳过以大写字母开头、以句号/冒号结尾的自然语言解释行
        if re.match(r'^[A-Z][a-z].*([\.\:])\s*$', line.strip()):
            continue
        clean_lines.append(line)
    return "\n".join(clean_lines).strip()


def _normalize(text: str) -> str:
    """空白归一化：多个空白 → 单个空格，首尾去除。"""
    return re.sub(r'\s+', ' ', text).strip()


def _extract_keywords(text_norm: str) -> set:
    """
    提取有意义的标识符关键词，过滤掉：
      1. MATLAB 语言关键字（if / for / while / end …）
      2. MATLAB 极高频内置函数 & 常量（size / zeros / true …）
      3. 长度 ≤ 2 的短名（i / n / ii …，MATLAB 中极常见但无区分度）
    """
    all_words = set(re.findall(r'[a-zA-Z_]\w*', text_norm))
    return all_words - IGNORE_WORDS - {w for w in all_words if len(w) <= 2}


def _strip_lines(text: str) -> set:
    """将文本按行分割，strip 每行，返回非空行集合。"""
    return {l.strip() for l in text.split('\n') if l.strip()}


def score(pred: str, expected: str):
    """
    综合评分，满分 100，由四个维度合成：
      - 字符相似度   (40%)：SequenceMatcher 逐字符比较
      - 关键词覆盖率 (35%)：期望中的「有意义关键词」有多少出现在预测中
      - 行命中率     (25%)：期望的每行（去除缩进后）有多少出现在预测中

    修复记录：
      [fix-1] 关键词过滤：排除 MATLAB 关键字 & 高频内置函数，避免虚高
      [fix-2] 行命中率：双边 strip 后用集合比较，消除缩进敏感问题
      [fix-3] 精确匹配：单独统计，不并入加权分（用于汇总展示）
    """
    pred_norm = _normalize(pred)
    exp_norm  = _normalize(expected)

    # ── 1. 字符相似度 ─────────────────────────────────────────
    char_sim = SequenceMatcher(None, pred_norm, exp_norm).ratio()

    # ── 2. 关键词覆盖率 [fix-1] ───────────────────────────────
    keywords = _extract_keywords(exp_norm)
    if keywords:
        matched_kw   = sum(1 for kw in keywords if kw in pred_norm)
        keyword_score = matched_kw / len(keywords)
    else:
        keyword_score = char_sim   # 无有效关键词时用字符相似度兜底

    # ── 3. 行命中率 [fix-2] ───────────────────────────────────
    exp_lines  = [l.strip() for l in expected.split('\n') if l.strip()]
    pred_lines = _strip_lines(pred)                # 双边 strip 后的集合
    if exp_lines:
        hit_lines  = sum(1 for line in exp_lines if line in pred_lines)
        line_score = hit_lines / len(exp_lines)
    else:
        line_score = char_sim


    # ── 综合加权 ──────────────────────────────────────────────
    total = (
        char_sim      * 45 +
        keyword_score * 35 +
        line_score    * 20 
    )

    # ── 精确匹配 [fix-3] ──────────────────────────────────────
    exact = pred_norm == exp_norm

    return (
        round(total,         1),
        round(char_sim     * 100, 1),
        round(keyword_score* 100, 1),
        round(line_score   * 100, 1),
        exact,
    )


def score_label(total: float) -> str:
    if total >= 80: return "🟢 优秀"
    if total >= 60: return "🟡 良好"
    if total >= 40: return "🟠 较差"
    return "🔴 很差"


# ─────────────────────────────────────────────────────────────
# 加载模型
# ─────────────────────────────────────────────────────────────
print("加载基础模型...")
tokenizer = AutoTokenizer.from_pretrained(base_model_path, trust_remote_code=True)
base_model = AutoModelForCausalLM.from_pretrained(
    base_model_path,
    trust_remote_code=True,
    torch_dtype=torch.float16,
    device_map="cuda:0",
)

print("加载 LoRA adapter...")
model = PeftModel.from_pretrained(base_model, lora_path)
model.eval()

# ─────────────────────────────────────────────────────────────
# 加载测试数据
# ─────────────────────────────────────────────────────────────
print("加载测试数据...")
with open(test_data_path, "r", encoding="utf-8") as f:
    test_data = json.load(f)

batch = random.sample(test_data, min(BATCH_SIZE, len(test_data)))
print(f"共 {len(test_data)} 条数据，随机抽取 {len(batch)} 条")
print("-" * 60)

# ─────────────────────────────────────────────────────────────
# 推理 & 评分
# ─────────────────────────────────────────────────────────────
# ─────────────────────────────────────────────────────────────
# 推理 & 评分 (修改为纯文本推理版本)
# ─────────────────────────────────────────────────────────────
scores        = []
exact_matches = 0

# 在循环外获取特殊的 Token ID (针对 Qwen 系列)
# 这样能确保模型识别到这是一个补全任务
fim_mid_id = tokenizer.convert_tokens_to_ids('<|fim_middle|>')
eos_id = tokenizer.eos_token_id

for i, item in enumerate(batch):
    # 直接使用原始的 instruction，里面已经包含了 <|fim_prefix|> 等标记
    prompt = item["instruction"]
    expected_output = item["output"].strip()

    # [关键修改]：不再使用 apply_chat_template，直接编码 Raw Text
    # add_special_tokens=False 是为了防止在 <|fim_prefix|> 前面又加个 <s> 之类的标记
    inputs = tokenizer(prompt, return_tensors="pt", add_special_tokens=False).to(model.device)

    with torch.no_grad():
        outputs = model.generate(
            **inputs,
            max_new_tokens=128,      # 适当缩短，代码填空通常不需要太长
            do_sample=False,         # 保持确定性
            pad_token_id=eos_id,
            eos_token_id=eos_id,
            # [进阶]：设置停止字符串。当模型写完一行或开始复读 Suffix 时自动停止
            stop_strings=["\n\n", "<|endoftext|>", "<|file_separator|>"], 
            tokenizer=tokenizer
        )

    # 提取生成内容
    input_len      = inputs["input_ids"].shape[1]
    generated_ids  = outputs[0][input_len:]
    
    # 解码并清洗
    raw_output = tokenizer.decode(generated_ids, skip_special_tokens=True).strip()
    assistant_part = clean_output(raw_output)

    # 评分逻辑保持
    total, char_sim, kw_cov, line_hit, exact = score(
        assistant_part, expected_output
    )
    scores.append(total)

    if exact:
        exact_matches += 1

    print(f"\n=== 测试 {i+1}/{len(batch)} ===")
    print(f"文件     : {item.get('file_name', 'unknown')}")
    print(f"期望     : {expected_output[:80]}")
    print(f"预测     : {assistant_part[:80]}")
    print(f"综合评分 : {total}/100  {score_label(total)}{'  ✅ 精确匹配' if exact else ''}")
    print(f"  ├─ 字符相似度 : {char_sim:>6}/100  (权重45%)")
    print(f"  ├─ 关键词覆盖 : {kw_cov:>6}/100  (权重35%，已过滤通用词)")
    print(f"  └─ 行命中率   : {line_hit:>6}/100  (权重20%，缩进不敏感)")

# ─────────────────────────────────────────────────────────────
# 汇总统计
# ─────────────────────────────────────────────────────────────
avg    = sum(scores) / len(scores)
median = statistics.median(scores)

print("\n" + "=" * 60)
print(f"📊 本次评估汇总  ({len(batch)} 条样本)")
print("=" * 60)
print(f"平均分   : {avg:.1f}/100  {score_label(avg)}")
print(f"中位数   : {median:.1f}/100")
print(f"最高分   : {max(scores)}")
print(f"最低分   : {min(scores)}")
print(f"精确匹配 : {exact_matches}/{len(batch)}  ({exact_matches/len(batch)*100:.1f}%)")
print(f"\n分布:")
print(f"  🟢 优秀 (≥80) : {sum(1 for s in scores if s >= 80):>3} 条")
print(f"  🟡 良好 (60-80): {sum(1 for s in scores if 60 <= s < 80):>3} 条")
print(f"  🟠 较差 (40-60): {sum(1 for s in scores if 40 <= s < 60):>3} 条")
print(f"  🔴 很差 (<40)  : {sum(1 for s in scores if s < 40):>3} 条")