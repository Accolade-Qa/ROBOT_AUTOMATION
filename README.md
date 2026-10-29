# RFID Reader Hardware Automation

Robot Framework and Python foundation for RFID reader/controller validation
over UART. The controller may perform CAN operations in response to UART
commands; PCAN-View is currently supplemental monitoring, not an automated
CAN interface.

## Project structure

```text
config/
  rfid_config.yaml            RFID board and UART connection settings
drivers/
  serial_driver.py            Real byte-oriented UART driver
  can_driver.py               Managed CAN bus driver (python-can backends)
libraries/
  RfidHardwareLib.py          Robot keywords for the physical UART connection
  RfidProtocolLibrary.py      CRC-16/CCITT-FALSE helper
  CanHardwareLib.py           Robot keywords for CAN bus access
tests/
  functional/
    packet_format.robot       All 31 Packet_Format cases with workbook traceability
    rs232_communication.robot All 15 RS232_Communication cases
    uart_hardware.robot       Direct configured-UART connection check
    protocol_helpers.robot    CRC helper vectors executable without hardware
  unit/
    test_protocol.py          Python unit tests
results/                      Robot Framework reports (generated)
```

## Setup and run

Install dependencies into the project virtual environment:

```powershell
python -m venv .venv
.\.venv\Scripts\python.exe -m pip install -r requirements.txt
```

Run software-only CRC checks from the project root:

```powershell
.\.venv\Scripts\python.exe -m unittest discover -s tests\unit
.\.venv\Scripts\python.exe -m robot --pythonpath . --include unit --outputdir results tests\functional
```

The UART hardware suite opens the actual serial port from
`config/rfid_config.yaml`. Confirm the port and baud rate, then run it explicitly:

```powershell
.\.venv\Scripts\python.exe -m robot --pythonpath . --include hardware --outputdir results tests\functional\uart_hardware.robot
```

This opens the configured physical port; it does not send a command or validate
the reader protocol. Workbook cases that require device commands, tags, fixtures,
or destructive actions remain skipped until their protocol and setup are confirmed.

Direct CAN access is provided by `CanDriver` and the `CanHardwareLib` Robot
library. Select the physical backend, channel, and bitrate to match the
installed adapter and test bench before opening the bus. No virtual CAN tests
or mock transport are included.

## Workbook traceability and implementation boundary

The Excel workbook is the source of truth for test IDs, procedures, expected
results, and prerequisites. Phase 1 now has Robot test entries for all 31
`Packet_Format` cases (`TC_RW_01`–`TC_RW_31`) and all 15
`RS232_Communication` cases (`TC_RS232_01`–`TC_RS232_15`). Each case retains
its workbook ID, summary, expected result, and a specific reason it is not yet
safe to execute. Those cases are deliberately reported as **skipped**, not
passed, until the hardware, protocol, fixtures, or missing expected results are
available. For the exact step-by-step procedure, refer to the corresponding
test-ID row in the source workbook.

The executable CRC helper checks cover the CCITT-FALSE example recorded in
`TC_RW_19` (`29 03 00 06` produces `79 6F`) and the standard `123456789`
check value. These validate the software helper only, not end-to-end reader
packet processing. The physical UART connection check only verifies that the
configured COM port opens; it does not verify reader responses.

Frame layout, length-field meaning, CRC coverage for complete frames, command
semantics, and negative-response details must be verified against a real,
known-good UART capture and the device specification before implementing
reader-facing packet tests. The workbook also includes test cases requiring
CAN monitoring, tags, physical fixtures, power control, or firmware tools;
those need their respective equipment and must not be reported as automated
based only on UART responses.

Some workbook entries are incomplete or contradictory. For example,
`TC_RW_25` treats command ID `0x05` as unsupported while `TC_RW_13` assigns
`0x05` to a read command; `TC_RW_26` includes `0x07` in its procedure even
though the workbook assigns that ID to a read. Those cases remain skipped
until the command mapping is clarified.
