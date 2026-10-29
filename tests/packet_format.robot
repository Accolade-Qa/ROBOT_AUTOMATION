*** Settings ***
Documentation    Workbook traceability suite for Packet_Format. Cases remain skipped until the RFID protocol is verified on hardware.
Library           ../../libraries/RfidHardwareLib.py
Library           ../../libraries/RfidProtocolLibrary.py
Test Template     Workbook Case Pending
Force Tags        workbook    packet_format    pending_hardware

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
TC_RW_01 - Valid Request Frame Format Verification
    Packet_Format    TC_RW_01    Valid request frame returns a properly formatted response.    Response frame: $ + 0xEF + Length + Response Data + CRC16 + #.    Confirm UART capture, frame length semantics, CRC coverage, and response parser.
TC_RW_02 - Invalid Parameters
    Packet_Format    TC_RW_02    Send a request with an invalid parameter.    Negative response: $ + 0xEF + Length + 0x7F + Command ID + 0x01 + CRC16 + #.    Confirm protocol and invalid-parameter request vector with the device owner.
TC_RW_03 - Missing Start Delimiter
    Packet_Format    TC_RW_03    Send a request without the starting delimiter.    Negative response result code 0x02.    Confirm framing behavior and response format on a reader.
TC_RW_04 - Missing End Delimiter
    Packet_Format    TC_RW_04    Send a request without the ending delimiter.    Negative response result code 0x02.    Confirm framing behavior and response format on a reader.
TC_RW_05 - Invalid ECU ID
    Packet_Format    TC_RW_05    Send a request with ECU ID 0x22 instead of 0x11.    Negative response result code 0x03.    Confirm protocol response parsing on a reader.
TC_RW_06 - Invalid Length
    Packet_Format    TC_RW_06    Send a frame whose length does not match its payload.    Negative response result code 0x04.    Confirm length-field semantics and response parsing on a reader.
TC_RW_07 - CRC Verification Failure
    Packet_Format    TC_RW_07    Send a request with an invalid CRC16.    Negative response result code 0x05.    Confirm CRC coverage and response parsing on a reader.
TC_RW_08 - Read Tag EPC
    Packet_Format    TC_RW_08    Read EPC using command ID 0x00.    Positive response command 0x40; EPC must match the tag.    Requires a reader, a known EPC test tag, and a verified read request.
TC_RW_09 - Read Reader Serial Number
    Packet_Format    TC_RW_09    Read the RFID reader serial number using command ID 0x01.    Positive response command 0x41; value must match the reader's stored serial number.    Requires a reader, expected serial number, and verified read request.
TC_RW_10 - Read Trailer VIN
    Packet_Format    TC_RW_10    Read Trailer VIN using command ID 0x02.    Positive response command 0x42; VIN must match the tag data.    Requires a reader, a provisioned tag, and a verified read request.
TC_RW_11 - Read Axle Count
    Packet_Format    TC_RW_11    Read axle count using command ID 0x03.    Positive response command 0x43; value must match tag data.    Requires a reader, a provisioned tag, and a verified read request.
TC_RW_12 - Read Registration Number
    Packet_Format    TC_RW_12    Read registration number using command ID 0x04.    Positive response command 0x44; value must match tag data.    Requires a reader, a provisioned tag, and a verified read request.
TC_RW_13 - Read Gross Combined Weight
    Packet_Format    TC_RW_13    Read gross combined weight using command ID 0x05.    Positive response command 0x45; value must match tag data.    Requires a reader, a provisioned tag, and a verified read request.
TC_RW_14 - Read TA Certification Number
    Packet_Format    TC_RW_14    Read TA certification number using command ID 0x06.    Positive response command 0x46; value must match tag data.    Requires a reader, a provisioned tag, and a verified read request.
TC_RW_15 - Read Insurance Information
    Packet_Format    TC_RW_15    Read insurance information using command ID 0x07.    Positive response command 0x47; value must match tag data.    Requires a reader, a provisioned tag, and a verified read request.
TC_RW_16 - Read Unavailable Parameter
    Packet_Format    TC_RW_16    Read command 0x00 when data is unavailable.    Negative response command 0x7F with command ID 0x00 and result 0x07.    Confirm no-data setup, response format, and error-code mapping.
