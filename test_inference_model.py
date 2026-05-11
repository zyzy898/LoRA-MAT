"""
MATLAB FIM 评估脚本  v2.0
改进列表：
  [1] 按 mode 分层抽样      → 每种 FIM 模式均衡覆盖
  [2] 基准分对比            → 利用数据自带的 score 字段与模型预测对比
  [3] 按 mode 分组统计      → 精准定位哪类填充位置最弱
  [4] 输出补全 chunk_id /
      file_index            → 方便溯源到原始数据
  [5] 流式 CSV + JSON +
      纯文本摘要            → 中途崩溃不丢数据
"""

from transformers import AutoModelForCausalLM, AutoTokenizer
from peft import PeftModel
import torch
import json
import re
import random
import statistics
import csv
import os
from collections import defaultdict
from datetime import datetime
from difflib import SequenceMatcher

# ─────────────────────────────────────────────────────────────
# 路径配置
# ─────────────────────────────────────────────────────────────
base_model_path = r"/hy-tmp/my-project/train_model/Qwen3.5-4B-Base"
lora_path       = r"./saves_model/Qwen3.5-4B-base/lora/sft"
test_data_path  = r"./train_data/code_test.json"

# 每种 mode 最多抽取的样本数（总量 = mode数 × PER_MODE_LIMIT）
PER_MODE_LIMIT = 40

# ─────────────────────────────────────────────────────────────
# 输出目录
# ─────────────────────────────────────────────────────────────
RUN_ID       = datetime.now().strftime("%Y%m%d_%H%M%S")
OUTPUT_DIR   = f"./eval_results/{RUN_ID}"
os.makedirs(OUTPUT_DIR, exist_ok=True)
CSV_PATH     = os.path.join(OUTPUT_DIR, "detail_results.csv")
JSON_PATH    = os.path.join(OUTPUT_DIR, "detail_results.json")
SUMMARY_PATH = os.path.join(OUTPUT_DIR, "summary_report.txt")

print(f"📁 结果将保存至: {OUTPUT_DIR}")

# ─────────────────────────────────────────────────────────────
# 过滤词表
# ─────────────────────────────────────────────────────────────
_MATLAB_KEYWORDS = {
    "break", "case", "catch", "classdef", "continue", "else",
    "elseif", "end", "for", "function", "global", "if", "otherwise",
    "parfor", "persistent", "return", "spmd", "switch", "try", "while",
}
_MATLAB_BUILTINS = {
    "true", "false", "pi", "inf", "Inf", "nan", "NaN", "eps",
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
}
IGNORE_WORDS = _MATLAB_KEYWORDS | _MATLAB_BUILTINS


# ─────────────────────────────────────────────────────────────
# 工具函数
# ─────────────────────────────────────────────────────────────
def clean_output(text: str) -> str:
    text = re.sub(r"```[\w]*\n?", "", text)
    text = re.sub(r"```", "", text)
    lines = text.strip().split("\n")
    clean_lines = [
        line for line in lines
        if not re.match(r'^[A-Z][a-z].*([\.\:])\s*$', line.strip())
    ]
    return "\n".join(clean_lines).strip()


def _normalize(text: str) -> str:
    return re.sub(r'\s+', ' ', text).strip()


def _extract_keywords(text_norm: str) -> set:
    all_words = set(re.findall(r'[a-zA-Z_]\w*', text_norm))
    return all_words - IGNORE_WORDS - {w for w in all_words if len(w) <= 2}


def _strip_lines(text: str) -> set:
    return {l.strip() for l in text.split('\n') if l.strip()}


def score(pred: str, expected: str):
    pred_norm = _normalize(pred)
    exp_norm  = _normalize(expected)

    char_sim = SequenceMatcher(None, pred_norm, exp_norm).ratio()

    keywords = _extract_keywords(exp_norm)
    keyword_score = (
        sum(1 for kw in keywords if kw in pred_norm) / len(keywords)
        if keywords else char_sim
    )

    exp_lines  = [l.strip() for l in expected.split('\n') if l.strip()]
    pred_lines = _strip_lines(pred)
    line_score = (
        sum(1 for line in exp_lines if line in pred_lines) / len(exp_lines)
        if exp_lines else char_sim
    )

    total = char_sim * 45 + keyword_score * 35 + line_score * 20
    exact = pred_norm == exp_norm

    return (
        round(total,          1),
        round(char_sim      * 100, 1),
        round(keyword_score * 100, 1),
        round(line_score    * 100, 1),
        exact,
    )


def score_label(total: float) -> str:
    if total >= 80: return "优秀"
    if total >= 60: return "良好"
    if total >= 40: return "较差"
    return "很差"


def grade_emoji(label: str) -> str:
    return {"优秀": "🟢", "良好": "🟡", "较差": "🟠", "很差": "🔴"}.get(label, "")


