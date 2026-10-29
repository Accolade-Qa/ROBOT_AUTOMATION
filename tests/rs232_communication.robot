*** Settings ***
Documentation    Workbook traceability suite for RS232_Communication.
...              These cases are skipped until the UART hardware and test-specific setup are available.
Library           ../../libraries/RfidHardwareLib.py
Test Template     Workbook Case Pending
Force Tags        workbook    rs232    pending_hardware

*** Keywords ***
Workbook Case Pending
    [Arguments]    ${workbook_sheet}    ${case_id}    ${summary}    ${expected}    ${blocker}
    ${documentation}=    Catenate    SEPARATOR=${\n}
    ...    Source: ${workbook_sheet} / ${case_id}
    ...    Summary: ${summary}
    ...    Expected result: ${expected}
    ...    Execution steps: Refer to the source workbook row for ${case_id}.
    Set Test Documentation    ${documentation}
    Skip    Not executed against hardware: ${blocker}

*** Test Cases ***
TC_RS232_01 - Default Baud Rate
    RS232_Communication    TC_RS232_01    Verify communication at default baud rate, e.g. 115200.    The module responds with OK or valid data.    Requires a connected reader and a confirmed harmless command plus expected response.
TC_RS232_02 - Baud Rate Mismatch
    RS232_Communication    TC_RS232_02    Verify behavior with a mismatched baud rate.    The module does not respond or produces garbled data.    Requires isolated hardware and confirmed configured baud; workbook setup is ambiguous about which side is set to 9600.
TC_RS232_03 - Auto Baud Detection
    RS232_Communication    TC_RS232_03    Verify auto-baud detection if supported.    The module locks to the correct baud rate.    Auto-baud support is unconfirmed and requires hardware plus a defined observation method.
TC_RS232_04 - Baud Rate Change Persistence
    RS232_Communication    TC_RS232_04    Change baud to 57600 and reboot the module.    The module responds at 57600 after reboot.    Changes persistent device configuration; requires approved command, power control, and recovery plan.
TC_RS232_05 - MCU UART Handshake
    RS232_Communication    TC_RS232_05    Connect the module to the MCU/ATCU and send a serial command.    The module responds whenever a command is sent.    Requires the MCU/ATCU hardware and a verified request/response.
TC_RS232_06 - RTS CTS Hardware Flow Control
    RS232_Communication    TC_RS232_06    Enable RTS/CTS, send data, and assert RTS to pause transmission.    The module stops sending when RTS is de-asserted.    Requires RTS/CTS-capable hardware and confirmed flow-control wiring/settings.
TC_RS232_07 - Response Timeout
    RS232_Communication    TC_RS232_07    Verify module response timeout.    Expected result is not specified in the workbook.    Requires a defined timeout threshold, command, and expected recovery behavior.
TC_RS232_08 - Busy State Handling
    RS232_Communication    TC_RS232_08    Verify module busy-state handling.    Expected result is not specified in the workbook.    Requires a reproducible busy condition and expected response/recovery criteria.
TC_RS232_09 - I2C Address Display
    RS232_Communication    TC_RS232_09    Inspect the I2C address displayed in the serial console.    I2C address is non-zero and equals 48.    Requires reader access and a documented console output format.
TC_RS232_10 - SPI Address Display
    RS232_Communication    TC_RS232_10    Inspect the SPI address displayed in the serial console.    SPI address is non-zero.    Requires reader access and a documented console output format.
TC_RS232_11 - UART Address Display
    RS232_Communication    TC_RS232_11    Inspect the UART address displayed in the serial console.    UART address is non-zero.    Requires reader access and a documented console output format.
TC_RS232_12 - Unspecified Workbook Case
    RS232_Communication    TC_RS232_12    Test case has no summary, procedure, or expected result in the workbook.    Expected result is not specified in the workbook.    Workbook row is incomplete; obtain the intended test definition before automation.
TC_RS232_13 - Continuous Communication Stability
    RS232_Communication    TC_RS232_13    Observe communication while tags are out of range and when they enter range.    Device does not freeze or reboot and resumes communication when a tag enters range.    Requires reader, controlled tag movement, and a defined observation duration.
TC_RS232_14 - Invalid or Garbage Data
    RS232_Communication    TC_RS232_14    Inspect serial data during communication for invalid or garbage payloads.    Device does not send invalid or garbage data.    Requires hardware and a confirmed serial framing/parser specification.
TC_RS232_15 - RSSI and CRC Change with Distance
    RS232_Communication    TC_RS232_15    Move multiple tags relative to the reader and observe tag ID, CRC, and RSSI.    Tag IDs are visible and CRC/RSSI change with distance.    Requires multiple tags, controlled distance/fixture, and defined RSSI/CRC output interpretation.
