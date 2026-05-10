"""
将筛选后的代码文件按滑动窗口随机切分为数据块，输出为 JSON
"""

from __future__ import annotations

import json
import logging
import random
from dataclasses import asdict, dataclass
from pathlib import Path

import pandas as pd
from tqdm import tqdm

# ──────────────────────────────────────────────
# 日志
# ──────────────────────────────────────────────
logging.basicConfig(level=logging.INFO, format="%(asctime)s [%(levelname)s] %(message)s", datefmt="%H:%M:%S")
logger = logging.getLogger(__name__)

# ──────────────────────────────────────────────
# 常量
# ──────────────────────────────────────────────
SCRIPT_DIR  = Path(__file__).parent
INPUT_CSV   = (SCRIPT_DIR / "../3-filtrate_files/filtered_file_with_content.csv").resolve()
OUTPUT_JSON = SCRIPT_DIR / "./split_result.json"

RANDOM_SEED = 415
LANGUAGE    = "matlab"

# 切分参数
MIN_LINES = 20
MAX_LINES = 50
WINDOW    = 40


# ──────────────────────────────────────────────
# 数据结构
# ──────────────────────────────────────────────
@dataclass
class Chunk:
    file_index: int
    file_name:  str
    language:   str
    content:    str


# ──────────────────────────────────────────────
# 核心逻辑
# ──────────────────────────────────────────────
def split_lines(
    lines:     list[str],
    min_lines: int,
    max_lines: int,
    window:    int,
) -> list[str]:
    """
    将代码行按随机长度 + 固定步长窗口切分为多个文本块。

    Args:
        lines:     代码行列表
        min_lines: 每块最少行数
        max_lines: 每块最多行数
        window:    两块起始位置之间的固定间距

    Returns:
        切分后的文本块列表
    """
    chunks: list[str] = []
    start = 0

    while start + min_lines < len(lines):
        end = min(start + random.randint(min_lines, max_lines), len(lines))
        chunks.append("\n".join(lines[start:end]))
        start = end + window

    return chunks


def process_row(row: pd.Series, min_lines: int, max_lines: int, window: int) -> list[Chunk]:
    """处理单行 DataFrame 记录，返回切分后的 Chunk 列表"""
    raw_content = row.get("content", "")
    lines = raw_content.splitlines() if isinstance(raw_content, str) else []

    if not lines:
        logger.warning("文件内容为空，跳过：%s", row.get("filename", "unknown"))
        return []

    return [
        Chunk(
            file_index=int(row.get("file_index", 0)),
            file_name=str(row.get("filename", "")),
            language=LANGUAGE,
            content=chunk_text,
        )
        for chunk_text in split_lines(lines, min_lines, max_lines, window)
    ]


# ──────────────────────────────────────────────
# IO
# ──────────────────────────────────────────────
def load_csv(path: Path) -> pd.DataFrame:
    if not path.exists():
        raise FileNotFoundError(f"输入文件不存在：{path}")
    df = pd.read_csv(path)
    for col in ("filename", "content"):
        if col not in df.columns:
            raise ValueError(f"CSV 缺少必要列：{col}")
    return df


def save_json(chunks: list[Chunk], path: Path) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(
        json.dumps([asdict(c) for c in chunks], ensure_ascii=False, indent=4),
        encoding="utf-8",
    )
    logger.info("已保存 %d 个数据块 → %s", len(chunks), path)


# ──────────────────────────────────────────────
# 入口
# ──────────────────────────────────────────────
def main() -> None:
    random.seed(RANDOM_SEED)

    df = load_csv(INPUT_CSV)
    logger.info("加载 %d 条记录，开始切分（min=%d, max=%d, window=%d）", len(df), MIN_LINES, MAX_LINES, WINDOW)

    chunks: list[Chunk] = []
    for _, row in tqdm(df.iterrows(), total=len(df), desc="切分数据"):
        chunks.extend(process_row(row, MIN_LINES, MAX_LINES, WINDOW))

    save_json(chunks, OUTPUT_JSON)

    print(f"\n{'─' * 36}")
    print(f"  输入文件数  : {len(df)}")
    print(f"  输出数据块数: {len(chunks)}")
    print(f"  平均每文件  : {len(chunks) / len(df):.1f} 块")
    print(f"{'─' * 36}")


if __name__ == "__main__":
    main()