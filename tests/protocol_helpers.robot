*** Settings ***
Documentation    Software-only checks for protocol helpers; these do not exercise reader firmware.
Library           ../../libraries/RfidProtocolLibrary.py
Force Tags        unit    protocol_helpers

*** Test Cases ***
Workbook CRC-16 Example
    [Documentation]    Validates CRC-16/CCITT-FALSE over the workbook's example bytes 29 03 00 06.
    ${crc}=    Calculate Crc16 Ccitt False    29 03 00 06
    Should Be Equal As Integers    ${crc}    0x796F

Standard CRC-16/CCITT-FALSE Check Value
    [Documentation]    Validates the standard check value for ASCII 123456789.
    ${crc}=    Calculate Crc16 Ccitt False    31 32 33 34 35 36 37 38 39
    Should Be Equal As Integers    ${crc}    0x29B1
