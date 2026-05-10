from tree_sitter_languages import get_parser
from transformers import AutoModel, AutoTokenizer
from utils import DICT_CODEBODY, DICT_NEXT, DICT_CODEHINT


# 解析代码获取parsetree
def getast_tree(language, text):
    parser = get_parser(language)
    tree = parser.parse(bytes(text, "utf8"))
    return tree


def search(node, language):
    nodes = set()
    node_childs = node.children
    if node_childs == []:
        return set()
    for i in node_childs:
        nodes.add(i.type)
        nodes = nodes | search(i, language)
    return nodes


def test_text(language, text):
    tree = getast_tree(language, text)
    nodes = set()
    nodes = search(tree.root_node, language)
    for i in nodes:
        if "comment" in i:
            return True
    return False


# 对根节点的第一层节点进行搜索，将class、function节点加入
def dfs(node, language):
    node_childs = node.children
    if node_childs == []:
        return
    method_list = []
    mod = ""
    for i in range(len(node_childs) - 1, -1, -1):
        if node_childs[i].type in DICT_CODEBODY[language]:
            method_list.append(node_childs[i])
            mod = "body"
        elif node_childs[i].type in DICT_NEXT[language]:
            if type(dfs(node_childs[i], language)) == list:
                for j in dfs(node_childs[i], language):
                    method_list.append(j)
        elif node_childs[i].type in DICT_CODEHINT[language]:
            if mod == "body":
                method_list.append(node_childs[i])
        else:
            mod = "trash"
    return method_list


def split_code(language, code):
    "返回所有函数和函数节点信息"
    language = language.lower()
    tree = getast_tree(language, code)
    method_nodes = []
    method_nodes = dfs(tree.root_node, language)
    methods_list = []
    method = ""
    for n in range(len(method_nodes) - 1, -1, -1):
        if method_nodes[n].type in DICT_CODEHINT[language]:
            method += method_nodes[n].text.decode("utf-8")  # bytes转str
            method += "\n"
        else:
            method += method_nodes[n].text.decode("utf-8")
            if test_text(language, method):
                methods_list.append(method)
            method = ""
            
    return methods_list


# tokenizer = AutoTokenizer.from_pretrained("/mnt/vepfs/qinkai/checkpoints/huggingface/chatglm-6b-v2-infilling", trust_remote_code=True)

# special_tokens_dict = {
#     "additional_special_tokens": ['<code_prefix>', '<code_middle>', '<code_suffix>']
# }

# num_added_toks = tokenizer.add_special_tokens(special_tokens_dict, replace_additional_special_tokens=False)
# print('We have added', num_added_toks, 'tokens')

# 检查注释是否无意义
def CheckSymbol(line, threshold=10):
    list1 = tokenizer.encode(line, add_special_tokens=False)
    unique_chars = set(list1)
    count = len(unique_chars)
    ratio = len(line) / count
    
    if ratio > threshold:
        return False
    else:
        return True


def cutoff(node, language, threshold):
    node_childs = node.children
    if node_childs == []: return
    method_list = []
    count = 0
    for i in range(len(node_childs)):
        if node_childs[i].type in DICT_CODEHINT[language]:
            count += 1
            if count <= threshold:
                method_list.append(node_childs[i])
        else:
                method_list.append(node_childs[i])
                
    return method_list
    
    
def Pass(node, language, minbash):
    node_childs = node.children
    count = 0
    method_list = []
    for i in range(len(node_childs)):
        if node_childs[i].type in DICT_CODEHINT[language]:
            if CheckSymbol(node_childs[i].text.decode('utf-8')):
                method_list.append(node_childs[i])
                count += 1
            if count > minbash:
                    return []
            else:
                method_list.append(node_childs[i])
            
    return method_list


def cutoff(node, language, threshold=1):
    node_childs = node.children
    if node_childs == []: return
    method_list = []
    count = 0
    for i in range(len(node_childs)):
        if node_childs[i].type in DICT_CODEHINT[language]:
            if CheckSymbol(node_childs[i].text.decode('utf-8')):
                count += 1
                if count <= threshold and count >= 1:
                    method_list.append(node_childs[i])
        else:
            method_list.append(node_childs[i])
                
    return method_list


# 检查前边是否有注释，如果没有的话将内部注释提取出来
def CheckComment(node, language, code):
    node_childs = node.children
    count = 0
    for i in range(len(node_childs)):
        if node_childs[i].type in DICT_CODEHINT[language]:
            count += 1
    if count == 0:
        Node=node_childs[-1].children
        comment = ""
        for i in range(len(Node)):
            if Node[i].type in DICT_CODEHINT[language]:
                comment += Node[i].text.decode('utf-8')
        method = node_childs[-1].text.decode('utf-8')
        return comment + method
    else:
        return code

# 检查注释长度                    
def CheckLength(language, code, mod, threshold=1):
    "返回所有函数和函数节点信息"
    tree = getast_tree(language, code)
    method_nodes=[]
    if mod == 'cutoff':
        method_nodes = cutoff(tree.root_node, language, threshold)
        method = ""
        for n in range(len(method_nodes)):
            method += method_nodes[n].text.decode('utf-8') # bytes转str
            method += '\n'
        return method
    elif mod == 'pass':
        method_nodes = Pass(tree.root_node, language, threshold)
        method = ""
        for n in range(len(method_nodes)):
            method += method_nodes[n].text.decode('utf-8') # bytes转str
            method += '\n'
            
        return method
     
     
if __name__ == "__main__":
    test_code = """# write a hello world function\ndef hello_world():\n    print('hello world')\n\n# write a new function\ndef new_fun():\n    print('hello new function')"""
    language = "python"
    methods_list = split_code(language, test_code)
    for i, method in enumerate(methods_list):
        print(i, method)
        
    