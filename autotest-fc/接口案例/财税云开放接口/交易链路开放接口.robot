*** Settings ***
Suite Setup    Run Keywords    连接财税云数据库    AND    连接数仓数据库
Suite Teardown    断开所有数据库连接
Library           requests
Library           RequestsLibrary
Library           json
Library           SeleniumLibrary
Library           urllib3
Library           DatabaseLibrary
Library           Collections
Resource          ../../常用关键字/常用关键字.robot
Resource          ../../接口定义/财税云开放接口.robot

*** Test Cases ***
跨境仓到仓
    [Template]    跨境仓到仓关键字
    #始发节点     #目标节点    #存货分类
    CN01SZ-ID    ID01JKT    1,4,2
    CN01SZ-SG    SG01KL     1
    CN01SZ-SG    PH01MNL    1
    ID02SBY      ID01JKT    2,1
    
本地仓到仓
    [Template]    本地仓到仓关键字
    #始发节点     #目标节点    #存货分类
    ID02SBY      ID01JKT    2,1
    CN01SZ-ID    ID02SBY    1,2,4
    CN01SZ-ID    ID01JKT    1,2,4

跨境仓到店
    [Template]    跨境仓到店关键字
    #始发节点     #目标节点    #存货分类
    CN01SZ-ID    IDNV016    1
    ID02SBY      IDNV016    1,2,4
    CN01SZ-ID    IDNV001    1,4,2

本地仓到店
    [Template]    本地仓到店关键字
    #始发节点     #目标节点    #存货分类
    ID01JKT      IDNV001    1
    ID02SBY      IDNV016    1,2,4
    CN01SZ-ID    IDNV001    1,4,2

跨境供应商直邮到仓
    [Template]    跨境供应商直邮到仓关键字
    #始发节点    #采购主体    #目标节点    #存货分类
    SP00000007    BO002    ID01JKT    1,2,4
    SP00000007    BO010    ID01JKT    1,2,4
    SP00000008    BO011    ID02SBY    1
    SP00000004    PT001    ID03TGR    2

本地供应商直邮到仓
    [Template]    本地供应商直邮到仓关键字
    #始发节点    #采购主体    #目标节点    #存货分类
    SP00002382    109      ID01JKT    1
    SP00000021    BO002    ID01JKT    1,2,4
    SP00000021    PT001    ID02SBY    1,2,4
    SP00000021    BO027    ID02SBY    1,2,4

跨境供应商直邮到店
    [Template]    跨境供应商直邮到店关键字
    #始发节点    #采购主体    #目标节点    #存货分类
    SP00002382    BO002    IDNV066    1,2,4
    SP00000021    BO002    IDNV045    1,2,4
    SP00000021    PT001    IDNV002    1,2

本地供应商直邮到店
    [Template]    本地供应商直邮到店关键字
    #始发节点     #采购主体    #目标节点    #存货分类
    SP00002382    BO002    BOE001    1,2,4
    SP00002382    PT001    IDNV002    1,2
    SP00002382    BO004    IDNV068    1,2,4

国到国
    [Template]    国到国关键字
    #始发节点       #目标节点    #存货分类
    CN            ID          1,2,4
    CN            MY          1,2
    CN            CN          1,2,4

仓到终端
    [Template]    仓到终端关键字
    #始发节点     #存货分类
    ID01JKT      1,2
    SG01KL       1,2,4
    CN01SZ-ID    1,4,2

本地店到店
    [Template]    本地店到店关键字
    #始发节点       #目标节点    #存货分类
    IDOS094       IDNV019     1,2,4
    IDOS099       IDOS073     1,2,4
    IDNV006       IDNV006     1,2

跨境供应商到客
    [Template]    跨境供应商到客关键字
    #始发供应商    #采购主体    #目标客户    #存货分类
    SP00002382    BO011    CM00000030    1,2,4
    SP00000021    BO002    CM00000020    1,2,4
    SP00000021    PT001    CM00000001    1,2

本地仓到客
    [Template]    本地仓到客关键字
    #始发仓库     #目标客户       #存货分类
    ID01JKT      CM00000022    1,2,4
    CN01SZ-ID    CM00000021    1,2,4
    ID01JKT      CM00000001    1,2

本地供应商到客
    [Template]    本地供应商到客关键字
    #始发供应商    #采购主体    #目标客户    #存货分类
    SP00002382    109      CM00000010    1,2,4
    SP00000021    BO002    CM00000003    1,2,4
    SP00000021    PT001    CM00000001    1,2

*** Keywords ***
跨境仓到仓关键字
    [Arguments]    ${start_warehouse}    ${end_warehouse}    ${stock_categories}
    #仓库子公司关系转json
    ${warehouse_subsidiary_dict}    Evaluate    json.loads('''${warehouse_subsidiary}''')
    #查询是否存在匹配规则
    @{result}    query    SELECT count(*) FROM fc_transaction_matching_rule tmr JOIN fc_transaction_matching_rule_delivery_node tmrd on tmr.id = tmrd.transaction_matching_rule_id where UNIX_TIMESTAMP()<tmr.end_time and UNIX_TIMESTAMP()>tmr.start_time and tmr.status=1 and tmrd.`start_node` = '${start_warehouse}' and tmrd.`end_node` = '${end_warehouse}' and `delivery_model` in (1);
    ${count}    设置变量    ${result}[0][0]
    #MatchRule=0则没有匹配规则，1则有
    ${MatchRule}    Set Variable If    ${count}==0    0    1
    log    ${warehouse_subsidiary_dict}
    ${start_subsidiary}    设置变量    ${warehouse_subsidiary_dict}[${start_warehouse}]
    ${end_subsidiary}    设置变量    ${warehouse_subsidiary_dict}[${end_warehouse}]
    @{start_subsidiary_list}    Create List
    @{end_subsidiary_list}    Create List
    ${start_isList}    Evaluate    "${start_subsidiary}".startswith("[")
    ${end_isList}    Evaluate    "${end_subsidiary}".startswith("[")
    ${start_subsidiary_list}    Run Keyword If    ${start_isList}    Copy List    ${start_subsidiary}    
    ...    ELSE    Create List    ${start_subsidiary}
    ${end_subsidiary_list}    Run Keyword If    ${end_isList}    Copy List    ${end_subsidiary}
    ...    ELSE    Create List    ${end_subsidiary}
    #去掉数据[]后续sql查询使用
    ${start_subsidiary_list}    Evaluate    "${start_subsidiary_list}".replace("[", "").replace("]", "")
    ${end_subsidiary_list}    Evaluate    "${end_subsidiary_list}".replace("[", "").replace("]", "")
    log    ${start_subsidiary_list}
    log    ${end_subsidiary_list}
    #查询是否存在交易链路
    @{result}    query    select count(*) from fc_transaction_chain_rule where shipping_subsidiary_code in (${start_subsidiary_list}) and receiving_subsidiary_code in (${end_subsidiary_list}) and UNIX_TIMESTAMP()<end_time and UNIX_TIMESTAMP()>start_time and status=1 and (levels like '%"node_types": [1, 2]%' or levels like '%"node_types": [2, 1]%' or levels like '%"node_types": [2]%') and (levels like '%"node_types": [3, 4]%' or levels like '%"node_types": [4, 3]%' or levels like '%"node_types": [3]%');
    ${length}    设置变量    ${result}[0][0]
    @{result}    query    select code,levels->'$[*].pricing_rule_id' from fc_transaction_chain_rule where shipping_subsidiary_code in (${start_subsidiary_list}) and receiving_subsidiary_code in (${end_subsidiary_list}) and UNIX_TIMESTAMP()<end_time and UNIX_TIMESTAMP()>start_time and status=1 and (levels like '%"node_types": [1, 2]%' or levels like '%"node_types": [2, 1]%' or levels like '%"node_types": [2]%') and (levels like '%"node_types": [3, 4]%' or levels like '%"node_types": [4, 3]%' or levels like '%"node_types": [3]%');
    @{code_list}    Create List
    @{price_rule_list}    Create List
    FOR    ${i}    IN RANGE    ${length}
        Append To List    ${code_list}    ${result}[${i}][0]
        Append To List    ${price_rule_list}    ${result}[${i}][1]
    END
    Log    ${code_list}
    ${code_length}    Get Length    ${code_list}
    Log    ${price_rule_list}
    # 先转换为真实列表结构
    ${cleaned} =    Evaluate    "${price_rule_list}".replace("[", "").replace("]", "").replace("'", "").replace(" ", "")
    Log    ${cleaned}
    @{items} =    Split String    ${cleaned}    separator=,
    # 再展平嵌套列表
    @{new_price_rule_list}    Create List
    Append To List    ${new_price_rule_list}    @{items}
    ${new_price_rule_list}    Evaluate    list(set(${new_price_rule_list}))
    #去掉值为0的
    Remove Values From List    ${new_price_rule_list}    0
    Log    ${new_price_rule_list}
    ${price_rule_list_length}    Get Length    ${new_price_rule_list}    
    #根据存货分类传惨决定查看定价规则SQL
    @{NoMatch_id_list}    Create List    #对不上存货分类的定价规则id
    FOR    ${i}    IN RANGE    ${price_rule_list_length}
        ${origin_sql}    设置变量    select count(*) from fc_pricing_rule where id='${new_price_rule_list}[${i}]'
        ${origin_sql}    Run Keyword If    '1' in '${stock_categories}'     设置变量    ${origin_sql} and calculation_rules like '%"stock_category": 1%'
        ...    ELSE    设置变量    ${origin_sql}
        ${origin_sql}    Run Keyword If    '2' in '${stock_categories}'     设置变量    ${origin_sql} and calculation_rules like '%"stock_category": 2%'
        ...    ELSE    设置变量    ${origin_sql}
        ${origin_sql}    Run Keyword If    '4' in '${stock_categories}'     设置变量    ${origin_sql} and calculation_rules like '%"stock_category": 4%'
        ...    ELSE    设置变量    ${origin_sql}
        Log    ${origin_sql}
        @{result}    query    ${origin_sql}
        ${price_count}    设置变量    ${result}[0][0]
        Log    ${price_count}
        Run Keyword If    ${price_count}==0    Append To List    ${NoMatch_id_list}    ${new_price_rule_list}[${i}]
    END
    Log    ${NoMatch_id_list}
    ${NoMatch_id_list_len}    Get Length    ${NoMatch_id_list}
    #确定查询交易链路时加的sql
    ${add_sql}    设置变量     and levels REGEXP
    FOR    ${i}    IN RANGE    ${NoMatch_id_list_len}
        ${add_sql}    Run Keyword If    ${i}==0    设置变量    ${add_sql} '${NoMatch_id_list}[${i}]'
        ...    ELSE    设置变量    ${add_sql}[:-1]|${NoMatch_id_list}[${i}]'
        Log    ${add_sql}
    END
    Log    ${add_sql}
    #如果没有不匹配的定价规则，则把add_sql设置为空
    ${add_sql}    Run Keyword If    ${NoMatch_id_list_len}==0    设置变量    ${SPACE}
    ...    ELSE    设置变量    ${add_sql}
    #用没有匹配上的定价规则反查是哪个交易链路用到的，并去掉该交易链路，不会返回此交易链路
    ${sql}    设置变量    ${SPACE}
    ${new_code_list}    Copy List    ${code_list}
    FOR    ${i}    IN RANGE    ${code_length}
        Continue For Loop If    ${NoMatch_id_list_len}==0
        ${sql}    设置变量     select count(*) from fc_transaction_chain_rule where code='${code_list}[${i}]' ${add_sql}
        @{result}    query    ${sql}
        ${count3}    设置变量    ${result}[0][0]
        Run Keyword Unless    ${count3}==0    Remove Values From List    ${new_code_list}    ${code_list}[${i}]
    END
    #数据库查询出来最终结果的交易链路，后续和接口的交易链路作对比
    Log    ${new_code_list}
    #获取开放接口token
    ${data}    设置变量    {"app_id":"${app_id}[${env}]","app_secret":"${app_secret}[${env}]"}
    ${response}    /open/v1/applications/tokens    ${data}
    ${Authorization}    设置变量    ${response.json()}[data][token]
    #查询交易链路接口
    ${data}    设置变量    {"delivery_model":1,"start_nodes":[{"supplier_code":"","purchase_subsidiary_code":"","store_code":"","country_Code":"","warehouse_code":"${start_warehouse}"}],"end_nodes":[{"warehouse_code":"${end_warehouse}","country_Code":"","store_code":"","customer_code":""}],"stock_categories":[${stock_categories}]}
    ${response}    /open/v1/transaction-chains/queries    ${data}    ${Authorization}
    log    ${response.json()}
    #抓取接口返回的交易链路
    @{intf_code_list}    Create List
    ${intf_code_list}    Run Keyword If    ${response.json()}[code]==0    收集接口返回的交易链路    ${response}    ${intf_code_list}
    ...    ELSE    设置变量    ${intf_code_list}
    ${new_code_list}    Evaluate    sorted(${new_code_list})
    ${intf_code_list}    Evaluate    sorted(${intf_code_list})
    Run Keyword If    ${MatchRule}==1    Should Be Equal As Strings    ${response.json()}[message]    success
    Should Be Equal    ${new_code_list}    ${intf_code_list}

