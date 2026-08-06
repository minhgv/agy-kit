#!/usr/bin/env python3
"""
Token Cost Calculator Module for agy-kit Evaluation Harness
Computes estimated API costs based on model pricing registry.
"""

PRICING_REGISTRY = {
    "gemini-3.6-flash-high": {"input": 0.075, "output": 0.30},  # USD per 1M tokens
    "gemini-3.6-flash-low": {"input": 0.0375, "output": 0.15},
    "gemini-1.5-pro": {"input": 1.25, "output": 5.00},
    "claude-3-5-sonnet": {"input": 3.00, "output": 15.00},
    "gpt-4o": {"input": 2.50, "output": 10.00},
    "zai/glm-5.2": {"input": 1.00, "output": 3.00},
    "default": {"input": 1.00, "output": 3.00}
}

def calculate_cost(model_name: str, prompt_tokens: int, completion_tokens: int) -> dict:
    rates = PRICING_REGISTRY.get(model_name, PRICING_REGISTRY["default"])
    input_cost = (prompt_tokens / 1_000_000) * rates["input"]
    output_cost = (completion_tokens / 1_000_000) * rates["output"]
    total_cost = input_cost + output_cost
    return {
        "model": model_name,
        "prompt_tokens": prompt_tokens,
        "completion_tokens": completion_tokens,
        "input_cost_usd": round(input_cost, 6),
        "output_cost_usd": round(output_cost, 6),
        "total_cost_usd": round(total_cost, 6)
    }

if __name__ == "__main__":
    res = calculate_cost("gemini-3.6-flash-high", 50000, 10000)
    print(f"Sample Cost Calculation: {res}")
