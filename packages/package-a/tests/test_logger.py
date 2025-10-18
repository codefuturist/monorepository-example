"""Tests for logging utilities."""

import logging
import tempfile
from pathlib import Path

from src.logger import setup_logger


class TestSetupLogger:
    """Test suite for logger setup."""

    def test_setup_logger_creates_logger(self) -> None:
        """Test that setup_logger creates a logger instance."""
        logger = setup_logger("test_logger")
        assert isinstance(logger, logging.Logger)
        assert logger.name == "test_logger"

    def test_setup_logger_default_level(self) -> None:
        """Test that logger has correct default level."""
        logger = setup_logger("test_logger_default")
        assert logger.level == logging.INFO

    def test_setup_logger_custom_level(self) -> None:
        """Test that logger can be set to custom level."""
        logger = setup_logger("test_logger_debug", level=logging.DEBUG)
        assert logger.level == logging.DEBUG

    def test_setup_logger_with_file(self) -> None:
        """Test that logger can write to file."""
        with tempfile.TemporaryDirectory() as tmpdir:
            log_file = Path(tmpdir) / "test.log"

            logger = setup_logger("test_logger_file", log_file=str(log_file))
            logger.info("Test message")

            assert log_file.exists()
            assert "Test message" in log_file.read_text()

    def test_setup_logger_has_handlers(self) -> None:
        """Test that logger has at least console handler."""
        logger = setup_logger("test_logger_handlers")
        assert len(logger.handlers) > 0

    def test_setup_logger_console_and_file(self) -> None:
        """Test that logger has both console and file handlers when file specified."""
        with tempfile.TemporaryDirectory() as tmpdir:
            log_file = Path(tmpdir) / "test.log"

            logger = setup_logger("test_logger_both", log_file=str(log_file))
            # Should have console handler + file handler
            assert len(logger.handlers) == 2