本地仓到仓关键字
    [Arguments]    ${start_warehouse}    ${end_warehouse}    ${stock_categories}
    #仓库子公司关系转json
    ${warehouse_subsidiary_dict}    Evaluate    json.loads('''${warehouse_subsidiary}''')
    #查询是否存在匹配规则
    @{result}    query    SELECT count(*) FROM fc_transaction_matching_rule tmr JOIN fc_transaction_matching_rule_delivery_node tmrd on tmr.id = tmrd.transaction_matching_rule_id where UNIX_TIMESTAMP()<tmr.end_time and UNIX_TIMESTAMP()>tmr.start_time and tmr.status=1 and tmrd.`start_node` = '${start_warehouse}' and tmrd.`end_node` = '${end_warehouse}' and `delivery_model` in (2);
    ${count}    设置变量    ${result}[0][0]
    #MatchRule=0则没有匹配规则，1则有
    ${MatchRule}    Set Variable If    ${count}==0    0    1
    log    ${warehouse_subsidiary_dict}
    ${start_subsidiary}    设置变量    ${warehouse_subsidiary_dict}[${start_warehouse}]
    ${end_subsidiary}    设置变量    ${warehouse_subsidiary_dict}[${end_warehouse}]
    @{start_subsidiary_list}    Create List
    @{end_subsidiary_list}    Create List
    ${start_isList}    Evaluate    "${start_subsidiary}".startswith("[")
    ${end_isList}    Evaluate    "${end_subsidiary}".startswith("[")
    ${start_subsidiary_list}    Run Keyword If    ${start_isList}    Copy List    ${start_subsidiary}
    ...    ELSE    Create List    ${start_subsidiary}
    ${end_subsidiary_list}    Run Keyword If    ${end_isList}    Copy List    ${end_subsidiary}
    ...    ELSE    Create List    ${end_subsidiary}
    #去掉数据[]后续sql查询使用
    ${start_subsidiary_list}    Evaluate    "${start_subsidiary_list}".replace("[", "").replace("]", "")
    ${end_subsidiary_list}    Evaluate    "${end_subsidiary_list}".replace("[", "").replace("]", "")
    log    ${start_subsidiary_list}
    log    ${end_subsidiary_list}
    #查询是否存在交易链路
    @{result}    query    select count(*) from fc_transaction_chain_rule where shipping_subsidiary_code in (${start_subsidiary_list}) and receiving_subsidiary_code in (${end_subsidiary_list}) and UNIX_TIMESTAMP()<end_time and UNIX_TIMESTAMP()>start_time and status=1;
    ${length}    设置变量    ${result}[0][0]
    @{result}    query    select code,levels->'$[*].pricing_rule_id' from fc_transaction_chain_rule where shipping_subsidiary_code in (${start_subsidiary_list}) and receiving_subsidiary_code in (${end_subsidiary_list}) and UNIX_TIMESTAMP()<end_time and UNIX_TIMESTAMP()>start_time and status=1;
    @{code_list}    Create List
    @{price_rule_list}    Create List
    FOR    ${i}    IN RANGE    ${length}
        Append To List    ${code_list}    ${result}[${i}][0]
        Append To List    ${price_rule_list}    ${result}[${i}][1]
    END
    Log    ${code_list}
#    ${code_length}    Get Length    ${code_list}
#    Log    ${price_rule_list}
#    # 先转换为真实列表结构
#    ${cleaned} =    Evaluate    "${price_rule_list}".replace("[", "").replace("]", "").replace("'", "").replace(" ", "")
#    Log    ${cleaned}
#    @{items} =    Split String    ${cleaned}    separator=,
#    # 再展平嵌套列表
#    @{new_price_rule_list}    Create List
#    Append To List    ${new_price_rule_list}    @{items}
#    ${new_price_rule_list}    Evaluate    list(set(${new_price_rule_list}))
#    #去掉值为0的
#    Remove Values From List    ${new_price_rule_list}    0
#    Log    ${new_price_rule_list}
#    ${price_rule_list_length}    Get Length    ${new_price_rule_list}
#    #根据存货分类传惨决定查看定价规则SQL
#    @{NoMatch_id_list}    Create List    #对不上存货分类的定价规则id
#    FOR    ${i}    IN RANGE    ${price_rule_list_length}
#        ${origin_sql}    设置变量    select count(*) from fc_pricing_rule where id='${new_price_rule_list}[${i}]'
#        ${origin_sql}    Run Keyword If    '1' in '${stock_categories}'     设置变量    ${origin_sql} and calculation_rules like '%"stock_category": 1%'
#        ...    ELSE    设置变量    ${origin_sql}
#        ${origin_sql}    Run Keyword If    '2' in '${stock_categories}'     设置变量    ${origin_sql} and calculation_rules like '%"stock_category": 2%'
#        ...    ELSE    设置变量    ${origin_sql}
#        ${origin_sql}    Run Keyword If    '4' in '${stock_categories}'     设置变量    ${origin_sql} and calculation_rules like '%"stock_category": 4%'
#        ...    ELSE    设置变量    ${origin_sql}
#        Log    ${origin_sql}
#        @{result}    query    ${origin_sql}
#        ${price_count}    设置变量    ${result}[0][0]
#        Log    ${price_count}
#        Run Keyword If    ${price_count}==0    Append To List    ${NoMatch_id_list}    ${new_price_rule_list}[${i}]
#    END
#    Log    ${NoMatch_id_list}
#    ${NoMatch_id_list_len}    Get Length    ${NoMatch_id_list}
#    #确定查询交易链路时加的sql
#    ${add_sql}    设置变量     and levels REGEXP
#    FOR    ${i}    IN RANGE    ${NoMatch_id_list_len}
#        ${add_sql}    Run Keyword If    ${i}==0    设置变量    ${add_sql} '${NoMatch_id_list}[${i}]'
#        ...    ELSE    设置变量    ${add_sql}[:-1]|${NoMatch_id_list}[${i}]'
#        Log    ${add_sql}
#    END
#    Log    ${add_sql}
#    #如果没有不匹配的定价规则，则把add_sql设置为空
#    ${add_sql}    Run Keyword If    ${NoMatch_id_list_len}==0    设置变量    ${SPACE}
#    ...    ELSE    设置变量    ${add_sql}
#    #用没有匹配上的定价规则反查是哪个交易链路用到的，并去掉该交易链路，不会返回此交易链路
#    ${sql}    设置变量    ${SPACE}
#    ${new_code_list}    Copy List    ${code_list}
#    FOR    ${i}    IN RANGE    ${code_length}
#        Continue For Loop If    ${NoMatch_id_list_len}==0
#        ${sql}    设置变量     select count(*) from fc_transaction_chain_rule where code='${code_list}[${i}]' ${add_sql}
#        @{result}    query    ${sql}
#        ${count3}    设置变量    ${result}[0][0]
#        Run Keyword Unless    ${count3}==0    Remove Values From List    ${new_code_list}    ${code_list}[${i}]
#    END
#    #数据库查询出来最终结果的交易链路，后续和接口的交易链路作对比
#    Log    ${new_code_list}
    #获取开放接口token
    ${data}    设置变量    {"app_id":"${app_id}[${env}]","app_secret":"${app_secret}[${env}]"}
    ${response}    /open/v1/applications/tokens    ${data}
    ${Authorization}    设置变量    ${response.json()}[data][token]
    #查询交易链路接口
    ${data}    设置变量    {"delivery_model":2,"start_nodes":[{"supplier_code":"","purchase_subsidiary_code":"","store_code":"","country_Code":"","warehouse_code":"${start_warehouse}"}],"end_nodes":[{"warehouse_code":"${end_warehouse}","country_Code":"","store_code":"","customer_code":""}],"stock_categories":[${stock_categories}]}
    ${response}    /open/v1/transaction-chains/queries    ${data}    ${Authorization}
    log    ${response.json()}
    #抓取接口返回的交易链路
    @{intf_code_list}    Create List
    ${intf_code_list}    Run Keyword If    ${response.json()}[code]==0    收集接口返回的交易链路    ${response}    ${intf_code_list}
    ...    ELSE    设置变量    ${intf_code_list}
    ${code_list}    Evaluate    sorted(${code_list})
    ${intf_code_list}    Evaluate    sorted(${intf_code_list})
    Run Keyword If    ${MatchRule}==1    Should Be Equal As Strings    ${response.json()}[message]    success
    Should Be Equal    ${code_list}    ${intf_code_list}

