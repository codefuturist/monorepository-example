"""String utilities for package-b."""


def truncate(text: str, max_length: int, suffix: str = "...") -> str:
    """
    Truncate string to max length, adding suffix if truncated.

    Args:
        text: String to truncate
        max_length: Maximum length of result
        suffix: Suffix to add if truncated (default: "...")

    Returns:
        Truncated string
    """
    if len(text) <= max_length:
        return text

    available = max_length - len(suffix)
    if available <= 0:
        return suffix[:max_length]

    return text[:available] + suffix


def kebab_case(text: str) -> str:
    """
    Convert string to kebab-case.

    Args:
        text: String to convert

    Returns:
        kebab-case string
    """
    import re

    # Replace spaces and underscores with hyphens
    text = re.sub(r"[\s_]+", "-", text)
    # Insert hyphen before uppercase letters
    text = re.sub(r"([a-z])([A-Z])", r"\1-\2", text)
    return text.lower()
