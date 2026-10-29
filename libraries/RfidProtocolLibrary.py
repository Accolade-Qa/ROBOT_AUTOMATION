from __future__ import annotations


class RfidProtocolLibrary:
    """Protocol helpers whose behavior is established by the handoff/workbook."""

    @staticmethod
    def calculate_crc16_ccitt_false(hex_payload: str) -> int:
        """Calculate CRC-16/CCITT-FALSE over the supplied bytes."""
        if not isinstance(hex_payload, str):
            raise TypeError("Hex payload must be a string.")
        try:
            payload = bytes.fromhex(hex_payload)
        except ValueError as exc:
            raise ValueError(
                f"Invalid hexadecimal byte sequence: {hex_payload!r}"
            ) from exc

        crc = 0xFFFF
        for value in payload:
            crc ^= value << 8
            for _ in range(8):
                crc = (
                    ((crc << 1) ^ 0x1021) & 0xFFFF
                    if crc & 0x8000
                    else (crc << 1) & 0xFFFF
                )
        return crc
