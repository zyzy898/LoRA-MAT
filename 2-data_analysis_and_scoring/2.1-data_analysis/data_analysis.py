import argparse
import os
from tqdm import tqdm
import pandas as pd

# 全局关键词集合（由主程序初始化）
keywords: set[str] = set()


def filter_content(content: list[str]) -> list[str]:
    """过滤注释和空行"""
    result = []
    for line in content:
        line = line.strip()
        if line.startswith("%"):
            continue
        result.append(line)
    return result


def filter_display(content: list[str]) -> list[str]:
    """过滤 display 语句"""
    result = []
    for line in content:
        if "$display" in line:
            continue
        result.append(line)
    return result


def read_data(file_path: str) -> tuple[list[str], list[str]]:
    """读取 CSV 数据，返回文件名列表和内容列表"""
    df = pd.read_csv(file_path)
    return df["filename"].tolist(), df["content"].tolist()


def get_length_score(content: list[str]) -> int:
    """文件长度评分"""
    # 10       30
    # 10-30    60
    # 30-100   100
    # 100-300  80
    # 300+     70
    num = len(content)
    if num <= 10:
        return 30
    if num <= 30:
        return 60
    if num <= 100:
        return 100
    if num <= 300:
        return 80
    return 70


def get_uniqueness_score(content: list[str]) -> float:
    """代码重复率得分（去重率越高分数越高）"""
    if not content:
        return 0.0
    return round(len(set(content)) / len(content) * 100, 2)


def get_keyword_score(content: list[str]) -> float:
    """关键词得分"""
    words = set(" ".join(content).split(" "))
    return min(len(words & keywords) * 15, 100)


def get_valid_code_score(content: list[str]) -> float:
    """有效代码得分（过滤 display 语句后的比例）"""
    if not content:
        return 0.0
    filtered = filter_display(content)
    return round(len(filtered) / len(content) * 100, 2)


def get_diversity_score(content: list[str]) -> float:
    """多样性得分（行长度多样性）"""
    if not content:
        return 0.0
    lengths = [len(line) for line in content]

    # 每100行一组计算多样性
    groups = [lengths[i:i + 100] for i in range(0, len(lengths), 100)]
    scores = [len(set(group)) / len(group) for group in groups if group]

    return round(sum(scores) / len(scores) * 100, 2) if scores else 0.0


def get_keywords(path: str) -> set[str]:
    """从文件读取关键词集合"""
    with open(path, encoding="utf-8") as f:
        return set(f.read().split("\n"))


def evaluate_files(files_list: list[str], contents_list: list[str]) -> pd.DataFrame:
    """评估所有文件并返回结果 DataFrame"""
    print(f"前5个文件名：\n{chr(10).join(files_list[:5])}")
    print("*" * 30)

    score_records = []
    score_functions = [
        ("文件长度得分", get_length_score),
        ("代码重复率得分", get_uniqueness_score),
        ("关键词得分", get_keyword_score),
        ("有效代码得分", get_valid_code_score),
        ("多样性得分", get_diversity_score),
    ]
    weights = [1, 1, 1, 1, 1]

    for file_name, content in tqdm(zip(files_list, contents_list), total=len(files_list)):
        lines = content.split("\n")
        filtered_lines = filter_content(lines)

        scores = [func(filtered_lines) for _, func in score_functions]
        weighted_score = sum(s * w for s, w in zip(scores, weights)) / sum(weights)

        print(f"{file_name} ：{weighted_score:.2f}\n每项得分：{scores}\n")

        score_records.append({
            "filename": file_name,
            "总分": round(weighted_score, 3),
            "文件长度得分": scores[0],
            "代码重复率得分": scores[1],
            "关键词得分": scores[2],
            "有效代码得分": scores[3],
            "多样性得分": scores[4],
        })

    df = pd.DataFrame(score_records)
    avg_score = round(df["总分"].mean(), 3)
    print(f"所有文件总分为：{avg_score}（共 {len(files_list)} 个文件）")

    return df


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="数据质量评测")
    parser.add_argument(
        "--dir_path",
        type=str,
        default="1-clean_data\data.csv",
        help="CSV 文件路径"
    )
    parser.add_argument(
        "--keywords_path",
        type=str,
        default="2-data_analysis_and_scoring\\2.1-data_analysis\\keywords.txt",
        help="关键词文件路径"
    )
    parser.add_argument(
        "--output",
        type=str,
        default="2-data_analysis_and_scoring\\2.1-data_analysis\\score.csv",
        help="输出文件路径"
    )
    args = parser.parse_args()

    keywords = get_keywords(args.keywords_path)
    files_list, contents_list = read_data(args.dir_path)

    result_df = evaluate_files(files_list, contents_list)
    result_df.to_csv(args.output, index=False, encoding="utf-8")
    print(f"结果已保存至：{args.output}")