跨境仓到店关键字
    [Arguments]    ${start_warehouse}    ${end_store}    ${stock_categories}
    #仓库子公司关系转json
    ${warehouse_subsidiary_dict}    Evaluate    json.loads('''${warehouse_subsidiary}''')
    #查询是否存在匹配规则
    #@{result}    query    SELECT count(*) FROM fc_transaction_matching_rule tmr JOIN fc_transaction_matching_rule_delivery_node tmrd on tmr.id = tmrd.transaction_matching_rule_id where UNIX_TIMESTAMP()<tmr.end_time and UNIX_TIMESTAMP()>tmr.start_time and tmr.status=1 and tmrd.`start_node` = '${start_warehouse}' and tmrd.`end_node` = '${end_warehouse}' and `delivery_model` in (1);
    #${count}    设置变量    ${result}[0][0]
    #MatchRule=0则没有匹配规则，1则有
    #${MatchRule}    Set Variable If    ${count}==0    0    1
    #数仓获取门店对应的子公司
    @{result}    query    select entity_code from ods.ods_retail_biz_store_db_rt_store_info_rt where store_code='${end_store}';
    ...    alias=dw    #数仓的数据库查询要加alias=dw
    ${end_subsidiary}    设置变量    ${result}[0][0]
    log    ${warehouse_subsidiary_dict}
    ${start_subsidiary}    设置变量    ${warehouse_subsidiary_dict}[${start_warehouse}]

    @{start_subsidiary_list}    Create List
    @{end_subsidiary_list}    Create List    ${end_subsidiary}
    ${start_isList}    Evaluate    "${start_subsidiary}".startswith("[")
    ${end_isList}    Evaluate    "${end_subsidiary}".startswith("[")
    ${start_subsidiary_list}    Run Keyword If    ${start_isList}    Copy List    ${start_subsidiary}
    ...    ELSE    Create List    ${start_subsidiary}
    ${end_subsidiary_list}    Run Keyword If    ${end_isList}    Copy List    ${end_subsidiary}
    ...    ELSE    Create List    ${end_subsidiary}
    #去掉数据[]后续sql查询使用
    ${start_subsidiary_list}    Evaluate    "${start_subsidiary_list}".replace("[", "").replace("]", "")
    ${end_subsidiary_list}    Evaluate    "${end_subsidiary_list}".replace("[", "").replace("]", "")
    log    ${start_subsidiary_list}
    log    ${end_subsidiary_list}
    #查询是否存在交易链路
    @{result}    query    select count(*) from fc_transaction_chain_rule where shipping_subsidiary_code in (${start_subsidiary_list}) and receiving_subsidiary_code in (${end_subsidiary_list}) and UNIX_TIMESTAMP()<end_time and UNIX_TIMESTAMP()>start_time and status=1 and (levels like '%"node_types": [1, 2]%' or levels like '%"node_types": [2, 1]%' or levels like '%"node_types": [2]%') and (levels like '%"node_types": [3, 4]%' or levels like '%"node_types": [4, 3]%' or levels like '%"node_types": [3]%');
    ${length}    设置变量    ${result}[0][0]
    @{result}    query    select code,levels->'$[*].pricing_rule_id' from fc_transaction_chain_rule where shipping_subsidiary_code in (${start_subsidiary_list}) and receiving_subsidiary_code in (${end_subsidiary_list}) and UNIX_TIMESTAMP()<end_time and UNIX_TIMESTAMP()>start_time and status=1 and (levels like '%"node_types": [1, 2]%' or levels like '%"node_types": [2, 1]%' or levels like '%"node_types": [2]%') and (levels like '%"node_types": [3, 4]%' or levels like '%"node_types": [4, 3]%' or levels like '%"node_types": [3]%');
    @{code_list}    Create List
    @{price_rule_list}    Create List
    FOR    ${i}    IN RANGE    ${length}
        Append To List    ${code_list}    ${result}[${i}][0]
        Append To List    ${price_rule_list}    ${result}[${i}][1]
    END
    Log    ${code_list}
    ${code_length}    Get Length    ${code_list}
    Log    ${price_rule_list}
    # 先转换为真实列表结构
    ${cleaned} =    Evaluate    "${price_rule_list}".replace("[", "").replace("]", "").replace("'", "").replace(" ", "")
    Log    ${cleaned}
    @{items} =    Split String    ${cleaned}    separator=,
    # 再展平嵌套列表
    @{new_price_rule_list}    Create List
    Append To List    ${new_price_rule_list}    @{items}
    ${new_price_rule_list}    Evaluate    list(set(${new_price_rule_list}))
    #去掉值为0的
    Remove Values From List    ${new_price_rule_list}    0
    Log    ${new_price_rule_list}
    ${price_rule_list_length}    Get Length    ${new_price_rule_list}
    #根据存货分类传惨决定查看定价规则SQL
    @{NoMatch_id_list}    Create List    #对不上存货分类的定价规则id
    FOR    ${i}    IN RANGE    ${price_rule_list_length}
        ${origin_sql}    设置变量    select count(*) from fc_pricing_rule where id='${new_price_rule_list}[${i}]'
        ${origin_sql}    Run Keyword If    '1' in '${stock_categories}'     设置变量    ${origin_sql} and calculation_rules like '%"stock_category": 1%'
        ...    ELSE    设置变量    ${origin_sql}
        ${origin_sql}    Run Keyword If    '2' in '${stock_categories}'     设置变量    ${origin_sql} and calculation_rules like '%"stock_category": 2%'
        ...    ELSE    设置变量    ${origin_sql}
        ${origin_sql}    Run Keyword If    '4' in '${stock_categories}'     设置变量    ${origin_sql} and calculation_rules like '%"stock_category": 4%'
        ...    ELSE    设置变量    ${origin_sql}
        Log    ${origin_sql}
        @{result}    query    ${origin_sql}
        ${price_count}    设置变量    ${result}[0][0]
        Log    ${price_count}
        Run Keyword If    ${price_count}==0    Append To List    ${NoMatch_id_list}    ${new_price_rule_list}[${i}]
    END
    Log    ${NoMatch_id_list}
    ${NoMatch_id_list_len}    Get Length    ${NoMatch_id_list}
    #确定查询交易链路时加的sql
    ${add_sql}    设置变量     and levels REGEXP
    FOR    ${i}    IN RANGE    ${NoMatch_id_list_len}
        ${add_sql}    Run Keyword If    ${i}==0    设置变量    ${add_sql} '${NoMatch_id_list}[${i}]'
        ...    ELSE    设置变量    ${add_sql}[:-1]|${NoMatch_id_list}[${i}]'
        Log    ${add_sql}
    END
    Log    ${add_sql}
    #如果没有不匹配的定价规则，则把add_sql设置为空
    ${add_sql}    Run Keyword If    ${NoMatch_id_list_len}==0    设置变量    ${SPACE}
    ...    ELSE    设置变量    ${add_sql}
    #用没有匹配上的定价规则反查是哪个交易链路用到的，并去掉该交易链路，不会返回此交易链路
    ${sql}    设置变量    ${SPACE}
    ${new_code_list}    Copy List    ${code_list}
    FOR    ${i}    IN RANGE    ${code_length}
        Continue For Loop If    ${NoMatch_id_list_len}==0
        ${sql}    设置变量     select count(*) from fc_transaction_chain_rule where code='${code_list}[${i}]' ${add_sql}
        @{result}    query    ${sql}
        ${count3}    设置变量    ${result}[0][0]
        Run Keyword Unless    ${count3}==0    Remove Values From List    ${new_code_list}    ${code_list}[${i}]
    END
    #数据库查询出来最终结果的交易链路，后续和接口的交易链路作对比
    Log    ${new_code_list}
    #获取开放接口token
    ${data}    设置变量    {"app_id":"${app_id}[${env}]","app_secret":"${app_secret}[${env}]"}
    ${response}    /open/v1/applications/tokens    ${data}
    ${Authorization}    设置变量    ${response.json()}[data][token]
    #查询交易链路接口
    ${data}    设置变量    {"delivery_model":3,"start_nodes":[{"supplier_code":"","purchase_subsidiary_code":"","store_code":"","country_Code":"","warehouse_code":"${start_warehouse}"}],"end_nodes":[{"warehouse_code":"","country_Code":"","store_code":"${end_store}","customer_code":""}],"stock_categories":[${stock_categories}]}
    ${response}    /open/v1/transaction-chains/queries    ${data}    ${Authorization}
    log    ${response.json()}
    #抓取接口返回的交易链路
    @{intf_code_list}    Create List
    ${intf_code_list}    Run Keyword If    ${response.json()}[code]==0    收集接口返回的交易链路    ${response}    ${intf_code_list}
    ...    ELSE    设置变量    ${intf_code_list}
    ${new_code_list}    Evaluate    sorted(${new_code_list})
    ${intf_code_list}    Evaluate    sorted(${intf_code_list})
    #Run Keyword If    ${MatchRule}==1    Should Be Equal As Strings    ${response.json()}[message]    success
    Should Be Equal    ${new_code_list}    ${intf_code_list}

本地仓到店关键字
    [Arguments]    ${start_warehouse}    ${end_store}    ${stock_categories}
    #仓库子公司关系转json
    ${warehouse_subsidiary_dict}    Evaluate    json.loads('''${warehouse_subsidiary}''')
    #查询是否存在匹配规则
    #@{result}    query    SELECT count(*) FROM fc_transaction_matching_rule tmr JOIN fc_transaction_matching_rule_delivery_node tmrd on tmr.id = tmrd.transaction_matching_rule_id where UNIX_TIMESTAMP()<tmr.end_time and UNIX_TIMESTAMP()>tmr.start_time and tmr.status=1 and tmrd.`start_node` = '${start_warehouse}' and tmrd.`end_node` = '${end_warehouse}' and `delivery_model` in (1);
    #${count}    设置变量    ${result}[0][0]
    #MatchRule=0则没有匹配规则，1则有
    #${MatchRule}    Set Variable If    ${count}==0    0    1
    #数仓获取门店对应的子公司
    @{result}    query    select entity_code from ods.ods_retail_biz_store_db_rt_store_info_rt where store_code='${end_store}';
    ...    alias=dw    #数仓的数据库查询要加alias=dw
    ${end_subsidiary}    设置变量    ${result}[0][0]
    log    ${warehouse_subsidiary_dict}
    ${start_subsidiary}    设置变量    ${warehouse_subsidiary_dict}[${start_warehouse}]

    @{start_subsidiary_list}    Create List
    @{end_subsidiary_list}    Create List    ${end_subsidiary}
    ${start_isList}    Evaluate    "${start_subsidiary}".startswith("[")
    ${end_isList}    Evaluate    "${end_subsidiary}".startswith("[")
    ${start_subsidiary_list}    Run Keyword If    ${start_isList}    Copy List    ${start_subsidiary}
    ...    ELSE    Create List    ${start_subsidiary}
    ${end_subsidiary_list}    Run Keyword If    ${end_isList}    Copy List    ${end_subsidiary}
    ...    ELSE    Create List    ${end_subsidiary}
    #去掉数据[]后续sql查询使用
    ${start_subsidiary_list}    Evaluate    "${start_subsidiary_list}".replace("[", "").replace("]", "")
    ${end_subsidiary_list}    Evaluate    "${end_subsidiary_list}".replace("[", "").replace("]", "")
    log    ${start_subsidiary_list}
    log    ${end_subsidiary_list}
    #查询是否存在交易链路
    @{result}    query    select count(*) from fc_transaction_chain_rule where shipping_subsidiary_code in (${start_subsidiary_list}) and receiving_subsidiary_code in (${end_subsidiary_list}) and UNIX_TIMESTAMP()<end_time and UNIX_TIMESTAMP()>start_time and status=1;
    ${length}    设置变量    ${result}[0][0]
    @{result}    query    select code,levels->'$[*].pricing_rule_id' from fc_transaction_chain_rule where shipping_subsidiary_code in (${start_subsidiary_list}) and receiving_subsidiary_code in (${end_subsidiary_list}) and UNIX_TIMESTAMP()<end_time and UNIX_TIMESTAMP()>start_time and status=1;
    @{code_list}    Create List
    @{price_rule_list}    Create List
    FOR    ${i}    IN RANGE    ${length}
        Append To List    ${code_list}    ${result}[${i}][0]
        Append To List    ${price_rule_list}    ${result}[${i}][1]
    END
    Log    ${code_list}