# ─────────────────────────────────────────────────────────────
# [1] 分层抽样：每种 mode 各取最多 PER_MODE_LIMIT 条
# ─────────────────────────────────────────────────────────────
print("加载测试数据...")
with open(test_data_path, "r", encoding="utf-8") as f:
    test_data = json.load(f)

by_mode = defaultdict(list)
for item in test_data:
    by_mode[item["mode"]].append(item)

batch = []
for mode_val, items in sorted(by_mode.items()):
    sampled = random.sample(items, min(PER_MODE_LIMIT, len(items)))
    batch.extend(sampled)
    print(f"  mode={mode_val}: 总 {len(items)} 条，抽取 {len(sampled)} 条")

random.shuffle(batch)
print(f"\n合计抽取: {len(batch)} 条 / {len(test_data)} 条")
print("-" * 60)

# ─────────────────────────────────────────────────────────────
# 加载模型
# ─────────────────────────────────────────────────────────────
print("\n加载基础模型...")
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
# CSV 写入器（流式）
# ─────────────────────────────────────────────────────────────
CSV_COLUMNS = [
    "index", "chunk_id", "file_index", "file_name", "mode",
    "expected_output", "predicted_output",
    "total_score", "char_similarity", "keyword_coverage", "line_hit_rate",
    "grade", "exact_match",
    "baseline_score", "score_delta",
]

csv_file   = open(CSV_PATH, "w", newline="", encoding="utf-8-sig")
csv_writer = csv.DictWriter(csv_file, fieldnames=CSV_COLUMNS)
csv_writer.writeheader()

# ─────────────────────────────────────────────────────────────
# 推理 & 评分
# ─────────────────────────────────────────────────────────────
all_scores    = []
exact_matches = 0
json_records  = []
mode_stats    = defaultdict(list)

eos_id = tokenizer.eos_token_id

for i, item in enumerate(batch):
    prompt          = item["instruction"]
    expected_output = item["output"].strip()
    file_name       = item.get("file_name", "unknown")
    mode_val        = item.get("mode", -1)
    chunk_id        = item.get("chunk_id", "")
    file_index      = item.get("file_index", "")
    baseline_score  = item.get("score", None)   # [2] 数据自带基准分

    inputs = tokenizer(prompt, return_tensors="pt", add_special_tokens=False).to(model.device)

    with torch.no_grad():
        outputs = model.generate(
            **inputs,
            max_new_tokens=128,
            do_sample=False,
            pad_token_id=eos_id,
            eos_token_id=eos_id,
            stop_strings=["\n\n", "<|endoftext|>", "<|file_separator|>"],
            tokenizer=tokenizer,
        )

    input_len      = inputs["input_ids"].shape[1]
    generated_ids  = outputs[0][input_len:]
    raw_output     = tokenizer.decode(generated_ids, skip_special_tokens=True).strip()
    assistant_part = clean_output(raw_output)

    total, char_sim, kw_cov, line_hit, exact = score(assistant_part, expected_output)
    grade = score_label(total)

    score_delta = round(total - baseline_score, 1) if baseline_score is not None else None

    all_scores.append(total)
    mode_stats[mode_val].append(total)
    if exact:
        exact_matches += 1

    # ── 流式写入 CSV ──────────────────────────────────────────
    csv_writer.writerow({
        "index":            i + 1,
        "chunk_id":         chunk_id,
        "file_index":       file_index,
        "file_name":        file_name,
        "mode":             mode_val,
        "expected_output":  expected_output,
        "predicted_output": assistant_part,
        "total_score":      total,
        "char_similarity":  char_sim,
        "keyword_coverage": kw_cov,
        "line_hit_rate":    line_hit,
        "grade":            grade,
        "exact_match":      "是" if exact else "否",
        "baseline_score":   baseline_score if baseline_score is not None else "",
        "score_delta":      score_delta if score_delta is not None else "",
    })
    csv_file.flush()

    # ── 收集 JSON ─────────────────────────────────────────────
    json_records.append({
        "index":             i + 1,
        "chunk_id":          chunk_id,
        "file_index":        file_index,
        "file_name":         file_name,
        "mode":              mode_val,
        "expected_output":   expected_output,
        "predicted_output":  assistant_part,
        "scores": {
            "total":            total,
            "char_similarity":  char_sim,
            "keyword_coverage": kw_cov,
            "line_hit_rate":    line_hit,
            "grade":            grade,
            "exact_match":      exact,
        },
        "baseline_score": baseline_score,
        "score_delta":    score_delta,
    })

    # ── 控制台 ────────────────────────────────────────────────
    delta_str = (f"  Δ={score_delta:+.1f}" if score_delta is not None else "")
    print(f"\n=== [{i+1}/{len(batch)}]  mode={mode_val}  {file_name} ===")
    print(f"期望     : {expected_output[:80]}")
    print(f"预测     : {assistant_part[:80]}")
    print(f"综合评分 : {total}/100  {grade_emoji(grade)} {grade}{delta_str}{'  ✅ 精确匹配' if exact else ''}")
    print(f"  ├─ 字符相似度 : {char_sim:>6}/100  (权重45%)")
    print(f"  ├─ 关键词覆盖 : {kw_cov:>6}/100  (权重35%)")
    print(f"  └─ 行命中率   : {line_hit:>6}/100  (权重20%)")

