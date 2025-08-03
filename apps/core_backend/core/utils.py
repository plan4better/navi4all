import re

def to_camel_case(string: str):
    """Utility function to convert a snake_case string to camelCase"""

    parts = string.split('_')
    return parts[0] + ''.join(word.capitalize() for word in parts[1:])

def to_snake_case(string: str):
    """Utility function to convert a camelCase string to snake_case"""

    return re.sub(r'(?<!^)(?=[A-Z])', '_', string).lower()
