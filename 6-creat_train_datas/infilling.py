import re
import random
import numpy as np
from buding_split import getast_tree
from utils import DICT_CODEBODY, DICT_CODEGEEX2TS

# c,cpp,csharp,go,php,rust
list1 = ["c", "cpp", "csharp", "go", "php", "rust"]
dictof = {
    "template_declaration": "",
    "type_declaration": "",
    " namespace_definition": "declaration_list",
    "function_definition": "compound_statement",
    "expression_statement": "",
    "class_specifier": "field_declaration_list",
    "class_declaration": "declaration_list",
    "interface_declaration": "declaration_list",
    "struct_declaration": "declaration_list",
    "struct_specifier": "field_declaration_list",
    "function_declaration": "block",
    "method_declaration": "block",
    "trait_item": "declaration_list",
    "impl_item": "declaration_list",
    "function_item": "block",
    "struct_item": "field_declaration_list",
    "enum_item": "",
    "type_item": "",
}
list2 = ["java", "python"]
# java,python
dictof1 = {
    "interface_declaration": "interface_body",
    "class_declaration": "class_body",
    "class_definition": "block",
    "function_definition": "block",
}

import re

def find_brackets(code):
    # Regular expressions for matching symbols
    symbols = {
        'paren': (re.compile(r'\(|\)'), []),
        'bracket': (re.compile(r'\[|\]'), []),
        'brace': (re.compile(r'\{|\}'), []),
    }

    matches = []

    for symbol_type, (symbol_re, symbol_matches) in symbols.items():
        for m in symbol_re.finditer(code):
            opening_symbol = {
                'paren': '(',
                'bracket': '[',
                'brace': '{',
            }[symbol_type]

            if m.group() == opening_symbol:
                symbol_matches.append((m.start(), None))
            else:
                for i in range(len(symbol_matches) - 1, -1, -1):
                    if symbol_matches[i][1] is None:
                        symbol_matches[i] = (symbol_matches[i][0], m.end())
                        break

        matches.extend(symbol_matches)

    return matches


def random_non_adjacent_bracket(matches):
    
    non_adjacent_matches = [m for m in matches if None not in m and m[1] - m[0] > 30 and m[1]-m[0]<1500]


    if not non_adjacent_matches:
        return None

    return random.choice(non_adjacent_matches)


def weighted_randint(min_val, max_val):
    weights = np.arange(max_val, min_val - 1, -1)  # higher weight for smaller numbers
    weights = weights / weights.sum()  # normalize weights
    return np.random.choice(np.arange(min_val, max_val + 1), p=weights)


def find_nearest_newline(s, index):
    """
    在字符串s中的index索引之后找到最近的"\n"符号的位置。

    参数:
    s (str): 搜索的字符串。
    index (int): 开始搜索的索引。

    返回:
    回车符的索引（如果找到），否则返回-1。
    """
    # 异常情况，index大于字符串长度时，直接返回-1。
    if index >= len(s):
        return -1

    # 查找给定索引后面的下一个回车符
    newline_index = s.find('\n', index)

    return newline_index - index


def reset_start_end(start,end):
    max_l = 15
    if end - start >= max_l:
        start = random.randint(start,end-max_l+1)
        end = start + max_l - 1

    return start,end

