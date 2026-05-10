"""
从筛选后的 CSV 中读取原始文件内容，合并后输出新 CSV
"""

from __future__ import annotations

import logging
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
SCRIPT_DIR      = Path(__file__).parent
FILTERED_CSV    = (SCRIPT_DIR / "../2-data_analysis_and_scoring/2.2-data_scoring/filtered_file.csv").resolve()
DATA_DIR        = (SCRIPT_DIR / "../source_data").resolve()
OUTPUT_CSV      = SCRIPT_DIR / "./filtered_file_with_content.csv"
FILE_ENCODING   = "utf-8"


# ──────────────────────────────────────────────
# 核心逻辑
# ──────────────────────────────────────────────
def read_file_content(filename: str, data_dir: Path) -> str:
    """读取单个文件内容，文件缺失或读取失败时返回占位符"""
    file_path = data_dir / filename

    if not file_path.exists():
        logger.warning("文件不存在：%s", file_path)
        return "[FILE NOT FOUND]"

    try:
        content = file_path.read_text(encoding=FILE_ENCODING)

        # ─────────────────────────────
        # 删除以 % 开头的 MATLAB 注释行
        # ─────────────────────────────
        lines = content.splitlines()

        cleaned_lines = [
            line for line in lines
            if not line.lstrip().startswith("%")
        ]

        content = "\n".join(cleaned_lines).strip()

        return content

    except OSError as e:
        logger.error("读取失败：%s → %s", file_path, e)
        return f"[ERROR: {e}]"


def load_filtered(path: Path) -> pd.DataFrame:
    if not path.exists():
        raise FileNotFoundError(f"筛选文件不存在：{path}")
    df = pd.read_csv(path)
    if "filename" not in df.columns:
        raise ValueError("CSV 缺少 'filename' 列")
    return df


def attach_content(df: pd.DataFrame, data_dir: Path) -> pd.DataFrame:
    """新增 content 列（带进度条）"""
    tqdm.pandas(desc="读取文件内容")
    result = df.copy()
    result["content"] = result["filename"].progress_apply(read_file_content, data_dir=data_dir)
    return result


def save(df: pd.DataFrame, output: Path) -> None:
    output.parent.mkdir(parents=True, exist_ok=True)
    df.to_csv(output, index=False, encoding="utf-8-sig", escapechar="\\")
    logger.info("已保存 %d 行 → %s", len(df), output)


# ──────────────────────────────────────────────
# 统计摘要
# ──────────────────────────────────────────────
def print_summary(df: pd.DataFrame) -> None:
    total       = len(df)
    not_found   = (df["content"] == "[FILE NOT FOUND]").sum()
    error_count = df["content"].str.startswith("[ERROR:").sum()
    ok_count    = total - not_found - error_count

    print(f"\n{'─' * 36}")
    print(f"  总行数      : {total}")
    print(f"  成功读取    : {ok_count}")
    print(f"  文件不存在  : {not_found}")
    print(f"  读取失败    : {error_count}")
    print(f"{'─' * 36}\n")


# ──────────────────────────────────────────────
# 入口
# ──────────────────────────────────────────────
def main() -> None:
    df = load_filtered(FILTERED_CSV)
    logger.info("加载 %d 条记录，数据目录：%s", len(df), DATA_DIR)

    df = attach_content(df, DATA_DIR)
    print_summary(df)
    save(df, OUTPUT_CSV)


if __name__ == "__main__":
    main()