#    ${code_length}    Get Length    ${code_list}
#    Log    ${price_rule_list}
#    # 先转换为真实列表结构
#    ${cleaned} =    Evaluate    "${price_rule_list}".replace("[", "").replace("]", "").replace("'", "").replace(" ", "")
#    Log    ${cleaned}
#    @{items} =    Split String    ${cleaned}    separator=,
#    # 再展平嵌套列表
#    @{new_price_rule_list}    Create List
#    Append To List    ${new_price_rule_list}    @{items}
#    ${new_price_rule_list}    Evaluate    list(set(${new_price_rule_list}))
#    #去掉值为0的
#    Remove Values From List    ${new_price_rule_list}    0
#    Log    ${new_price_rule_list}
#    ${price_rule_list_length}    Get Length    ${new_price_rule_list}
#    #根据存货分类传惨决定查看定价规则SQL
#    @{NoMatch_id_list}    Create List    #对不上存货分类的定价规则id
#    FOR    ${i}    IN RANGE    ${price_rule_list_length}
#        ${origin_sql}    设置变量    select count(*) from fc_pricing_rule where id='${new_price_rule_list}[${i}]'
#        ${origin_sql}    Run Keyword If    '1' in '${stock_categories}'     设置变量    ${origin_sql} and calculation_rules like '%"stock_category": 1%'
#        ...    ELSE    设置变量    ${origin_sql}
#        ${origin_sql}    Run Keyword If    '2' in '${stock_categories}'     设置变量    ${origin_sql} and calculation_rules like '%"stock_category": 2%'
#        ...    ELSE    设置变量    ${origin_sql}
#        ${origin_sql}    Run Keyword If    '4' in '${stock_categories}'     设置变量    ${origin_sql} and calculation_rules like '%"stock_category": 4%'
#        ...    ELSE    设置变量    ${origin_sql}
#        Log    ${origin_sql}
#        @{result}    query    ${origin_sql}
#        ${price_count}    设置变量    ${result}[0][0]
#        Log    ${price_count}
#        Run Keyword If    ${price_count}==0    Append To List    ${NoMatch_id_list}    ${new_price_rule_list}[${i}]
#    END
#    Log    ${NoMatch_id_list}
#    ${NoMatch_id_list_len}    Get Length    ${NoMatch_id_list}
#    #确定查询交易链路时加的sql
#    ${add_sql}    设置变量     and levels REGEXP
#    FOR    ${i}    IN RANGE    ${NoMatch_id_list_len}
#        ${add_sql}    Run Keyword If    ${i}==0    设置变量    ${add_sql} '${NoMatch_id_list}[${i}]'
#        ...    ELSE    设置变量    ${add_sql}[:-1]|${NoMatch_id_list}[${i}]'
#        Log    ${add_sql}
#    END
#    Log    ${add_sql}
#    #如果没有不匹配的定价规则，则把add_sql设置为空
#    ${add_sql}    Run Keyword If    ${NoMatch_id_list_len}==0    设置变量    ${SPACE}
#    ...    ELSE    设置变量    ${add_sql}
#    #用没有匹配上的定价规则反查是哪个交易链路用到的，并去掉该交易链路，不会返回此交易链路
#    ${sql}    设置变量    ${SPACE}
#    ${new_code_list}    Copy List    ${code_list}
#    FOR    ${i}    IN RANGE    ${code_length}
#        Continue For Loop If    ${NoMatch_id_list_len}==0
#        ${sql}    设置变量     select count(*) from fc_transaction_chain_rule where code='${code_list}[${i}]' ${add_sql}
#        @{result}    query    ${sql}
#        ${count3}    设置变量    ${result}[0][0]
#        Run Keyword Unless    ${count3}==0    Remove Values From List    ${new_code_list}    ${code_list}[${i}]
#    END
#    #数据库查询出来最终结果的交易链路，后续和接口的交易链路作对比
#    Log    ${new_code_list}
    #获取开放接口token
    ${data}    设置变量    {"app_id":"${app_id}[${env}]","app_secret":"${app_secret}[${env}]"}
    ${response}    /open/v1/applications/tokens    ${data}
    ${Authorization}    设置变量    ${response.json()}[data][token]
    #查询交易链路接口
    ${data}    设置变量    {"delivery_model":4,"start_nodes":[{"supplier_code":"","purchase_subsidiary_code":"","store_code":"","country_Code":"","warehouse_code":"${start_warehouse}"}],"end_nodes":[{"warehouse_code":"","country_Code":"","store_code":"${end_store}","customer_code":""}],"stock_categories":[${stock_categories}]}
    ${response}    /open/v1/transaction-chains/queries    ${data}    ${Authorization}
    log    ${response.json()}
    #抓取接口返回的交易链路
    @{intf_code_list}    Create List
    ${intf_code_list}    Run Keyword If    ${response.json()}[code]==0    收集接口返回的交易链路    ${response}    ${intf_code_list}
    ...    ELSE    设置变量    ${intf_code_list}
    ${code_list}    Evaluate    sorted(${code_list})
    ${intf_code_list}    Evaluate    sorted(${intf_code_list})
    #Run Keyword If    ${MatchRule}==1    Should Be Equal As Strings    ${response.json()}[message]    success
    Should Be Equal    ${code_list}    ${intf_code_list}

跨境供应商直邮到仓关键字
    [Arguments]    ${start_supplier}    ${start_subsidiary}    ${end_warehouse}    ${stock_categories}
    #仓库子公司关系转json
    ${warehouse_subsidiary_dict}    Evaluate    json.loads('''${warehouse_subsidiary}''')
    #查询是否存在匹配规则
    @{result}    query    SELECT count(*) from fc_transaction_matching_rule tmr join fc_transaction_matching_rule_delivery_node tmrd on tmr.id = tmrd.transaction_matching_rule_id where tmr.delivery_model =5 and tmr.status=1 and UNIX_TIMESTAMP()<tmr.end_time and UNIX_TIMESTAMP()>tmr.start_time and tmrd.start_node in ('${start_supplier}','all') and tmrd.end_node='${end_warehouse}';
    ${count}    设置变量    ${result}[0][0]
    #MatchRule=0则没有匹配规则，1则有
    ${MatchRule}    Set Variable If    ${count}==0    0    1
    log    ${warehouse_subsidiary_dict}
    ${end_subsidiary}    设置变量    ${warehouse_subsidiary_dict}[${end_warehouse}]
    @{end_subsidiary_list}    Create List
    ${end_isList}    Evaluate    "${end_subsidiary}".startswith("[")
    ${end_subsidiary_list}    Run Keyword If    ${end_isList}    Copy List    ${end_subsidiary}
    ...    ELSE    Create List    ${end_subsidiary}
    #去掉数据[]后续sql查询使用
    ${end_subsidiary_list}    Evaluate    "${end_subsidiary_list}".replace("[", "").replace("]", "")
    log    ${start_subsidiary}
    log    ${end_subsidiary_list}
    #根据存货分类传惨决定查看匹配规则SQL
    ${tmr_sql}    设置变量    SELECT tmr.rule_configs->'$[*].tcr_ids',tmrd.start_node ,tmrd.end_node from fc_transaction_matching_rule tmr join fc_transaction_matching_rule_delivery_node tmrd on tmr.id = tmrd.transaction_matching_rule_id where tmr.delivery_model =5 and tmr.status=1 and UNIX_TIMESTAMP()<tmr.end_time and UNIX_TIMESTAMP()>tmr.start_time and tmrd.start_node in ('${start_supplier}','all') and tmrd.end_node='${end_warehouse}'
    #${tmr_sql}    Run Keyword If    '1' in '${stock_categories}'     设置变量    ${tmr_sql} and tmr.rule_configs like '%存货分类 等于 商品%'
    #...    ELSE    设置变量    ${tmr_sql}
    #${tmr_sql}    Run Keyword If    '2' in '${stock_categories}'     设置变量    ${tmr_sql} and tmr.rule_configs like '%存货分类 等于 物料%'
    #...    ELSE    设置变量    ${tmr_sql}
    #${tmr_sql}    Run Keyword If    '4' in '${stock_categories}'     设置变量    ${tmr_sql} and tmr.rule_configs like '%存货分类 等于 陈列品%'
    #...    ELSE    设置变量    ${tmr_sql}
    #Log    ${tmr_sql}
    @{result}    query    ${tmr_sql}
    FOR    ${i}    IN RANGE    ${count}
        ${tcr_ids}    Set Variable If    ${i}==0    ${result}[${i}][0]    ${tcr_ids},${result}[${i}][0]
        #${tcr_ids}    设置变量    ${tcr_ids},${result}[${i}][0]
    END    
    ${transaction_id}    Run Keyword If    ${count}!=0    Evaluate    "${tcr_ids}".replace("[", "").replace("]", "")
    ...    ELSE    设置变量    0
    Log    ${transaction_id}
    #查询是否存在交易链路
    @{result}    query    select count(*) from fc_transaction_chain_rule where shipping_subsidiary_code in ('${start_subsidiary}') and UNIX_TIMESTAMP()<end_time and UNIX_TIMESTAMP()>start_time and status=1 and id in (${transaction_id});
    ${length}    设置变量    ${result}[0][0]
    @{result}    query    select code,levels->'$[*].pricing_rule_id' from fc_transaction_chain_rule where shipping_subsidiary_code in ('${start_subsidiary}') and UNIX_TIMESTAMP()<end_time and UNIX_TIMESTAMP()>start_time and status=1 and id in (${transaction_id});
    @{code_list}    Create List
    @{price_rule_list}    Create List
    FOR    ${i}    IN RANGE    ${length}
        Append To List    ${code_list}    ${result}[${i}][0]
        Append To List    ${price_rule_list}    ${result}[${i}][1]
    END
    Log    ${code_list}
    #获取开放接口token
    ${data}    设置变量    {"app_id":"${app_id}[${env}]","app_secret":"${app_secret}[${env}]"}
    ${response}    /open/v1/applications/tokens    ${data}
    ${Authorization}    设置变量    ${response.json()}[data][token]
    #查询交易链路接口
    ${data}    设置变量    {"delivery_model":5,"start_nodes":[{"supplier_code":"${start_supplier}","purchase_subsidiary_code":"${start_subsidiary}","store_code":"","country_Code":"","warehouse_code":""}],"end_nodes":[{"warehouse_code":"${end_warehouse}","country_Code":"","store_code":"","customer_code":""}],"stock_categories":[${stock_categories}]}
    ${response}    /open/v1/transaction-chains/queries    ${data}    ${Authorization}
    log    ${response.json()}
    #抓取接口返回的交易链路
    @{intf_code_list}    Create List
    ${intf_code_list}    Run Keyword If    ${response.json()}[code]==0    收集接口返回的交易链路    ${response}    ${intf_code_list}
    ...    ELSE    设置变量    ${intf_code_list}
    ${code_list}    Evaluate    sorted(${code_list})
    ${intf_code_list}    Evaluate    sorted(${intf_code_list})
    Run Keyword If    ${MatchRule}==1    Should Be Equal As Strings    ${response.json()}[message]    success
    Should Be Equal    ${code_list}    ${intf_code_list}

