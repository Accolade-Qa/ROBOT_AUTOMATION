from __future__ import annotations

from pathlib import Path
from typing import Any

import yaml

from drivers.serial_driver import SerialDriver


class RfidHardwareLib:
    """Robot Framework keywords for direct byte-oriented UART access."""

    ROBOT_LIBRARY_SCOPE = "SUITE"

    def __init__(self) -> None:
        self.project_root = Path(__file__).resolve().parents[1]
        config_path = self.project_root / "config" / "rfid_config.yaml"
        self.config = self._load_yaml(config_path)
        self.driver: SerialDriver | None = None

    @staticmethod
    def _load_yaml(path: Path) -> dict[str, Any]:
        with path.open("r", encoding="utf-8") as config_file:
            config = yaml.safe_load(config_file)
        if not isinstance(config, dict):
            raise ValueError(f"Configuration file must contain a YAML mapping: {path}")
        return config

    def initialize_uart_connection(
        self,
        port: str | None = None,
        baudrate: int | None = None,
        timeout_seconds: float | None = None,
    ) -> None:
        if self.driver is not None:
            self.close_uart_connection()

        uart_config = self.config["board"]["uart"]
        serial_settings: dict[str, str | int | float] = {
            "port": port if port is not None else uart_config["port"],
            "baudrate": (
                baudrate if baudrate is not None else uart_config["baudrate"]
            ),
        }
        if timeout_seconds is not None:
            serial_settings["timeout"] = timeout_seconds
        driver = SerialDriver(**serial_settings)
        driver.open()
        self.driver = driver

    def close_uart_connection(self) -> None:
        if self.driver is not None:
            self.driver.close()
            self.driver = None

    def is_uart_connected(self) -> bool:
        return self.driver is not None and self.driver.is_open

    def write_uart_bytes(self, hex_payload: str) -> str:
        payload = self._parse_hex_bytes(hex_payload)
        self._require_driver().write_bytes(payload)
        return payload.hex(" ").upper()

    def read_uart_bytes(self, size: int) -> bytes:
        return self._require_driver().read_bytes(int(size))

    def bytes_to_hex(self, payload: bytes) -> str:
        if not isinstance(payload, bytes):
            raise TypeError("Payload must be bytes.")
        return payload.hex(" ").upper()

    @staticmethod
    def _parse_hex_bytes(hex_payload: str) -> bytes:
        if not isinstance(hex_payload, str):
            raise TypeError("Hex payload must be a string.")
        try:
            return bytes.fromhex(hex_payload)
        except ValueError as exc:
            raise ValueError(f"Invalid hexadecimal byte sequence: {hex_payload!r}") from exc

    def _require_driver(self) -> SerialDriver:
        if self.driver is None or not self.driver.is_open:
            raise RuntimeError("UART connection is not open; initialize it first.")
        return self.driver
