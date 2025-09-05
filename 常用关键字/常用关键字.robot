*** Settings ***
Library           requests
Library           RequestsLibrary
Library           json
Library           SeleniumLibrary
Library           urllib3
Library           DatabaseLibrary
Resource          ../常用变量/常用变量.robot
Library           ExcelLibrary
Library           Collections
Library           String

*** Keywords ***
连接财税云数据库
    Connect To Database    pymysql    financial_cloud    ${fc_mysql_user}[${env}]    ${fc_mysql_pwd}[${env}]    ${fc_mysql_url}[${env}]    ${fc_mysql_port}[${env}]

连接数仓数据库
    Connect To Database    psycopg2    financial_cloud    ${dw_psySql_user}[${env}]    ${dw_psySql_pwd}[${env}]    ${dw_psySql_url}[${env}]    ${dw_psySql_port}[${env}]      alias=dw

断开所有数据库连接
    disconnect_from_all_databases



设置变量
    [Arguments]    ${var}
    ${value}    set variable    ${var}
    [Return]    ${value}

上传文件
    [Arguments]    ${file}    ${file_type}    # 1.文件名包括后缀，2.文件类型如：【text/plain】【application/vnd.openxmlformats-officedocument.spreadsheetml.sheet】【image/jpeg】
    [Documentation]    读取公共文件下的文件
    ${correctfile}    设置变量    {"file":("${file}",open(r"${CURDIR}${/}..${/}公共文件${/}${file}","rb"),"${file_type}")}
    ${files}    evaluate    ${correctfile}
    [Return]    ${files}    # 返回接口用格式的files

打开excel
    [Arguments]    ${file}
    Open Excel Document    ${CURDIR}${/}..${/}公共文件${/}${file}    excel1

保存excel
    [Arguments]    ${file}
    Save Excel Document    ${CURDIR}${/}..${/}公共文件${/}${file}
    Close All Excel Documents

连接pilot_mysql
    [Arguments]    ${数据库}=bo_service_pilot
    Connect To Database    pymysql    ${数据库}    ${pilot_mysql_user}    ${pilot_mysql_pwd}    ${pilot_mysql_url}    ${pilot_mysql_port}

登录用户
    [Arguments]    ${email}=${enterprise_email}
    连接pilot_mysql
    @{result}    query    select id,enterprise_email from bo_service_pilot.users where enterprise_email='${email}'
    Set Suite Variable    ${Lark-User}    ${result}[0][0]
    Set Suite Variable    ${enterprise_email}    ${result}[0][1]

返回成功校验
    [Arguments]    ${response}
    Should Be Equal As Strings    ${response.json()}[code]    0
    Should Be Equal As Strings    ${response.json()}[msg]    成功
    ${returnData}    设置变量    ${response.json()}[data]
    [Return]    ${returnData}