本地供应商直邮到仓关键字
    [Arguments]    ${start_supplier}    ${start_subsidiary}    ${end_warehouse}    ${stock_categories}
    #仓库子公司关系转json
    ${warehouse_subsidiary_dict}    Evaluate    json.loads('''${warehouse_subsidiary}''')
    #查询是否存在匹配规则
    @{result}    query    SELECT count(*) from fc_transaction_matching_rule tmr join fc_transaction_matching_rule_delivery_node tmrd on tmr.id = tmrd.transaction_matching_rule_id where tmr.delivery_model =6 and tmr.status=1 and UNIX_TIMESTAMP()<tmr.end_time and UNIX_TIMESTAMP()>tmr.start_time and tmrd.start_node in ('${start_supplier}','all') and tmrd.end_node='${end_warehouse}';
    ${count}    设置变量    ${result}[0][0]
    #MatchRule=0则没有匹配规则，1则有
    ${MatchRule}    Set Variable If    ${count}==0    0    1
    log    ${warehouse_subsidiary_dict}
    ${end_subsidiary}    设置变量    ${warehouse_subsidiary_dict}[${end_warehouse}]
    @{end_subsidiary_list}    Create List
    ${end_isList}    Evaluate    "${end_subsidiary}".startswith("[")
    ${end_subsidiary_list}    Run Keyword If    ${end_isList}    Copy List    ${end_subsidiary}
    ...    ELSE    Create List    ${end_subsidiary}
    #去掉数据[]后续sql查询使用
    ${end_subsidiary_list}    Evaluate    "${end_subsidiary_list}".replace("[", "").replace("]", "")
    log    ${start_subsidiary}
    log    ${end_subsidiary_list}
    #根据存货分类传惨决定查看匹配规则SQL
    ${tmr_sql}    设置变量    SELECT tmr.rule_configs->'$[*].tcr_ids',tmrd.start_node ,tmrd.end_node from fc_transaction_matching_rule tmr join fc_transaction_matching_rule_delivery_node tmrd on tmr.id = tmrd.transaction_matching_rule_id where tmr.delivery_model =6 and tmr.status=1 and UNIX_TIMESTAMP()<tmr.end_time and UNIX_TIMESTAMP()>tmr.start_time and tmrd.start_node in ('${start_supplier}','all') and tmrd.end_node='${end_warehouse}'
    #${tmr_sql}    Run Keyword If    '1' in '${stock_categories}'     设置变量    ${tmr_sql} and tmr.rule_configs like '%存货分类 等于 商品%'
    #...    ELSE    设置变量    ${tmr_sql}
    #${tmr_sql}    Run Keyword If    '2' in '${stock_categories}'     设置变量    ${tmr_sql} and tmr.rule_configs like '%存货分类 等于 物料%'
    #...    ELSE    设置变量    ${tmr_sql}
    #${tmr_sql}    Run Keyword If    '4' in '${stock_categories}'     设置变量    ${tmr_sql} and tmr.rule_configs like '%存货分类 等于 陈列品%'
    #...    ELSE    设置变量    ${tmr_sql}
    #Log    ${tmr_sql}
    @{result}    query    ${tmr_sql}
    FOR    ${i}    IN RANGE    ${count}
        ${tcr_ids}    Set Variable If    ${i}==0    ${result}[${i}][0]    ${tcr_ids},${result}[${i}][0]
        #${tcr_ids}    设置变量    ${tcr_ids},${result}[${i}][0]
    END
    ${transaction_id}    Run Keyword If    ${count}!=0    Evaluate    "${tcr_ids}".replace("[", "").replace("]", "")
    ...    ELSE    设置变量    0
    Log    ${transaction_id}
    #查询是否存在交易链路
    @{result}    query    select count(*) from fc_transaction_chain_rule where shipping_subsidiary_code in ('${start_subsidiary}') and UNIX_TIMESTAMP()<end_time and UNIX_TIMESTAMP()>start_time and status=1 and id in (${transaction_id});
    ${length}    设置变量    ${result}[0][0]
    @{result}    query    select code,levels->'$[*].pricing_rule_id' from fc_transaction_chain_rule where shipping_subsidiary_code in ('${start_subsidiary}') and UNIX_TIMESTAMP()<end_time and UNIX_TIMESTAMP()>start_time and status=1 and id in (${transaction_id});
    @{code_list}    Create List
    @{price_rule_list}    Create List
    FOR    ${i}    IN RANGE    ${length}
        Append To List    ${code_list}    ${result}[${i}][0]
        Append To List    ${price_rule_list}    ${result}[${i}][1]
    END
    Log    ${code_list}
    #获取开放接口token
    ${data}    设置变量    {"app_id":"${app_id}[${env}]","app_secret":"${app_secret}[${env}]"}
    ${response}    /open/v1/applications/tokens    ${data}
    ${Authorization}    设置变量    ${response.json()}[data][token]
    #查询交易链路接口
    ${data}    设置变量    {"delivery_model":6,"start_nodes":[{"supplier_code":"${start_supplier}","purchase_subsidiary_code":"${start_subsidiary}","store_code":"","country_Code":"","warehouse_code":""}],"end_nodes":[{"warehouse_code":"${end_warehouse}","country_Code":"","store_code":"","customer_code":""}],"stock_categories":[${stock_categories}]}
    ${response}    /open/v1/transaction-chains/queries    ${data}    ${Authorization}
    log    ${response.json()}
    #抓取接口返回的交易链路
    @{intf_code_list}    Create List
    ${intf_code_list}    Run Keyword If    ${response.json()}[code]==0    收集接口返回的交易链路    ${response}    ${intf_code_list}
    ...    ELSE    设置变量    ${intf_code_list}
    ${code_list}    Evaluate    sorted(${code_list})
    ${intf_code_list}    Evaluate    sorted(${intf_code_list})
    Run Keyword If    ${MatchRule}==1    Should Be Equal As Strings    ${response.json()}[message]    success
    Should Be Equal    ${code_list}    ${intf_code_list}

跨境供应商直邮到店关键字
    [Arguments]    ${start_supplier}    ${start_subsidiary}    ${end_store}    ${stock_categories}
    #仓库子公司关系转json
    ${warehouse_subsidiary_dict}    Evaluate    json.loads('''${warehouse_subsidiary}''')
    #数仓获取门店对应的子公司
    @{result}    query    select entity_code from ods.ods_retail_biz_store_db_rt_store_info_rt where store_code='${end_store}';
    ...    alias=dw    #数仓的数据库查询要加alias=dw
    ${end_subsidiary}    设置变量    ${result}[0][0]
    #查询是否存在匹配规则
    @{result}    query    SELECT count(*) from fc_transaction_matching_rule tmr join fc_transaction_matching_rule_delivery_node tmrd on tmr.id = tmrd.transaction_matching_rule_id where tmr.delivery_model =7 and tmr.status=1 and UNIX_TIMESTAMP()<tmr.end_time and UNIX_TIMESTAMP()>tmr.start_time and tmrd.start_node in ('${start_supplier}','all') and tmrd.end_node='${end_subsidiary}';
    ${count}    设置变量    ${result}[0][0]
    #MatchRule=0则没有匹配规则，1则有
    ${MatchRule}    Set Variable If    ${count}==0    0    1
    #根据存货分类传惨决定查看匹配规则SQL
    ${tmr_sql}    设置变量    SELECT tmr.rule_configs->'$[*].tcr_ids',tmrd.start_node ,tmrd.end_node from fc_transaction_matching_rule tmr join fc_transaction_matching_rule_delivery_node tmrd on tmr.id = tmrd.transaction_matching_rule_id where tmr.delivery_model =7 and tmr.status=1 and UNIX_TIMESTAMP()<tmr.end_time and UNIX_TIMESTAMP()>tmr.start_time and tmrd.start_node in ('${start_supplier}','all') and tmrd.end_node='${end_subsidiary}'
    #${tmr_sql}    Run Keyword If    '1' in '${stock_categories}'     设置变量    ${tmr_sql} and tmr.rule_configs like '%存货分类 等于 商品%'
    #...    ELSE    设置变量    ${tmr_sql}
    #${tmr_sql}    Run Keyword If    '2' in '${stock_categories}'     设置变量    ${tmr_sql} and tmr.rule_configs like '%存货分类 等于 物料%'
    #...    ELSE    设置变量    ${tmr_sql}
    #${tmr_sql}    Run Keyword If    '4' in '${stock_categories}'     设置变量    ${tmr_sql} and tmr.rule_configs like '%存货分类 等于 陈列品%'
    #...    ELSE    设置变量    ${tmr_sql}
    #Log    ${tmr_sql}
    @{result}    query    ${tmr_sql}
    FOR    ${i}    IN RANGE    ${count}
        ${tcr_ids}    Set Variable If    ${i}==0    ${result}[${i}][0]    ${tcr_ids},${result}[${i}][0]
        #${tcr_ids}    设置变量    ${tcr_ids},${result}[${i}][0]
    END
    ${transaction_id}    Run Keyword If    ${count}!=0    Evaluate    "${tcr_ids}".replace("[", "").replace("]", "")
    ...    ELSE    设置变量    0
    Log    ${transaction_id}
    #查询是否存在交易链路
    @{result}    query    select count(*) from fc_transaction_chain_rule where shipping_subsidiary_code in ('${start_subsidiary}') and UNIX_TIMESTAMP()<end_time and UNIX_TIMESTAMP()>start_time and status=1 and id in (${transaction_id});
    ${length}    设置变量    ${result}[0][0]
    @{result}    query    select code,levels->'$[*].pricing_rule_id' from fc_transaction_chain_rule where shipping_subsidiary_code in ('${start_subsidiary}') and UNIX_TIMESTAMP()<end_time and UNIX_TIMESTAMP()>start_time and status=1 and id in (${transaction_id});
    @{code_list}    Create List
    @{price_rule_list}    Create List
    FOR    ${i}    IN RANGE    ${length}
        Append To List    ${code_list}    ${result}[${i}][0]
        Append To List    ${price_rule_list}    ${result}[${i}][1]
    END
    Log    ${code_list}
    #获取开放接口token
    ${data}    设置变量    {"app_id":"${app_id}[${env}]","app_secret":"${app_secret}[${env}]"}
    ${response}    /open/v1/applications/tokens    ${data}
    ${Authorization}    设置变量    ${response.json()}[data][token]
    #查询交易链路接口
    ${data}    设置变量    {"delivery_model":7,"start_nodes":[{"supplier_code":"${start_supplier}","purchase_subsidiary_code":"${start_subsidiary}","store_code":"","country_Code":"","warehouse_code":""}],"end_nodes":[{"warehouse_code":"","country_Code":"","store_code":"${end_store}","customer_code":""}],"stock_categories":[${stock_categories}]}
    ${response}    /open/v1/transaction-chains/queries    ${data}    ${Authorization}
    log    ${response.json()}
    #抓取接口返回的交易链路
    @{intf_code_list}    Create List
    ${intf_code_list}    Run Keyword If    ${response.json()}[code]==0    收集接口返回的交易链路    ${response}    ${intf_code_list}
    ...    ELSE    设置变量    ${intf_code_list}
    ${code_list}    Evaluate    sorted(${code_list})
    ${intf_code_list}    Evaluate    sorted(${intf_code_list})
    #Run Keyword If    ${MatchRule}==1    Should Be Equal As Strings    ${response.json()}[message]    success
    Should Be Equal    ${code_list}    ${intf_code_list}

