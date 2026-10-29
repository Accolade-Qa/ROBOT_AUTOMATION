from __future__ import annotations

from typing import Any

from drivers.can_driver import CanDriver


class CanHardwareLib:
    """Robot Framework keywords for direct CAN interface access."""

    ROBOT_LIBRARY_SCOPE = "SUITE"

    def __init__(self) -> None:
        self.driver: CanDriver | None = None

    def open_can_interface(
        self,
        interface: str,
        channel: str | int | None = None,
        bitrate: int | None = None,
    ) -> None:
        self.close_can_interface()
        driver = CanDriver(interface=interface, channel=channel, bitrate=bitrate)
        driver.open()
        self.driver = driver

    def close_can_interface(self) -> None:
        if self.driver is not None:
            self.driver.close()
            self.driver = None

    def send_can_frame(
        self,
        arbitration_id: int,
        data_hex: str,
        is_extended_id: bool = False,
        timeout_seconds: float | None = None,
    ) -> None:
        data = self._parse_hex_bytes(data_hex)
        self._require_driver().send(
            int(arbitration_id),
            data,
            is_extended_id=is_extended_id,
            timeout=timeout_seconds,
        )

    def receive_can_frame(
        self, timeout_seconds: float | None = 1.0
    ) -> dict[str, Any] | None:
        message = self._require_driver().receive(timeout=timeout_seconds)
        if message is None:
            return None
        return {
            "arbitration_id": message.arbitration_id,
            "data": message.data,
            "data_hex": message.data.hex(" ").upper(),
            "is_extended_id": message.is_extended_id,
            "is_remote_frame": message.is_remote_frame,
            "is_error_frame": message.is_error_frame,
            "timestamp": message.timestamp,
        }

    def set_can_filters(
        self, filters: list[dict[str, int | bool]] | None
    ) -> None:
        self._require_driver().set_filters(filters)

    @staticmethod
    def _parse_hex_bytes(data_hex: str) -> bytes:
        if not isinstance(data_hex, str):
            raise TypeError("CAN data must be provided as a hexadecimal string.")
        try:
            return bytes.fromhex(data_hex)
        except ValueError as exc:
            raise ValueError(f"Invalid CAN data hex string: {data_hex!r}") from exc

    def _require_driver(self) -> CanDriver:
        if self.driver is None or not self.driver.is_open:
            raise RuntimeError("CAN interface is not open; open it first.")
        return self.driver
