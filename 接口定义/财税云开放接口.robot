*** Settings ***
Library           requests
Library           RequestsLibrary
Library           json
Library           urllib3
Resource          ../常用变量/常用变量.robot

*** Keywords ***
/open/v1/applications/tokens
    [Arguments]    ${data}
    [Documentation]    接口名称：获取token
    ...    接口：/open/v1/applications/tokens
    &{header}    Create Dictionary    Content-Type=application/json
    create session    api    ${fc_url}[${env}]    headers=${header}    disable_warnings=1
    ${data_body}    set variable    ${data}
    ${response}    post on session    api    /open/v1/applications/tokens    data=${data_body}
    [Return]    ${response}

/open/v1/transaction-chains/queries
    [Arguments]    ${data}    ${Authorization}
    [Documentation]    接口名称：交易链路查询接口
    ...    接口：/open/v1/transaction-chains/queries
    &{header}    Create Dictionary    Content-Type=application/json    Authorization=${Authorization}
    create session    api    ${fc_url}[${env}]    headers=${header}    disable_warnings=1
    ${data_body}    set variable    ${data}
    ${response}    post on session    api    /open/v1/transaction-chains/queries    data=${data_body}
    [Return]    ${response}