本地供应商直邮到店关键字
    [Arguments]    ${start_supplier}    ${start_subsidiary}    ${end_store}    ${stock_categories}
    #仓库子公司关系转json
    ${warehouse_subsidiary_dict}    Evaluate    json.loads('''${warehouse_subsidiary}''')
    #数仓获取门店对应的子公司
    @{result}    query    select entity_code from ods.ods_retail_biz_store_db_rt_store_info_rt where store_code='${end_store}';
    ...    alias=dw    #数仓的数据库查询要加alias=dw
    ${end_subsidiary}    设置变量    ${result}[0][0]
    #查询是否存在匹配规则
    @{result}    query    SELECT count(*) from fc_transaction_matching_rule tmr join fc_transaction_matching_rule_delivery_node tmrd on tmr.id = tmrd.transaction_matching_rule_id where tmr.delivery_model =8 and tmr.status=1 and UNIX_TIMESTAMP()<tmr.end_time and UNIX_TIMESTAMP()>tmr.start_time and tmrd.start_node in ('${start_supplier}','all') and tmrd.end_node='${end_subsidiary}';
    ${count}    设置变量    ${result}[0][0]
    #MatchRule=0则没有匹配规则，1则有
    ${MatchRule}    Set Variable If    ${count}==0    0    1
    #根据存货分类传惨决定查看匹配规则SQL
    ${tmr_sql}    设置变量    SELECT tmr.rule_configs->'$[*].tcr_ids',tmrd.start_node ,tmrd.end_node from fc_transaction_matching_rule tmr join fc_transaction_matching_rule_delivery_node tmrd on tmr.id = tmrd.transaction_matching_rule_id where tmr.delivery_model =8 and tmr.status=1 and UNIX_TIMESTAMP()<tmr.end_time and UNIX_TIMESTAMP()>tmr.start_time and tmrd.start_node in ('${start_supplier}','all') and tmrd.end_node='${end_subsidiary}'
    #${tmr_sql}    Run Keyword If    '1' in '${stock_categories}'     设置变量    ${tmr_sql} and tmr.rule_configs like '%存货分类 等于 商品%'
    #...    ELSE    设置变量    ${tmr_sql}
    #${tmr_sql}    Run Keyword If    '2' in '${stock_categories}'     设置变量    ${tmr_sql} and tmr.rule_configs like '%存货分类 等于 物料%'
    #...    ELSE    设置变量    ${tmr_sql}
    #${tmr_sql}    Run Keyword If    '4' in '${stock_categories}'     设置变量    ${tmr_sql} and tmr.rule_configs like '%存货分类 等于 陈列品%'
    #...    ELSE    设置变量    ${tmr_sql}
    #Log    ${tmr_sql}
    @{result}    query    ${tmr_sql}
    FOR    ${i}    IN RANGE    ${count}
        ${tcr_ids}    Set Variable If    ${i}==0    ${result}[${i}][0]    ${tcr_ids},${result}[${i}][0]
        #${tcr_ids}    设置变量    ${tcr_ids},${result}[${i}][0]
    END
    ${transaction_id}    Run Keyword If    ${count}!=0    Evaluate    "${tcr_ids}".replace("[", "").replace("]", "")
    ...    ELSE    设置变量    0
    Log    ${transaction_id}
    #查询是否存在交易链路
    @{result}    query    select count(*) from fc_transaction_chain_rule where shipping_subsidiary_code in ('${start_subsidiary}') and UNIX_TIMESTAMP()<end_time and UNIX_TIMESTAMP()>start_time and status=1 and id in (${transaction_id});
    ${length}    设置变量    ${result}[0][0]
    @{result}    query    select code,levels->'$[*].pricing_rule_id' from fc_transaction_chain_rule where shipping_subsidiary_code in ('${start_subsidiary}') and UNIX_TIMESTAMP()<end_time and UNIX_TIMESTAMP()>start_time and status=1 and id in (${transaction_id});
    @{code_list}    Create List
    @{price_rule_list}    Create List
    FOR    ${i}    IN RANGE    ${length}
        Append To List    ${code_list}    ${result}[${i}][0]
        Append To List    ${price_rule_list}    ${result}[${i}][1]
    END
    Log    ${code_list}
    #获取开放接口token
    ${data}    设置变量    {"app_id":"${app_id}[${env}]","app_secret":"${app_secret}[${env}]"}
    ${response}    /open/v1/applications/tokens    ${data}
    ${Authorization}    设置变量    ${response.json()}[data][token]
    #查询交易链路接口
    ${data}    设置变量    {"delivery_model":8,"start_nodes":[{"supplier_code":"${start_supplier}","purchase_subsidiary_code":"${start_subsidiary}","store_code":"","country_Code":"","warehouse_code":""}],"end_nodes":[{"warehouse_code":"","country_Code":"","store_code":"${end_store}","customer_code":""}],"stock_categories":[${stock_categories}]}
    ${response}    /open/v1/transaction-chains/queries    ${data}    ${Authorization}
    log    ${response.json()}
    #抓取接口返回的交易链路
    @{intf_code_list}    Create List
    ${intf_code_list}    Run Keyword If    ${response.json()}[code]==0    收集接口返回的交易链路    ${response}    ${intf_code_list}
    ...    ELSE    设置变量    ${intf_code_list}
    ${code_list}    Evaluate    sorted(${code_list})
    ${intf_code_list}    Evaluate    sorted(${intf_code_list})
    #Run Keyword If    ${MatchRule}==1    Should Be Equal As Strings    ${response.json()}[message]    success
    Should Be Equal    ${code_list}    ${intf_code_list}

国到国关键字
    [Arguments]    ${start_country}    ${end_country}    ${stock_categories}
    #仓库子公司关系转json
    #${warehouse_subsidiary_dict}    Evaluate    json.loads('''${warehouse_subsidiary}''')
    #查询是否存在匹配规则
    @{result}    query    SELECT count(*) from fc_transaction_matching_rule tmr join fc_transaction_matching_rule_delivery_node tmrd on tmr.id = tmrd.transaction_matching_rule_id where tmr.delivery_model =9 and tmr.status=1 and UNIX_TIMESTAMP()<tmr.end_time and UNIX_TIMESTAMP()>tmr.start_time and tmrd.start_node='${start_country}' and tmrd.end_node='${end_country}';
    ${count}    设置变量    ${result}[0][0]
    #MatchRule=0则没有匹配规则，1则有
    ${MatchRule}    Set Variable If    ${count}==0    0    1
    #根据存货分类传惨决定查看匹配规则SQL
    ${tmr_sql}    设置变量    SELECT tmr.rule_configs->'$[*].tcr_ids',tmrd.start_node ,tmrd.end_node from fc_transaction_matching_rule tmr join fc_transaction_matching_rule_delivery_node tmrd on tmr.id = tmrd.transaction_matching_rule_id where tmr.delivery_model =9 and tmr.status=1 and UNIX_TIMESTAMP()<tmr.end_time and UNIX_TIMESTAMP()>tmr.start_time and tmrd.start_node ='${start_country}' and tmrd.end_node='${end_country}'
    #${tmr_sql}    Run Keyword If    '1' in '${stock_categories}'     设置变量    ${tmr_sql} and tmr.rule_configs like '%存货分类 等于 商品%'
    #...    ELSE    设置变量    ${tmr_sql}
    #${tmr_sql}    Run Keyword If    '2' in '${stock_categories}'     设置变量    ${tmr_sql} and tmr.rule_configs like '%存货分类 等于 物料%'
    #...    ELSE    设置变量    ${tmr_sql}
    #${tmr_sql}    Run Keyword If    '4' in '${stock_categories}'     设置变量    ${tmr_sql} and tmr.rule_configs like '%存货分类 等于 陈列品%'
    #...    ELSE    设置变量    ${tmr_sql}
    #Log    ${tmr_sql}
    @{result}    query    ${tmr_sql}
    FOR    ${i}    IN RANGE    ${count}
        ${tcr_ids}    Set Variable If    ${i}==0    ${result}[${i}][0]    ${tcr_ids},${result}[${i}][0]
        #${tcr_ids}    设置变量    ${tcr_ids},${result}[${i}][0]
    END
    ${transaction_id}    Run Keyword If    ${count}!=0    Evaluate    "${tcr_ids}".replace("[", "").replace("]", "")
    ...    ELSE    设置变量    0
    Log    ${transaction_id}
    #查询是否存在交易链路
    @{result}    query    select count(*) from fc_transaction_chain_rule where UNIX_TIMESTAMP()<end_time and UNIX_TIMESTAMP()>start_time and status=1 and id in (${transaction_id});
    ${length}    设置变量    ${result}[0][0]
    @{result}    query    select code,levels->'$[*].pricing_rule_id' from fc_transaction_chain_rule where UNIX_TIMESTAMP()<end_time and UNIX_TIMESTAMP()>start_time and status=1 and id in (${transaction_id});
    @{code_list}    Create List
    @{price_rule_list}    Create List
    FOR    ${i}    IN RANGE    ${length}
        Append To List    ${code_list}    ${result}[${i}][0]
        Append To List    ${price_rule_list}    ${result}[${i}][1]
    END
    Log    ${code_list}
    #获取开放接口token
    ${data}    设置变量    {"app_id":"${app_id}[${env}]","app_secret":"${app_secret}[${env}]"}
    ${response}    /open/v1/applications/tokens    ${data}
    ${Authorization}    设置变量    ${response.json()}[data][token]
    #查询交易链路接口
    ${data}    设置变量    {"delivery_model":9,"start_nodes":[{"supplier_code":"","purchase_subsidiary_code":"","store_code":"","country_Code":"${start_country}","warehouse_code":""}],"end_nodes":[{"warehouse_code":"","country_Code":"${end_country}","store_code":"","customer_code":""}],"stock_categories":[${stock_categories}]}
    ${response}    /open/v1/transaction-chains/queries    ${data}    ${Authorization}
    log    ${response.json()}
    #抓取接口返回的交易链路
    @{intf_code_list}    Create List
    ${intf_code_list}    Run Keyword If    ${response.json()}[code]==0    收集接口返回的交易链路    ${response}    ${intf_code_list}
    ...    ELSE    设置变量    ${intf_code_list}
    ${code_list}    Evaluate    sorted(${code_list})
    ${intf_code_list}    Evaluate    sorted(${intf_code_list})
    #Run Keyword If    ${MatchRule}==1    Should Be Equal As Strings    ${response.json()}[message]    success
    Should Be Equal    ${code_list}    ${intf_code_list}

仓到终端关键字
    [Arguments]    ${start_warehouse}    ${stock_categories}
    #仓库子公司关系转json
    ${warehouse_subsidiary_dict}    Evaluate    json.loads('''${warehouse_subsidiary}''')
    #查询是否存在匹配规则
    @{result}    query    SELECT count(*) from fc_transaction_matching_rule tmr join fc_transaction_matching_rule_delivery_node tmrd on tmr.id = tmrd.transaction_matching_rule_id where tmr.delivery_model =10 and tmr.status=1 and UNIX_TIMESTAMP()<tmr.end_time and UNIX_TIMESTAMP()>tmr.start_time and tmrd.start_node='${start_warehouse}';
    ${count}    设置变量    ${result}[0][0]
    #MatchRule=0则没有匹配规则，1则有
    ${MatchRule}    Set Variable If    ${count}==0    0    1
    #根据存货分类传惨决定查看匹配规则SQL
    ${tmr_sql}    设置变量    SELECT tmr.rule_configs->'$[*].tcr_ids',tmrd.start_node ,tmrd.end_node from fc_transaction_matching_rule tmr join fc_transaction_matching_rule_delivery_node tmrd on tmr.id = tmrd.transaction_matching_rule_id where tmr.delivery_model =10 and tmr.status=1 and UNIX_TIMESTAMP()<tmr.end_time and UNIX_TIMESTAMP()>tmr.start_time and tmrd.start_node='${start_warehouse}';
    #${tmr_sql}    Run Keyword If    '1' in '${stock_categories}'     设置变量    ${tmr_sql} and tmr.rule_configs like '%存货分类 等于 商品%'
    #...    ELSE    设置变量    ${tmr_sql}
    #${tmr_sql}    Run Keyword If    '2' in '${stock_categories}'     设置变量    ${tmr_sql} and tmr.rule_configs like '%存货分类 等于 物料%'
    #...    ELSE    设置变量    ${tmr_sql}
    #${tmr_sql}    Run Keyword If    '4' in '${stock_categories}'     设置变量    ${tmr_sql} and tmr.rule_configs like '%存货分类 等于 陈列品%'
    #...    ELSE    设置变量    ${tmr_sql}
    #Log    ${tmr_sql}
    @{result}    query    ${tmr_sql}
    FOR    ${i}    IN RANGE    ${count}
        ${tcr_ids}    Set Variable If    ${i}==0    ${result}[${i}][0]    ${tcr_ids},${result}[${i}][0]
        #${tcr_ids}    设置变量    ${tcr_ids},${result}[${i}][0]
    END
    ${transaction_id}    Run Keyword If    ${count}!=0    Evaluate    "${tcr_ids}".replace("[", "").replace("]", "")
    ...    ELSE    设置变量    0
    Log    ${transaction_id}
    #查询是否存在交易链路
    @{result}    query    select count(*) from fc_transaction_chain_rule where UNIX_TIMESTAMP()<end_time and UNIX_TIMESTAMP()>start_time and status=1 and id in (${transaction_id});
    ${length}    设置变量    ${result}[0][0]
    @{result}    query    select code,levels->'$[*].pricing_rule_id' from fc_transaction_chain_rule where UNIX_TIMESTAMP()<end_time and UNIX_TIMESTAMP()>start_time and status=1 and id in (${transaction_id});
    @{code_list}    Create List
    @{price_rule_list}    Create List
    FOR    ${i}    IN RANGE    ${length}
        Append To List    ${code_list}    ${result}[${i}][0]
        Append To List    ${price_rule_list}    ${result}[${i}][1]
    END
    Log    ${code_list}
    #获取开放接口token
    ${data}    设置变量    {"app_id":"${app_id}[${env}]","app_secret":"${app_secret}[${env}]"}
    ${response}    /open/v1/applications/tokens    ${data}
    ${Authorization}    设置变量    ${response.json()}[data][token]
    #查询交易链路接口
    ${data}    设置变量    {"delivery_model":10,"start_nodes":[{"supplier_code":"","purchase_subsidiary_code":"","store_code":"","country_Code":"","warehouse_code":"${start_warehouse}"}],"end_nodes":[{"warehouse_code":"","country_Code":"","store_code":"","customer_code":""}],"stock_categories":[${stock_categories}]}
    ${response}    /open/v1/transaction-chains/queries    ${data}    ${Authorization}
    log    ${response.json()}
    #抓取接口返回的交易链路
    @{intf_code_list}    Create List
    ${intf_code_list}    Run Keyword If    ${response.json()}[code]==0    收集接口返回的交易链路    ${response}    ${intf_code_list}
    ...    ELSE    设置变量    ${intf_code_list}
    ${code_list}    Evaluate    sorted(${code_list})
    ${intf_code_list}    Evaluate    sorted(${intf_code_list})
    #Run Keyword If    ${MatchRule}==1    Should Be Equal As Strings    ${response.json()}[message]    success
    Should Be Equal    ${code_list}    ${intf_code_list}

