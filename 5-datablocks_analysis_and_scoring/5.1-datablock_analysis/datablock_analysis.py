import json
import re
from pathlib import Path

import pandas as pd
from tqdm import tqdm


def calculate_code_diversity(content: str, pattern: re.Pattern) -> float:
    """计算代码块的词汇多样性得分（去重率）"""
    tokens = pattern.findall(content)
    if not tokens:
        return 0.0
    return round(len(set(tokens)) / len(tokens) * 100, 2)


def main() -> None:
    pattern = re.compile(r'[A-Za-z]+|\d|[^A-Za-z0-9\s]')
    script_dir = Path(__file__).parent

    files_info = json.loads((script_dir / '../../4-split_datas/split_result.json').resolve().read_text(encoding="utf-8"))

    for file in tqdm(files_info, desc="计算多样性得分"):
        file["score"] = calculate_code_diversity(file["content"], pattern)

    pd.DataFrame(files_info).to_csv(script_dir / './chunk_scores.csv', index=False)


if __name__ == "__main__":
    main()

