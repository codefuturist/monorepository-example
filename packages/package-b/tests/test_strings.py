"""Tests for string utilities."""

from package_b.strings import kebab_case, truncate


class TestTruncate:
    """Test suite for truncate function."""

    def test_truncate_no_truncation_needed(self) -> None:
        """Test truncate when string is shorter than max length."""
        result = truncate("hello", max_length=10)
        assert result == "hello"

    def test_truncate_with_default_suffix(self) -> None:
        """Test truncate with default suffix."""
        result = truncate("hello world", max_length=8)
        assert result == "hello..."
        assert len(result) == 8

    def test_truncate_with_custom_suffix(self) -> None:
        """Test truncate with custom suffix."""
        result = truncate("hello world", max_length=11, suffix=" [...]")
        assert result == "hell [...]"
        assert len(result) == 11

    def test_truncate_exact_length(self) -> None:
        """Test truncate when string is exactly max length."""
        result = truncate("hello", max_length=5)
        assert result == "hello"

    def test_truncate_very_short_max_length(self) -> None:
        """Test truncate with very short max_length."""
        result = truncate("hello", max_length=2)
        assert len(result) <= 2


class TestKebabCase:
    """Test suite for kebab_case function."""

    def test_kebab_case_simple(self) -> None:
        """Test kebab_case with simple text."""
        result = kebab_case("hello world")
        assert result == "hello-world"

    def test_kebab_case_underscores(self) -> None:
        """Test kebab_case converts underscores."""
        result = kebab_case("hello_world")
        assert result == "hello-world"

    def test_kebab_case_camel_case(self) -> None:
        """Test kebab_case converts camelCase."""
        result = kebab_case("helloWorld")
        assert result == "hello-world"

    def test_kebab_case_pascal_case(self) -> None:
        """Test kebab_case converts PascalCase."""
        result = kebab_case("HelloWorld")
        assert result == "hello-world"

    def test_kebab_case_already_kebab(self) -> None:
        """Test kebab_case with already kebab-case string."""
        result = kebab_case("hello-world")
        assert result == "hello-world"

    def test_kebab_case_multiple_spaces(self) -> None:
        """Test kebab_case with multiple spaces."""
        result = kebab_case("hello   world")
        assert result == "hello-world"