本地店到店关键字
    [Arguments]    ${start_store}    ${end_store}    ${stock_categories}
    #仓库子公司关系转json
    #${warehouse_subsidiary_dict}    Evaluate    json.loads('''${warehouse_subsidiary}''')
    #数仓获取门店对应的子公司
    @{result}    query    select entity_code from ods.ods_retail_biz_store_db_rt_store_info_rt where store_code='${start_store}';
    ...    alias=dw    #数仓的数据库查询要加alias=dw
    ${start_subsidiary}    设置变量    ${result}[0][0]
    @{result}    query    select entity_code from ods.ods_retail_biz_store_db_rt_store_info_rt where store_code='${end_store}';
    ...    alias=dw    #数仓的数据库查询要加alias=dw
    ${end_subsidiary}    设置变量    ${result}[0][0]
    #查询是否存在匹配规则
    @{result}    query    SELECT count(*) from fc_transaction_matching_rule tmr join fc_transaction_matching_rule_delivery_node tmrd on tmr.id = tmrd.transaction_matching_rule_id where tmr.delivery_model =11 and tmr.status=1 and UNIX_TIMESTAMP()<tmr.end_time and UNIX_TIMESTAMP()>tmr.start_time and tmrd.start_node='${start_subsidiary}' and tmrd.end_node='${end_subsidiary}';
    ${count}    设置变量    ${result}[0][0]
    #MatchRule=0则没有匹配规则，1则有
    ${MatchRule}    Set Variable If    ${count}==0    0    1
    #根据存货分类传惨决定查看匹配规则SQL
    ${tmr_sql}    设置变量    SELECT tmr.rule_configs->'$[*].tcr_ids',tmrd.start_node ,tmrd.end_node from fc_transaction_matching_rule tmr join fc_transaction_matching_rule_delivery_node tmrd on tmr.id = tmrd.transaction_matching_rule_id where tmr.delivery_model =11 and tmr.status=1 and UNIX_TIMESTAMP()<tmr.end_time and UNIX_TIMESTAMP()>tmr.start_time and tmrd.start_node='${start_subsidiary}' and tmrd.end_node='${end_subsidiary}';
    #${tmr_sql}    Run Keyword If    '1' in '${stock_categories}'     设置变量    ${tmr_sql} and tmr.rule_configs like '%存货分类 等于 商品%'
    #...    ELSE    设置变量    ${tmr_sql}
    #${tmr_sql}    Run Keyword If    '2' in '${stock_categories}'     设置变量    ${tmr_sql} and tmr.rule_configs like '%存货分类 等于 物料%'
    #...    ELSE    设置变量    ${tmr_sql}
    #${tmr_sql}    Run Keyword If    '4' in '${stock_categories}'     设置变量    ${tmr_sql} and tmr.rule_configs like '%存货分类 等于 陈列品%'
    #...    ELSE    设置变量    ${tmr_sql}
    #Log    ${tmr_sql}
    @{result}    query    ${tmr_sql}
    FOR    ${i}    IN RANGE    ${count}
        ${tcr_ids}    Set Variable If    ${i}==0    ${result}[${i}][0]    ${tcr_ids},${result}[${i}][0]
        #${tcr_ids}    设置变量    ${tcr_ids},${result}[${i}][0]
    END
    ${transaction_id}    Run Keyword If    ${count}!=0    Evaluate    "${tcr_ids}".replace("[", "").replace("]", "")
    ...    ELSE    设置变量    0
    Log    ${transaction_id}
    #查询是否存在交易链路
    @{result}    query    select count(*) from fc_transaction_chain_rule where UNIX_TIMESTAMP()<end_time and UNIX_TIMESTAMP()>start_time and status=1 and id in (${transaction_id});
    ${length}    设置变量    ${result}[0][0]
    @{result}    query    select code,levels->'$[*].pricing_rule_id' from fc_transaction_chain_rule where UNIX_TIMESTAMP()<end_time and UNIX_TIMESTAMP()>start_time and status=1 and id in (${transaction_id});
    @{code_list}    Create List
    @{price_rule_list}    Create List
    FOR    ${i}    IN RANGE    ${length}
        Append To List    ${code_list}    ${result}[${i}][0]
        Append To List    ${price_rule_list}    ${result}[${i}][1]
    END
    Log    ${code_list}
    #获取开放接口token
    ${data}    设置变量    {"app_id":"${app_id}[${env}]","app_secret":"${app_secret}[${env}]"}
    ${response}    /open/v1/applications/tokens    ${data}
    ${Authorization}    设置变量    ${response.json()}[data][token]
    #查询交易链路接口
    ${data}    设置变量    {"delivery_model":11,"start_nodes":[{"supplier_code":"","purchase_subsidiary_code":"","store_code":"${start_store}","country_Code":"","warehouse_code":""}],"end_nodes":[{"warehouse_code":"","country_Code":"","store_code":"${end_store}","customer_code":""}],"stock_categories":[${stock_categories}]}
    ${response}    /open/v1/transaction-chains/queries    ${data}    ${Authorization}
    log    ${response.json()}
    #抓取接口返回的交易链路
    @{intf_code_list}    Create List
    ${intf_code_list}    Run Keyword If    ${response.json()}[code]==0    收集接口返回的交易链路    ${response}    ${intf_code_list}
    ...    ELSE    设置变量    ${intf_code_list}
    ${code_list}    Evaluate    sorted(${code_list})
    ${intf_code_list}    Evaluate    sorted(${intf_code_list})
    #Run Keyword If    ${MatchRule}==1    Should Be Equal As Strings    ${response.json()}[message]    success
    Should Be Equal    ${code_list}    ${intf_code_list}

跨境供应商到客关键字
    [Arguments]    ${start_supplier}    ${start_subsidiary}    ${end_customer}    ${stock_categories}
    #仓库子公司关系转json
    ${warehouse_subsidiary_dict}    Evaluate    json.loads('''${warehouse_subsidiary}''')
    #数仓获取门店对应的子公司
    @{result}    query    select subject_code from dim.dim_retail_public_sc_customer_df where customer_code='${end_customer}';
    ...    alias=dw    #数仓的数据库查询要加alias=dw
    ${end_subsidiary}    设置变量    ${result}[0][0]
    #查询是否存在匹配规则
    @{result}    query    SELECT count(*) from fc_transaction_matching_rule tmr join fc_transaction_matching_rule_delivery_node tmrd on tmr.id = tmrd.transaction_matching_rule_id where tmr.delivery_model =12 and tmr.status=1 and UNIX_TIMESTAMP()<tmr.end_time and UNIX_TIMESTAMP()>tmr.start_time and tmrd.start_node in ('${start_supplier}','all') and tmrd.end_node in ('all','${end_customer}');
    ${count}    设置变量    ${result}[0][0]
    #MatchRule=0则没有匹配规则，1则有
    ${MatchRule}    Set Variable If    ${count}==0    0    1
    #根据存货分类传惨决定查看匹配规则SQL
    ${tmr_sql}    设置变量    SELECT tmr.rule_configs->'$[*].tcr_ids',tmrd.start_node ,tmrd.end_node from fc_transaction_matching_rule tmr join fc_transaction_matching_rule_delivery_node tmrd on tmr.id = tmrd.transaction_matching_rule_id where tmr.delivery_model =12 and tmr.status=1 and UNIX_TIMESTAMP()<tmr.end_time and UNIX_TIMESTAMP()>tmr.start_time and tmrd.start_node in ('${start_supplier}','all') and tmrd.end_node in ('all','${end_customer}')
    #${tmr_sql}    Run Keyword If    '1' in '${stock_categories}'     设置变量    ${tmr_sql} and tmr.rule_configs like '%存货分类 等于 商品%'
    #...    ELSE    设置变量    ${tmr_sql}
    #${tmr_sql}    Run Keyword If    '2' in '${stock_categories}'     设置变量    ${tmr_sql} and tmr.rule_configs like '%存货分类 等于 物料%'
    #...    ELSE    设置变量    ${tmr_sql}
    #${tmr_sql}    Run Keyword If    '4' in '${stock_categories}'     设置变量    ${tmr_sql} and tmr.rule_configs like '%存货分类 等于 陈列品%'
    #...    ELSE    设置变量    ${tmr_sql}
    #Log    ${tmr_sql}
    @{result}    query    ${tmr_sql}
    FOR    ${i}    IN RANGE    ${count}
        ${tcr_ids}    Set Variable If    ${i}==0    ${result}[${i}][0]    ${tcr_ids},${result}[${i}][0]
        #${tcr_ids}    设置变量    ${tcr_ids},${result}[${i}][0]
    END
    ${transaction_id}    Run Keyword If    ${count}!=0    Evaluate    "${tcr_ids}".replace("[", "").replace("]", "")
    ...    ELSE    设置变量    0
    Log    ${transaction_id}
    #查询是否存在交易链路
    @{result}    query    select count(*) from fc_transaction_chain_rule where shipping_subsidiary_code in ('${start_subsidiary}') and receiving_subsidiary_code='${end_subsidiary}' and UNIX_TIMESTAMP()<end_time and UNIX_TIMESTAMP()>start_time and status=1 and id in (${transaction_id});
    ${length}    设置变量    ${result}[0][0]
    @{result}    query    select code,levels->'$[*].pricing_rule_id' from fc_transaction_chain_rule where shipping_subsidiary_code in ('${start_subsidiary}') and receiving_subsidiary_code='${end_subsidiary}' and UNIX_TIMESTAMP()<end_time and UNIX_TIMESTAMP()>start_time and status=1 and id in (${transaction_id});
    @{code_list}    Create List
    @{price_rule_list}    Create List
    FOR    ${i}    IN RANGE    ${length}
        Append To List    ${code_list}    ${result}[${i}][0]
        Append To List    ${price_rule_list}    ${result}[${i}][1]
    END
    Log    ${code_list}
    #获取开放接口token
    ${data}    设置变量    {"app_id":"${app_id}[${env}]","app_secret":"${app_secret}[${env}]"}
    ${response}    /open/v1/applications/tokens    ${data}
    ${Authorization}    设置变量    ${response.json()}[data][token]
    #查询交易链路接口
    ${data}    设置变量    {"delivery_model":12,"start_nodes":[{"supplier_code":"${start_supplier}","purchase_subsidiary_code":"${start_subsidiary}","store_code":"","country_Code":"","warehouse_code":""}],"end_nodes":[{"warehouse_code":"","country_Code":"","store_code":"","customer_code":"${end_customer}"}],"stock_categories":[${stock_categories}]}
    ${response}    /open/v1/transaction-chains/queries    ${data}    ${Authorization}
    log    ${response.json()}
    #抓取接口返回的交易链路
    @{intf_code_list}    Create List
    ${intf_code_list}    Run Keyword If    ${response.json()}[code]==0    收集接口返回的交易链路    ${response}    ${intf_code_list}
    ...    ELSE    设置变量    ${intf_code_list}
    ${code_list}    Evaluate    sorted(${code_list})
    ${intf_code_list}    Evaluate    sorted(${intf_code_list})
    #Run Keyword If    ${MatchRule}==1    Should Be Equal As Strings    ${response.json()}[message]    success
    Should Be Equal    ${code_list}    ${intf_code_list}

