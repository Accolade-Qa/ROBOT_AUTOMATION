from __future__ import annotations

import math
from typing import Any

import can  # pyright: ignore[reportMissingImports]


class CanDriver:
    """Managed CAN bus connection using python-can backends."""

    def __init__(
        self,
        interface: str,
        channel: str | int | None = None,
        bitrate: int | None = None,
        **bus_config: Any,
    ) -> None:
        if not isinstance(interface, str) or not interface.strip():
            raise ValueError("CAN interface must be a non-empty string.")
        if bitrate is not None and (
            not isinstance(bitrate, int)
            or isinstance(bitrate, bool)
            or bitrate <= 0
        ):
            raise ValueError("CAN bitrate must be a positive integer or None.")

        self.interface = interface
        self.channel = channel
        self.bitrate = bitrate
        self._bus_config = bus_config
        self._bus: can.BusABC | None = None

    @property
    def is_open(self) -> bool:
        return self._bus is not None

    def open(self) -> None:
        if self._bus is not None:
            return
        try:
            bus = can.Bus(
                interface=self.interface,
                channel=self.channel,
                bitrate=self.bitrate,
                **self._bus_config,
            )
        except (can.CanError, ValueError) as exc:
            raise RuntimeError(
                f"Could not open CAN interface {self.interface!r} "
                f"on channel {self.channel!r}: {exc}"
            ) from exc
        self._bus = bus

    def close(self) -> None:
        if self._bus is not None:
            bus = self._bus
            self._bus = None
            bus.shutdown()

    def _require_bus(self) -> can.BusABC:
        if self._bus is None:
            raise RuntimeError("CAN bus is not open; call open() first.")
        return self._bus

    def send(
        self,
        arbitration_id: int,
        data: bytes | bytearray | list[int],
        *,
        is_extended_id: bool = False,
        timeout: float | None = None,
    ) -> None:
        message = can.Message(
            arbitration_id=arbitration_id,
            data=data,
            is_extended_id=is_extended_id,
        )
        self._validate_timeout(timeout)
        try:
            self._require_bus().send(message, timeout=timeout)
        except can.CanError as exc:
            raise RuntimeError(
                f"Failed to send CAN frame 0x{arbitration_id:X}: {exc}"
            ) from exc

    def receive(self, timeout: float | None = 1.0) -> can.Message | None:
        self._validate_timeout(timeout)
        try:
            return self._require_bus().recv(timeout=timeout)
        except can.CanError as exc:
            raise RuntimeError(f"Failed to receive CAN frame: {exc}") from exc

    def set_filters(
        self, filters: list[dict[str, int | bool]] | None
    ) -> None:
        try:
            self._require_bus().set_filters(filters)
        except can.CanError as exc:
            raise RuntimeError(f"Failed to configure CAN filters: {exc}") from exc

    @staticmethod
    def _validate_timeout(timeout: float | None) -> None:
        if timeout is not None and (
            not isinstance(timeout, (int, float))
            or isinstance(timeout, bool)
            or not math.isfinite(timeout)
            or timeout < 0
        ):
            raise ValueError("CAN timeout must be a non-negative number or None.")

    def __enter__(self) -> CanDriver:
        self.open()
        return self

    def __exit__(self, exc_type: object, exc_value: object, traceback: object) -> None:
        self.close()