TC_RW_17 - Write Trailer Serial Number
    Packet_Format    TC_RW_17    Write a new trailer serial number and read it back.    Positive response command 0x69; read-back must equal written data.    Destructive tag write; requires approved sacrificial tag, recovery plan, and verified write protocol.
TC_RW_18 - Write Trailer VIN
    Packet_Format    TC_RW_18    Write a new trailer VIN and read it back.    Positive response command 0x69; read-back must equal written data.    Destructive tag write; requires approved sacrificial tag, recovery plan, and verified write protocol.
TC_RW_19 - Write Axle Count
    Packet_Format    TC_RW_19    Write axle count 0x0006 and read it back.    Workbook example CRC is 0x796F; positive response command 0x69; read-back must match.    Destructive tag write; requires approved sacrificial tag, recovery plan, and verified write protocol.
TC_RW_20 - Write Registration Number
    Packet_Format    TC_RW_20    Write registration number and read it back.    Positive response command 0x69; read-back must equal written data.    Destructive tag write; requires approved sacrificial tag, recovery plan, and verified write protocol.
TC_RW_21 - Write Gross Combined Weight
    Packet_Format    TC_RW_21    Write gross combined weight and read it back.    Positive response command 0x69; read-back must equal written data.    Destructive tag write; requires approved sacrificial tag, recovery plan, and verified write protocol.
TC_RW_22 - Write TA Certification
    Packet_Format    TC_RW_22    Write TA certification and read it back.    Expected result is not specified in the workbook.    Destructive write and missing expected result; requires clarification and an approved test tag.
TC_RW_23 - Write Insurance Information
    Packet_Format    TC_RW_23    Write insurance information and read it back.    Expected result is not specified in the workbook.    Destructive write and missing expected result; requires clarification and an approved test tag.
TC_RW_24 - Invalid Write Data Format
    Packet_Format    TC_RW_24    Send a write request containing an invalid data format.    Negative response result code 0x02.    Confirm invalid-data encoding, CRC coverage, and response parsing on a reader.
TC_RW_25 - Unsupported Command ID
    Packet_Format    TC_RW_25    Send unsupported command ID 0x05 as described in the workbook.    Negative response: command ID 0x05, result 0x06 (unsupported command).    Workbook conflicts with TC_RW_13, which assigns command ID 0x05 to a read; resolve command mapping first.
TC_RW_26 - Reserved Command IDs
    Packet_Format    TC_RW_26    Send requests for reserved command IDs 0x08 and 0x09.    Negative response result 0x06 for each reserved command.    Confirm reserved-command mapping and response parsing on a reader.
TC_RW_27 - Multiple Tags Detected Error
    Packet_Format    TC_RW_27    Issue a read request while multiple tags are detected.    Error response should indicate multiple tags; workbook says code 0x09 or similar.    Requires controlled multi-tag fixture and a confirmed exact error code.
TC_RW_28 - Transmission Failure Error
    Packet_Format    TC_RW_28    Disconnect RS-232 during a response and observe recovery.    TX_FAILED is logged and retries do not continue indefinitely.    Requires hardware, a safe disconnect/recovery procedure, and defined retry/log criteria.
TC_RW_29 - Consecutive Read Requests Performance
    Packet_Format    TC_RW_29    Send 100 read requests with 100 ms intervals.    All 100 succeed and average response time is below 500 ms.    Requires a reader, verified read request, and measured hardware response timing.
TC_RW_30 - Mixed Read and Write Operations
    Packet_Format    TC_RW_30    Read VIN, write VIN, then read VIN again.    All operations succeed and the final read returns the updated VIN.    Destructive tag write; requires approved sacrificial tag, recovery plan, and verified protocol.
TC_RW_31 - Frame CRC Calculation Verification
    Packet_Format    TC_RW_31    Send a frame with a valid CRC, then modify a non-CRC byte.    Valid CRC is accepted; modified CRC returns AEPL_RFID_RESULT_CRC_ERROR.    CRC helper vector is tested separately; device acceptance and rejection require a reader and verified frame format.
