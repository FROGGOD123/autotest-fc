*** Settings ***
Library           requests
Library           RequestsLibrary
Library           json
Library           urllib3
Library           DatabaseLibrary

*** Variables ***
#环境变量
${env}    test
#财税云数据库
&{fc_mysql_pwd}    test=ly5Vt893*FINamW
&{fc_mysql_user}    test=finance_test
&{fc_mysql_url}    test=rm-wz9u28bqy85v082837o.mysql.rds.aliyuncs.com
&{fc_mysql_port}    test=3306
#数仓数据库
&{dw_psySql_pwd}    test=Y0Vibw5K1aRWf@AH
&{dw_psySql_user}    test=BASIC$bo_test_group
&{dw_psySql_url}    test=hgpostcn-cn-1ls46jmnr0er-cn-shenzhen.hologres.aliyuncs.com
&{dw_psySql_port}    test=80
#财税云地址
&{fc_url}    test=https://financial-cloud-service.blueorigin.work
#财税云secret
&{app_id}    test=MFt3lLVxlZfow4xv
&{app_secret}    test=SPTB0FU73HA7JwGHRey7iZHd9JTHcgdj
#财税云实体仓对应子公司
@{entity_warehouse}    KH01PP    CN01SZ-CAM    CN01SZ-ID    CN01SZ-MY    CN01SZ-SG    CN01SZ-TH    CN01SZ-VN    ID02SBY    ID01JKT    VN01HCM    MY01KL    SG01KL    PH01MNL    #实体仓编码
${warehouse_subsidiary}    {"KH01PP":"BO015","CN01SZ-CAM":"BO002","CN01SZ-ID":"BO002","CN01SZ-MY":"BO002","CN01SZ-SG":"BO002","CN01SZ-TH":"BO002","CN01SZ-VN":"BO002","ID03TGR":["PT001","109","BO005","BO004","BO003","BO016"],"ID02SBY":["PT001","109","BO005","BO004","BO003","BO016"],"ID01JKT":["PT001","109","BO005","BO004","BO003","BO016"],"VN01HCM":"BO019","MY01KL":"BO010","SG01KL":"BO010","PH01MNL":["BO024","BO031"]}    #实体仓编码对应子公司
#财税云门店对应子公司
