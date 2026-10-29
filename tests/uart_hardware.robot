*** Settings ***
Documentation    Direct physical UART connectivity check using config/rfid_config.yaml.
Library           ../../libraries/RfidHardwareLib.py
Suite Setup       Initialize Uart Connection
Suite Teardown    Close Uart Connection

*** Test Cases ***
Configured RFID UART Port Opens
    [Documentation]    Opens the configured physical serial port and verifies the connection is active.
    [Tags]    hardware    uart
    ${connected}=    Is Uart Connected
    Should Be True    ${connected}    msg=Configured RFID UART port did not open.
