"""Tests for math helpers."""

import pytest

from src.math_helpers import divide_precise, percentage


class TestDividePrecise:
    """Test suite for divide_precise function."""

    def test_divide_precise_basic(self) -> None:
        """Test basic division with default precision."""
        result = divide_precise(10, 3)
        assert float(result) == 3.33

    def test_divide_precise_custom_precision(self) -> None:
        """Test division with custom precision."""
        result = divide_precise(10, 3, decimal_places=4)
        assert float(result) == 3.3333

    def test_divide_precise_exact(self) -> None:
        """Test division with exact result."""
        result = divide_precise(10, 2)
        assert float(result) == 5.0

    def test_divide_precise_zero_precision(self) -> None:
        """Test division with zero decimal places."""
        result = divide_precise(10, 3, decimal_places=0)
        assert float(result) == 3.0

    def test_divide_precise_zero_denominator(self) -> None:
        """Test that zero denominator raises error."""
        with pytest.raises(ValueError, match="Cannot divide by zero"):
            divide_precise(10, 0)


class TestPercentage:
    """Test suite for percentage function."""

    def test_percentage_basic(self) -> None:
        """Test basic percentage calculation."""
        result = percentage(50, 100)
        assert result == 50.0

    def test_percentage_fraction(self) -> None:
        """Test percentage of fraction."""
        result = percentage(1, 3)
        assert result == 33.33

    def test_percentage_custom_precision(self) -> None:
        """Test percentage with custom precision."""
        result = percentage(1, 3, decimal_places=4)
        assert result == 33.3333

    def test_percentage_zero_precision(self) -> None:
        """Test percentage with zero decimal places."""
        result = percentage(1, 3, decimal_places=0)
        assert result == 33.0

    def test_percentage_zero_total(self) -> None:
        """Test that zero total raises error."""
        with pytest.raises(ValueError, match="Total cannot be zero"):
            percentage(50, 0)

    def test_percentage_zero_value(self) -> None:
        """Test percentage when value is zero."""
        result = percentage(0, 100)
        assert result == 0.0
