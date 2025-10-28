"""Math helper functions for package-c."""

from decimal import Decimal
from typing import Union


def divide_precise(
    numerator: Union[int, float],
    denominator: Union[int, float],
    decimal_places: int = 2,
) -> Decimal:
    """
    Divide two numbers with precise decimal handling.

    Args:
        numerator: Number to divide
        denominator: Number to divide by
        decimal_places: Number of decimal places (default: 2)

    Returns:
        Result as Decimal with specified precision

    Raises:
        ValueError: If denominator is zero
    """
    if denominator == 0:
        raise ValueError("Cannot divide by zero")

    result = Decimal(str(numerator)) / Decimal(str(denominator))
    quantize_str = "0." + "0" * decimal_places
    return result.quantize(Decimal(quantize_str))


def percentage(
    value: Union[int, float],
    total: Union[int, float],
    decimal_places: int = 2,
) -> float:
    """
    Calculate percentage of value relative to total.

    Args:
        value: The value
        total: The total
        decimal_places: Number of decimal places (default: 2)

    Returns:
        Percentage as float

    Raises:
        ValueError: If total is zero
    """
    if total == 0:
        raise ValueError("Total cannot be zero")

    result = (value / total) * 100
    return round(result, decimal_places)