def model_0(code,language,times):
    result = []
    for i in range(times):
        l = len(code) # 字符数

        l_num = code.count("\n") # 分块原代码行数

        prefix_length = random.randint(0, l // 4)
        middle_length = random.randint(int(l/l_num)*1, min(int(l/l_num)*6,l//3))
        offset = find_nearest_newline(code,prefix_length + middle_length)
        middle_length += offset

        # suffix_length = l - prefix_length - middle_length
        prefix = code[:prefix_length]
        middle = code[prefix_length:prefix_length + middle_length]
        suffix = code[prefix_length + middle_length:]
        if prefix.strip() == "":
            # prefix = None
            return result
        if suffix.strip() == "":
            suffix = ""
        result.append((prefix, middle, suffix))
    return result

# 代码填空
def model_1(code, language,times):
    if language not in list1 and language not in list2:
        return []
    tree = getast_tree(language, code)
    node_childs = tree.root_node.children
    isfind = False
    starts,ends = [],[]
    for index in node_childs:
        if index.type in DICT_CODEBODY[language]:
            isfind = True
            j = index.children
            key = index.type
            for i in j:
                if language in list1:
                    flag = i.type != dictof[key]
                elif language in list2:
                    flag = i.type != dictof1[key]
                else:
                    break
                if flag:
                    pass
                else:
                    node_childs = i.children
                    # index = random.randint(1, max(1, len(node_childs) - 2))
                    indexs = random.choices([i for i in range(1,len(node_childs) - 1)],[node_childs[i].end_point[0]- node_childs[i].start_point[0] for i in range(1,len(node_childs) - 1)],k=times*2)
                    # indexs = random.sample([i for i in range(1, len(node_childs) - 1)], min(len(node_childs) - 2,times))

                    for ii in set(indexs):
                        for k in range(len(node_childs)):
                            if ii == k:
                                keynode = node_childs[k]
                                starts.append(keynode.start_point[0])
                                ends.append( keynode.end_point[0])

                                break
        if starts and ends:
            break
    starts = starts[:times]
    ends = ends[:times]
    result = []
    if starts != None and ends != None:
        for start,end in zip(starts,ends):
            start,end = reset_start_end(start,end)

            codelist = code.split("\n")
            above = "\n".join(codelist[:start])
            key = "\n".join(codelist[start : end + 1])
            bottom = "\n".join(codelist[end + 1 :])

            result.append((above, key, bottom))
    return result

def model_2(code,language,times):
    result = []
    for i in range(times):
        left_enter = random.random() < 0.5
        right_enter = random.random() < 0.5
        code_splits = code.split("\n")

        k = 0
        while True:
            ind = np.random.randint(1, len(code_splits) - 1)
            prefix = "\n".join(code_splits[:ind])
            middle = code_splits[ind]

            if len(middle.strip()) > 5 or k >= 5:
                break
            k += 1

        suffix = "\n".join(code_splits[ind + 1:])
        if suffix.strip() == '':
            return []
        if left_enter:
            prefix += "\n"
        else:
            middle = "\n" + middle
        if right_enter:
            middle += "\n"
        else:
            suffix = "\n" + suffix
        result.append((prefix,middle,suffix))
    return result

def model_3(code,language,times):
    result = []
    try:
        for i in range(times):
            brackets = find_brackets(code)
            bracket_pos = random_non_adjacent_bracket(brackets)
            if bracket_pos is None:
                return []
            prefix = code[:bracket_pos[0] + 1]
            middle = code[bracket_pos[0] + 1:bracket_pos[1] - 1]
            suffix = code[bracket_pos[1] - 1:]
            result.append((prefix, middle, suffix))
    except:
        return []
    return result

def model_4(code,language,times):
    result = []
    for i in range(times):
        left_enter = random.random() < 0.5
        right_enter = random.random() < 0.5
        code_splits = code.split("\n")
        # n_lines = weighted_randint(2, len(code_splits) - 1)
        n_lines = weighted_randint(2, 5)
        ind = random.randint(1, len(code_splits) - n_lines)
        prefix = "\n".join(code_splits[:ind])
        middle = "\n".join(code_splits[ind:ind + n_lines])
        suffix = "\n".join(code_splits[ind + n_lines:])
        if suffix.strip() == '':
            return []
        if left_enter:
            prefix += "\n"
        else:
            middle = "\n" + middle
        if right_enter:
            middle += "\n"
        else:
            suffix = "\n" + suffix
        result.append((prefix,middle,suffix))
    return result

def model_5(code,language,times):
    result = []
    for i in range(times):
        l = len(code)
        prefix_length = random.randint(l-100, l - 10)
        prefix = code[:prefix_length]
        middle = code[prefix_length:]
        suffix = ""

        result.append((prefix, middle, suffix))
    return result

def model_6(code,language,times):
    result = []
    for i in range(times):
        l = len(code)
        suffix_length = random.randint(l-100, l - 10)
        suffix = code[-suffix_length:]
        middle = code[:-suffix_length]
        prefix = ""

        result.append((prefix, middle, suffix))
    return result

def InFilling(code, language=None, mode=0,times=1):
    try:
        result = globals()[f"model_{mode}"](code,language,times)
        return result
    except:
        return []