# ─────────────────────────────────────────────────────────────
# 写入 JSON
# ─────────────────────────────────────────────────────────────
csv_file.close()
with open(JSON_PATH, "w", encoding="utf-8") as f:
    json.dump(json_records, f, ensure_ascii=False, indent=2)

# ─────────────────────────────────────────────────────────────
# 汇总统计
# ─────────────────────────────────────────────────────────────
avg    = sum(all_scores) / len(all_scores)
median = statistics.median(all_scores)
stdev  = statistics.stdev(all_scores) if len(all_scores) > 1 else 0.0

# [2] 基准分对比
items_with_baseline = [r for r in json_records if r["baseline_score"] is not None]
if items_with_baseline:
    avg_baseline = sum(r["baseline_score"] for r in items_with_baseline) / len(items_with_baseline)
    avg_delta    = sum(r["score_delta"]    for r in items_with_baseline) / len(items_with_baseline)
else:
    avg_baseline = avg_delta = None

# [3] 按 mode 统计
mode_summary_lines = []
for mode_val in sorted(mode_stats.keys()):
    ms = mode_stats[mode_val]
    m_avg = sum(ms) / len(ms)
    mode_summary_lines.append(
        f"   mode={mode_val} : 样本={len(ms):>3}  "
        f"均分={m_avg:>5.1f}  中位={statistics.median(ms):>5.1f}  "
        f"[{score_label(m_avg)}]"
    )

cnt = lambda lo, hi: sum(1 for s in all_scores if lo <= s < hi)
cnt_excellent = sum(1 for s in all_scores if s >= 80)

summary_lines = [
    "=" * 64,
    f"📊 评估汇总报告  —  运行 ID: {RUN_ID}",
    f"   模型 : {lora_path}",
    f"   数据 : {test_data_path}",
    f"   样本 : {len(batch)} 条（分层抽样，每种 mode ≤{PER_MODE_LIMIT} 条）",
    "=" * 64,
    "",
    "── 整体得分 ─────────────────────────────────────────────",
    f"   平均分   : {avg:.1f}/100   [{score_label(avg)}]",
    f"   中位数   : {median:.1f}/100",
    f"   标准差   : {stdev:.1f}",
    f"   最高分   : {max(all_scores)}",
    f"   最低分   : {min(all_scores)}",
    f"   精确匹配 : {exact_matches}/{len(batch)}  ({exact_matches/len(batch)*100:.1f}%)",
]

if avg_baseline is not None:
    summary_lines += [
        "",
        "── 基准分对比（数据自带 score 字段） ─────────────────────",
        f"   数据基准均分 : {avg_baseline:.1f}",
        f"   模型预测均分 : {avg:.1f}",
        f"   平均提升 Δ  : {avg_delta:+.1f}",
    ]

summary_lines += [
    "",
    "── 按 mode 分组 ─────────────────────────────────────────",
    *mode_summary_lines,
    "",
    "── 分级分布 ─────────────────────────────────────────────",
    f"   🟢 优秀 (≥80)   : {cnt_excellent:>4} 条  ({cnt_excellent/len(batch)*100:.1f}%)",
    f"   🟡 良好 (60-80) : {cnt(60,80):>4} 条  ({cnt(60,80)/len(batch)*100:.1f}%)",
    f"   🟠 较差 (40-60) : {cnt(40,60):>4} 条  ({cnt(40,60)/len(batch)*100:.1f}%)",
    f"   🔴 很差 (<40)   : {cnt(0,40):>4} 条  ({cnt(0,40)/len(batch)*100:.1f}%)",
    "",
    "── 输出文件 ─────────────────────────────────────────────",
    f"   CSV  : {CSV_PATH}",
    f"   JSON : {JSON_PATH}",
    f"   报告 : {SUMMARY_PATH}",
    "=" * 64,
]

summary_text = "\n".join(summary_lines)
print("\n" + summary_text)

with open(SUMMARY_PATH, "w", encoding="utf-8") as f:
    f.write(summary_text + "\n")

print(f"\n✅ 所有文件已保存至: {OUTPUT_DIR}")