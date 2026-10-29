from __future__ import annotations

import math

import serial


class SerialDriver:
    """Managed byte-oriented UART connection for the real hardware."""

    def __init__(
        self,
        port: str,
        baudrate: int,
        *,
        bytesize: int = serial.EIGHTBITS,
        parity: str = serial.PARITY_NONE,
        stopbits: int = serial.STOPBITS_ONE,
        timeout: float = 1.0,
        write_timeout: float = 1.0,
    ) -> None:
        if not isinstance(port, str) or not port.strip():
            raise ValueError("UART port must be a non-empty string.")
        if not isinstance(baudrate, int) or isinstance(baudrate, bool) or baudrate <= 0:
            raise ValueError("Baud rate must be a positive integer.")
        if bytesize not in (serial.FIVEBITS, serial.SIXBITS, serial.SEVENBITS, serial.EIGHTBITS):
            raise ValueError("UART data bits must be 5, 6, 7, or 8.")
        if parity not in (serial.PARITY_NONE, serial.PARITY_EVEN, serial.PARITY_ODD, serial.PARITY_MARK, serial.PARITY_SPACE):
            raise ValueError(f"Unsupported UART parity: {parity!r}.")
        if stopbits not in (serial.STOPBITS_ONE, serial.STOPBITS_ONE_POINT_FIVE, serial.STOPBITS_TWO):
            raise ValueError(f"Unsupported UART stop-bit setting: {stopbits!r}.")
        self._validate_timeout("timeout", timeout)
        self._validate_timeout("write_timeout", write_timeout)

        self.port = port
        self.baudrate = baudrate
        self.bytesize = bytesize
        self.parity = parity
        self.stopbits = stopbits
        self.timeout = timeout
        self.write_timeout = write_timeout
        self.connection: serial.Serial | None = None

    @staticmethod
    def _validate_timeout(name: str, value: float | None) -> None:
        if value is not None and (
            not isinstance(value, (int, float))
            or isinstance(value, bool)
            or not math.isfinite(value)
            or value < 0
        ):
            raise ValueError(f"{name} must be a non-negative number or None.")

    @property
    def is_open(self) -> bool:
        return self.connection is not None and self.connection.is_open

    def open(self) -> None:
        if self.is_open:
            return
        try:
            connection = serial.Serial(
                port=self.port,
                baudrate=self.baudrate,
                bytesize=self.bytesize,
                parity=self.parity,
                stopbits=self.stopbits,
                timeout=self.timeout,
                write_timeout=self.write_timeout,
            )
        except serial.SerialException as exc:
            raise RuntimeError(
                f"Could not open UART port {self.port}: {exc}"
            ) from exc
        self.connection = connection

    def close(self) -> None:
        if self.connection is not None:
            self.connection.close()
            self.connection = None

    def _require_connection(self) -> serial.Serial:
        if not self.is_open:
            raise RuntimeError(
                f"UART port {self.port} is not open; call open() first."
            )
        return self.connection

    def write_bytes(self, payload: bytes) -> None:
        if not isinstance(payload, bytes):
            raise TypeError("UART payload must be bytes.")
        connection = self._require_connection()
        try:
            written = connection.write(payload)
            if written != len(payload):
                raise TimeoutError(
                    f"Incomplete write to UART port {self.port}: "
                    f"{written} of {len(payload)} bytes sent."
                )
            connection.flush()
        except serial.SerialException as exc:
            raise RuntimeError(f"Failed to write to UART port {self.port}: {exc}") from exc

    def read_bytes(self, size: int) -> bytes:
        if not isinstance(size, int) or isinstance(size, bool) or size <= 0:
            raise ValueError("Read size must be a positive integer.")
        connection = self._require_connection()
        try:
            payload = connection.read(size)
        except serial.SerialException as exc:
            raise RuntimeError(f"Failed to read from UART port {self.port}: {exc}") from exc
        if not payload:
            raise TimeoutError(
                f"Timed out reading from UART port {self.port}."
            )
        return payload

    def __enter__(self) -> SerialDriver:
        self.open()
        return self

    def __exit__(self, exc_type: object, exc_value: object, traceback: object) -> None:
        self.close()