本地仓到客关键字
    [Arguments]    ${start_warehouse}    ${end_customer}    ${stock_categories}
    #仓库子公司关系转json
    ${warehouse_subsidiary_dict}    Evaluate    json.loads('''${warehouse_subsidiary}''')
    #数仓获取门店对应的子公司
    @{result}    query    select subject_code from dim.dim_retail_public_sc_customer_df where customer_code='${end_customer}';
    ...    alias=dw    #数仓的数据库查询要加alias=dw
    ${end_subsidiary}    设置变量    ${result}[0][0]
    #查询是否存在匹配规则
    @{result}    query    SELECT count(*) from fc_transaction_matching_rule tmr join fc_transaction_matching_rule_delivery_node tmrd on tmr.id = tmrd.transaction_matching_rule_id where tmr.delivery_model =13 and tmr.status=1 and UNIX_TIMESTAMP()<tmr.end_time and UNIX_TIMESTAMP()>tmr.start_time and tmrd.start_node in ('${start_warehouse}') and tmrd.end_node in ('all','${end_customer}');
    ${count}    设置变量    ${result}[0][0]
    #MatchRule=0则没有匹配规则，1则有
    ${MatchRule}    Set Variable If    ${count}==0    0    1
    #根据存货分类传惨决定查看匹配规则SQL
    ${tmr_sql}    设置变量    SELECT tmr.rule_configs->'$[*].tcr_ids',tmrd.start_node ,tmrd.end_node from fc_transaction_matching_rule tmr join fc_transaction_matching_rule_delivery_node tmrd on tmr.id = tmrd.transaction_matching_rule_id where tmr.delivery_model =13 and tmr.status=1 and UNIX_TIMESTAMP()<tmr.end_time and UNIX_TIMESTAMP()>tmr.start_time and tmrd.start_node in ('${start_warehouse}') and tmrd.end_node in ('all','${end_customer}')
    #${tmr_sql}    Run Keyword If    '1' in '${stock_categories}'     设置变量    ${tmr_sql} and tmr.rule_configs like '%存货分类 等于 商品%'
    #...    ELSE    设置变量    ${tmr_sql}
    #${tmr_sql}    Run Keyword If    '2' in '${stock_categories}'     设置变量    ${tmr_sql} and tmr.rule_configs like '%存货分类 等于 物料%'
    #...    ELSE    设置变量    ${tmr_sql}
    #${tmr_sql}    Run Keyword If    '4' in '${stock_categories}'     设置变量    ${tmr_sql} and tmr.rule_configs like '%存货分类 等于 陈列品%'
    #...    ELSE    设置变量    ${tmr_sql}
    #Log    ${tmr_sql}
    @{result}    query    ${tmr_sql}
    FOR    ${i}    IN RANGE    ${count}
        ${tcr_ids}    Set Variable If    ${i}==0    ${result}[${i}][0]    ${tcr_ids},${result}[${i}][0]
        #${tcr_ids}    设置变量    ${tcr_ids},${result}[${i}][0]
    END
    ${transaction_id}    Run Keyword If    ${count}!=0    Evaluate    "${tcr_ids}".replace("[", "").replace("]", "")
    ...    ELSE    设置变量    0
    Log    ${transaction_id}
    #查询是否存在交易链路
    @{result}    query    select count(*) from fc_transaction_chain_rule where receiving_subsidiary_code='${end_subsidiary}' and UNIX_TIMESTAMP()<end_time and UNIX_TIMESTAMP()>start_time and status=1 and id in (${transaction_id});
    ${length}    设置变量    ${result}[0][0]
    @{result}    query    select code,levels->'$[*].pricing_rule_id' from fc_transaction_chain_rule where receiving_subsidiary_code='${end_subsidiary}' and UNIX_TIMESTAMP()<end_time and UNIX_TIMESTAMP()>start_time and status=1 and id in (${transaction_id});
    @{code_list}    Create List
    @{price_rule_list}    Create List
    FOR    ${i}    IN RANGE    ${length}
        Append To List    ${code_list}    ${result}[${i}][0]
        Append To List    ${price_rule_list}    ${result}[${i}][1]
    END
    Log    ${code_list}
    #获取开放接口token
    ${data}    设置变量    {"app_id":"${app_id}[${env}]","app_secret":"${app_secret}[${env}]"}
    ${response}    /open/v1/applications/tokens    ${data}
    ${Authorization}    设置变量    ${response.json()}[data][token]
    #查询交易链路接口
    ${data}    设置变量    {"delivery_model":13,"start_nodes":[{"supplier_code":"","purchase_subsidiary_code":"","store_code":"","country_Code":"","warehouse_code":"${start_warehouse}"}],"end_nodes":[{"warehouse_code":"","country_Code":"","store_code":"","customer_code":"${end_customer}"}],"stock_categories":[${stock_categories}]}
    ${response}    /open/v1/transaction-chains/queries    ${data}    ${Authorization}
    log    ${response.json()}
    #抓取接口返回的交易链路
    @{intf_code_list}    Create List
    ${intf_code_list}    Run Keyword If    ${response.json()}[code]==0    收集接口返回的交易链路    ${response}    ${intf_code_list}
    ...    ELSE    设置变量    ${intf_code_list}
    ${code_list}    Evaluate    sorted(${code_list})
    ${intf_code_list}    Evaluate    sorted(${intf_code_list})
    #Run Keyword If    ${MatchRule}==1    Should Be Equal As Strings    ${response.json()}[message]    success
    Should Be Equal    ${code_list}    ${intf_code_list}

本地供应商到客关键字
    [Arguments]    ${start_supplier}    ${start_subsidiary}    ${end_customer}    ${stock_categories}
    #仓库子公司关系转json
    ${warehouse_subsidiary_dict}    Evaluate    json.loads('''${warehouse_subsidiary}''')
    #数仓获取门店对应的子公司
    @{result}    query    select subject_code from dim.dim_retail_public_sc_customer_df where customer_code='${end_customer}';
    ...    alias=dw    #数仓的数据库查询要加alias=dw
    ${end_subsidiary}    设置变量    ${result}[0][0]
    #查询是否存在匹配规则
    @{result}    query    SELECT count(*) from fc_transaction_matching_rule tmr join fc_transaction_matching_rule_delivery_node tmrd on tmr.id = tmrd.transaction_matching_rule_id where tmr.delivery_model =14 and tmr.status=1 and UNIX_TIMESTAMP()<tmr.end_time and UNIX_TIMESTAMP()>tmr.start_time and tmrd.start_node in ('${start_supplier}','all') and tmrd.end_node in ('all','${end_customer}');
    ${count}    设置变量    ${result}[0][0]
    #MatchRule=0则没有匹配规则，1则有
    ${MatchRule}    Set Variable If    ${count}==0    0    1
    #根据存货分类传惨决定查看匹配规则SQL
    ${tmr_sql}    设置变量    SELECT tmr.rule_configs->'$[*].tcr_ids',tmrd.start_node ,tmrd.end_node from fc_transaction_matching_rule tmr join fc_transaction_matching_rule_delivery_node tmrd on tmr.id = tmrd.transaction_matching_rule_id where tmr.delivery_model =14 and tmr.status=1 and UNIX_TIMESTAMP()<tmr.end_time and UNIX_TIMESTAMP()>tmr.start_time and tmrd.start_node in ('${start_supplier}','all') and tmrd.end_node in ('all','${end_customer}')
    #${tmr_sql}    Run Keyword If    '1' in '${stock_categories}'     设置变量    ${tmr_sql} and tmr.rule_configs like '%存货分类 等于 商品%'
    #...    ELSE    设置变量    ${tmr_sql}
    #${tmr_sql}    Run Keyword If    '2' in '${stock_categories}'     设置变量    ${tmr_sql} and tmr.rule_configs like '%存货分类 等于 物料%'
    #...    ELSE    设置变量    ${tmr_sql}
    #${tmr_sql}    Run Keyword If    '4' in '${stock_categories}'     设置变量    ${tmr_sql} and tmr.rule_configs like '%存货分类 等于 陈列品%'
    #...    ELSE    设置变量    ${tmr_sql}
    #Log    ${tmr_sql}
    @{result}    query    ${tmr_sql}
    FOR    ${i}    IN RANGE    ${count}
        ${tcr_ids}    Set Variable If    ${i}==0    ${result}[${i}][0]    ${tcr_ids},${result}[${i}][0]
        #${tcr_ids}    设置变量    ${tcr_ids},${result}[${i}][0]
    END
    ${transaction_id}    Run Keyword If    ${count}!=0    Evaluate    "${tcr_ids}".replace("[", "").replace("]", "")
    ...    ELSE    设置变量    0
    Log    ${transaction_id}
    #查询是否存在交易链路
    @{result}    query    select count(*) from fc_transaction_chain_rule where shipping_subsidiary_code in ('${start_subsidiary}') and receiving_subsidiary_code='${end_subsidiary}' and UNIX_TIMESTAMP()<end_time and UNIX_TIMESTAMP()>start_time and status=1 and id in (${transaction_id});
    ${length}    设置变量    ${result}[0][0]
    @{result}    query    select code,levels->'$[*].pricing_rule_id' from fc_transaction_chain_rule where shipping_subsidiary_code in ('${start_subsidiary}') and receiving_subsidiary_code='${end_subsidiary}' and UNIX_TIMESTAMP()<end_time and UNIX_TIMESTAMP()>start_time and status=1 and id in (${transaction_id});
    @{code_list}    Create List
    @{price_rule_list}    Create List
    FOR    ${i}    IN RANGE    ${length}
        Append To List    ${code_list}    ${result}[${i}][0]
        Append To List    ${price_rule_list}    ${result}[${i}][1]
    END
    Log    ${code_list}
    #获取开放接口token
    ${data}    设置变量    {"app_id":"${app_id}[${env}]","app_secret":"${app_secret}[${env}]"}
    ${response}    /open/v1/applications/tokens    ${data}
    ${Authorization}    设置变量    ${response.json()}[data][token]
    #查询交易链路接口
    ${data}    设置变量    {"delivery_model":14,"start_nodes":[{"supplier_code":"${start_supplier}","purchase_subsidiary_code":"${start_subsidiary}","store_code":"","country_Code":"","warehouse_code":""}],"end_nodes":[{"warehouse_code":"","country_Code":"","store_code":"","customer_code":"${end_customer}"}],"stock_categories":[${stock_categories}]}
    ${response}    /open/v1/transaction-chains/queries    ${data}    ${Authorization}
    log    ${response.json()}
    #抓取接口返回的交易链路
    @{intf_code_list}    Create List
    ${intf_code_list}    Run Keyword If    ${response.json()}[code]==0    收集接口返回的交易链路    ${response}    ${intf_code_list}
    ...    ELSE    设置变量    ${intf_code_list}
    ${code_list}    Evaluate    sorted(${code_list})
    ${intf_code_list}    Evaluate    sorted(${intf_code_list})
    #Run Keyword If    ${MatchRule}==1    Should Be Equal As Strings    ${response.json()}[message]    success
    Should Be Equal    ${code_list}    ${intf_code_list}

收集接口返回的交易链路
    [Arguments]    ${response}    ${intf_code_list}
    ${json_len}    Get Length    ${response.json()}[data][rules]
    FOR    ${i}    IN RANGE    ${json_len}
        Run Keyword If    '${response.json()}[data][rules][${i}][code]'!='${empty}'    Append To List    ${intf_code_list}    ${response.json()}[data][rules][${i}][code][:18]
        Log    ${intf_code_list}
    END    
    [Return]    ${intf_code_list}
