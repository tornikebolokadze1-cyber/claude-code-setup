"""Unit tests for agent tools."""

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent.parent / "src"))

from agent.tools.calculator import calculator_tool
from agent.tools.search import search_tool


class TestCalculatorTool:
    def test_addition(self):
        result = calculator_tool.invoke({"expression": "2 + 3"})
        assert result == "5.0"

    def test_multiplication(self):
        result = calculator_tool.invoke({"expression": "6 * 7"})
        assert result == "42.0"

    def test_power(self):
        result = calculator_tool.invoke({"expression": "2 ** 10"})
        assert result == "1024.0"

    def test_complex_expression(self):
        result = calculator_tool.invoke({"expression": "(10 + 5) * 3"})
        assert result == "45.0"

    def test_invalid_expression(self):
        result = calculator_tool.invoke({"expression": "invalid"})
        assert "Error" in result


class TestSearchTool:
    def test_returns_results(self):
        result = search_tool.invoke({"query": "test query"})
        assert "test query" in result
        assert "placeholder" in result.lower()
