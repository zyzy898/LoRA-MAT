import sys

SUPPORTED_LANGUAGES = [
    "c",
    "cpp",
    "c_sharp",
    "go",
    "java",
    "php",
    "python",
    "ruby",
    "rust",
    "tsx",
    "fortran",
    "kotlin",
    "cuda",
    "scala",
]

UNDEFINED_LANGUAGES = ["cuda", "fortran"]

# 该字典为不同语言的主体节点
DICT_CODEBODY = {
    "c": [
        "function_definition", 
        "struct_specifier",
    ],
    "cpp": [
        "function_definition",
        "class_specifier",
        "template_declaration",
        "struct_specifier",
    ],
    "c_sharp": [
        "class_declaration", 
        "interface_declaration", 
        "struct_declaration",
    ],
    "go": [
        "type_declaration", 
        "method_declaration", 
        "function_declaration",
    ],
    "java": [
        "class_declaration", 
        "interface_declaration",
    ],
    "php": [
        "class_declaration",
        "expression_statement",
        "interface_declaration",
        "function_definition",
    ],
    "python": [
        "function_definition", 
        "class_definition",
    ],
    "ruby": [
        "class", 
        "method",
    ],
    "rust": [
        "trait_item", 
        "struct_item", 
        "enum_item", 
        "function_item", 
        "type_item",
    ],
    "tsx": [
        "lexical_declaration",
        "export_statement",
        "expression_statement",
        "function_declaration",
        "class_declaration",
        "interface_declaration",
    ],
    "fortran": [
        "module", 
        "subroutine", 
        "function", 
        "submodule",
    ],
    "kotlin": [
        "call_expression",
        "function_declaration",
        "prefix_expression",
        "class_declaration",
        "object_declaration",
    ],
    "cuda": [
        "function_definition",
        "template_declaration",
        "struct_specifier",
        "class_specifier",
        "type_definition",
    ],
    "scala": [
        "class_definition",
        "object_definition",
        "function_definition",
        "trait_definition",
    ],
}

# 该字典为不同语言需要向下进一层的节点
DICT_NEXT = {
    "c": [],
    "cpp": ["namespace_definition", "declaration_list", "namespace_declaration"],
    "c_sharp": ["namespace_definition", "declaration_list", "namespace_declaration"],
    "go": [],
    "java": [],
    "php": [],
    "python": [],
    "ruby": ["module"],
    "rust": ["impl_item", "mod_item", "declaration_list"],
    "tsx": [],
    "fortran": ["program"],
    "kotlin": [],
    "cuda": ["namespace_definition", "declaration_list", "namespace_declaration"],
    "scala": [],
}

# 该字典为不同语言主体的前缀，需要在body的前面作为提示信息
DICT_CODEHINT = {
    "c": ["comment"],
    "cpp": ["comment"],
    "c_sharp": ["comment"],
    "go": ["comment"],
    "java": ["block_comment", "line_comment"],
    "php": ["comment"],
    "python": ["comment", "expression_statement"],
    "ruby": ["comment"],
    "rust": ["line_comment", "block_comment"],
    "tsx": ["comment"],
    "fortran": ["comment"],
    "kotlin": ["comment"],
    "cuda": ["comment"],
    "scala": ["comment"],
}

# 映射字典
DICT_CODEGEEX2TS = {
    "c": "c",
    "c++": "cpp",
    "cpp": "cpp",
    "c#": "c_sharp",
    "csharp": "c_sharp",
    "c-sharp": "c_sharp",
    "css": "css",
    "cuda": "cuda",
    "dart": "dart",
    "lua": "lua",
    "objectivec": "objc",
    "objective-c": "objc",
    "python": "python",
    "perl": "perl",
    "prolog": "prolog",
    "lisp": "elisp",
    "java": "java",
    "scala": "scala",
    "tex": "latex",
    "html": "html",
    "php": "php",
    "js": "javascript",
    "javascript": "javascript",
    "typescript": "tsx",
    "go": "go",
    "rust": "rust",
    "sql": "sqlite",
    "kotlin": "kotlin",
    "ruby": "ruby",
    "pascal": "pascal",
    "r": "r",
    "fortran": "fortran",
    "matlab": "matlab",
    "lean": "lean",
    "markdown": "markdown",
    "shell": "shell",
    "vue": "vue",
}


special_ords = [ord("\n"), ord("\t"), ord("\r")]

# build a table mapping all non-printable characters to None
NOPRINT_TRANS_TABLE = {
    i: None for i in range(0, sys.maxunicode + 1) if not chr(i).isprintable() and i not in special_ords
}

def make_printable(s):
    """Replace non-printable characters in a string."""

    # the translate method on str removes characters
    # that map to None from the string
    return s.translate(NOPRINT_TRANS_TABLE)
