"""Calculator tool for mathematical operations."""

import ast
import operator

from langchain_core.tools import tool

# Safe operators for AST-based evaluation
_OPERATORS = {
    ast.Add: operator.add,
    ast.Sub: operator.sub,
    ast.Mult: operator.mul,
    ast.Div: operator.truediv,
    ast.Pow: operator.pow,
    ast.USub: operator.neg,
    ast.Mod: operator.mod,
}


def _safe_eval(node: ast.AST) -> float:
    """Recursively evaluate an AST node with only arithmetic operators."""
    if isinstance(node, ast.Expression):
        return _safe_eval(node.body)
    elif isinstance(node, ast.Constant) and isinstance(node.value, (int, float)):
        return float(node.value)
    elif isinstance(node, ast.BinOp):
        left = _safe_eval(node.left)
        right = _safe_eval(node.right)
        op_type = type(node.op)
        if op_type not in _OPERATORS:
            raise ValueError(f"Unsupported operator: {op_type.__name__}")
        return _OPERATORS[op_type](left, right)
    elif isinstance(node, ast.UnaryOp) and isinstance(node.op, ast.USub):
        return -_safe_eval(node.operand)
    else:
        raise ValueError(f"Unsupported expression: {ast.dump(node)}")


@tool
def calculator_tool(expression: str) -> str:
    """Evaluate a mathematical expression safely using AST parsing.

    Supports: +, -, *, /, **, % with integers and floats.

    Args:
        expression: A mathematical expression to evaluate, e.g. "2 + 2" or "3 ** 4".

    Returns:
        The result of the expression as a string.
    """
    try:
        tree = ast.parse(expression, mode="eval")
        result = _safe_eval(tree)
        return str(result)
    except Exception as e:
        return f"Error evaluating '{expression}': {e}"
