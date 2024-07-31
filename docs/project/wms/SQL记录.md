





##### 组盘SQL 新增

```sql
INSERT INTO rc_transfer_note_product ( id, transfer_note_task, receipt_no, ext_order_line_no, product_no, product_name, ext_biz_batch_no, purchase_price_including_tax, total_prices, quantity, ext_order_no, kufang_code, kufang_name, area_name, area_code, map_roadway_code, map_pai, map_ceng, map_lie, delete_mark, create_time, update_time ) VALUES ( 1801411074164629505, 'ZP202406130081', 'SH202406130011', '10', '21001234', '楔式闸阀\Z41H-10C-100', '10', '0.0000', '0.000000', '1', '180277040 ', 'FSLK001', '纺丝库房', '纺丝库区', 'FSA001', 'L1', '2', '008', '000', 0, '2024-06-13 14:28:17.0', '2024-06-13 14:28:17.0' )
```



##### 入库单产品明细表 查询

```sql
SELECT id,receipt_no,order_no,ext_order_no,purchase_order_no,ext_order_line_no,ext_certificate_no,inspection_no,company_code,company_name,logistics_center_id,logistics_code,logistics_name,wm_id,wm_code,wm_name,product_no,product_name,package_code,product_description,article_no,manufacturer_code,manufacturer_name,base_num_unit_name,production_batch_no,manufacture_date,purchase_price_including_tax,total_prices,bar_code,product_category_no,product_category_name,quantity,transfer_quantity,shelves_quantity,status,quality_status,quality_grade,batch_management,cargo_owner_code,cargo_owner_name,package_bar_code,ext_biz_batch_no,shelf_life,brand_code,brand_name,vendor_code,vendor_name,wbs_project_no,project_no,base_num_unit,werks,aufps,ebelp,rspos,sobkz,kostl,prctr,ps_psr_pnr,equnr,zllfs,lifnr,lgort,umlgo,umwrk,certificate_no,create_by,create_time,update_by,update_time,delete_mark,acceptance_check_user_code,acceptance_check_user_name FROM rc_receiving_note_product WHERE (ext_order_no = '180277040' AND product_no = '21001234')
```



组盘任务

```sql
SELECT id,transfer_note_task,receipt_no,receipt_sub_no,order_no,ext_order_no,order_type,company_code,company_name,logistics_center_id,logistics_code,logistics_name,enterprise_id,wm_code,wm_name,cargo_owner_code,cargo_owner_name,business_type_code,status,create_by,create_time,update_by,update_time,warehouse_by,receiving_by,acceptance_check_user_code,acceptance_check_user_name,purchase_order_no,vendor_code,vendor_name,send_flag,product_source,back_status,delete_mark FROM rc_transfer_note_task WHERE delete_mark=0 AND (ext_order_no = '180277040')
```



库位占用 0空闲 10使用中 20正在搬入 30正在搬出

```sql
UPDATE base_main_map_locator SET STATUS=1 WHERE delete_mark=0 AND (WM_CODE = 'FS001' AND MAP_CODE = 'L11-000-010')
```



库房入库规则

```sql
SELECT id,LOGISTICS_CENTER_ID,LOGISTICS_NAME,LOGISTICS_CODE,WM_CODE,WM_NAME,inbound_type,outbound_type,in_rules,out_rules,sap_inventory_location,USAGE_FLAG,CREATE_BY,UPDATE_BY,update_time,delete_mark,create_time FROM base_main_wh_mst WHERE delete_mark=0 AND (WM_CODE = 'FS001') limit 1
```



获取WCS任务

```sql
SELECT id,wms_code,location_code,container_codes,request_type,comments,move_code,move_type,direction,start,end,cancelled,create_by,create_time,update_by,update_time,delete_mark,status FROM cnf_fs_wcs_task WHERE (container_codes = null AND status = 0)
```



产品库存 （relation_order_no=库存关联单号【productNo物料号】）

```sql
SELECT * FROM pims_production_inventory WHERE delete_mark = 0 AND relation_order_no = '21001234' order by logistics_code, wm_code, cargo_owner_code, kufang_code, area_code, map_code, product_no, batch_no
```



##### 查询纺丝库 WCS 的任务 

```sql
SELECT id,wms_code,location_code,container_codes,request_type,comments,move_code,move_type,direction,start,end,cancelled,create_by,create_time,update_by,update_time,delete_mark,status FROM cnf_fs_wcs_task WHERE (move_type IN ('转移','上架') AND container_codes = null AND status = 0)
```



##### 查询库存预占  **pims_production_inventory_preempt** 

```sql
SELECT id,production_inventory_id,ext_order_no,order_no,order_type,business_type_code,enterprise_id,company_code,company_name,logistics_code,logistics_name,wm_code,wm_name,vendor_code,vendor_name,manufacturer_code,manufacturer_name,cargo_owner_code,cargo_owner_name,kufang_code,kufang_name,area_code,area_name,brand_code,brand_name,product_category_no,product_category_name,product_no,product_name,batch_no,production_batch_no,receipt_batch_no,package_code,wbs_project_no,base_num_unit,base_num_unit_name,base_num_unit_quantity,assistant_num_unit,assistant_num_unit_name,assistant_num_unit_quantity,create_by,create_dept,create_time,update_by,update_time,status,delete_mark FROM pims_production_inventory_preempt WHERE delete_mark=0 AND (order_no IS NULL)
```



库位查询 

>  **表名：base_main_logistic_kufang**    主数据-基础资料-物流中心-库房资料
>
> **表名：base_main_kufang_zone** 		主数据-基础资料-库区
>
> **表名：base_main_map_locator**  		主数据-基础资料-MAP库位

```sql
select m.*, z.high from base_main_logistic_kufang k inner join base_main_kufang_zone z on k.kufang_code = z.kufang_code inner join base_main_map_locator m on z.kufang_code = m.kufang_code and z.area_code = m.area_code where m.delete_mark = 0 and m.status = 0 and m.usage_flag = 1 and k.kufang_device_type = 'HayStacker' and m.map_roadway_code = 'L1' order by concat(m.map_lie, m.map_ceng), case m.map_pai when '1' THEN 1 when '2' THEN 2 when '4' THEN 3 when '3' THEN 4 END
```





```yaml
kind: StatefulSet
apiVersion: apps/v1
metadata:
  name: nacos-standalone
  namespace: middleware
  labels:
    app: nacos-standalone
  annotations:
    kubesphere.io/creator: admin
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nacos-standalone
  template:
    metadata:
      creationTimestamp: null
      labels:
        app: nacos-standalone
      annotations:
        kubesphere.io/restartedAt: '2024-06-14T09:30:02.693Z'
        logging.kubesphere.io/logsidecar-config: '{}'
    spec:
      volumes:
        - name: volume-csutom
          configMap:
            name: holo-nacos-custom
            defaultMode: 420
      containers:
        - name: holo-nacos
          image: 'nacos/nacos-server:v2.2.0'
          ports:
            - name: http-8848
              containerPort: 8848
              protocol: TCP
            - name: http-9848
              containerPort: 9848
              protocol: TCP
            - name: http-9849
              containerPort: 9849
              protocol: TCP
          env:
            - name: MODE
              value: standalone
            - name: PREFER_HOST_MODE
              value: hostname
            - name: SPRING_DATASOURCE_PLATFORM
              value: mysql
            - name: MYSQL_SERVICE_HOST
              value: 10.30.94.24
            - name: MYSQL_SERVICE_PORT
              value: '3306'
            - name: MYSQL_SERVICE_DB_NAME
              value: pigxx_config
            - name: MYSQL_SERVICE_USER
              value: root
            - name: MYSQL_SERVICE_PASSWORD
              value: root
            - name: MYSQL_DATABASE_NUM
              value: '1'
            - name: MYSQL_SERVICE_DB_PARAM
              value: >-
                useSSL=false&useUnicode=true&characterEncoding=utf-8&zeroDateTimeBehavior=convertToNull&tinyInt1isBit=false&allowMultiQueries=true&serverTimezone=GMT%2B8&nullCatalogMeansCurrent=true&allowPublicKeyRetrieval=true&useJDBCCompliantTimezoneShift=true&useLegacyDatetimeCode=false
          resources: {}
          volumeMounts:
            - name: volume-custom
              readOnly: true
              mountPath: /home/nacos/init.d/custom.propertie
              subPath: custom.properties
          terminationMessagePath: /dev/termination-log
          terminationMessagePolicy: File
          imagePullPolicy: IfNotPresent
          securityContext:
            privileged: true
      restartPolicy: Always
      terminationGracePeriodSeconds: 30
      dnsPolicy: ClusterFirst
      serviceAccountName: default
      serviceAccount: default
      securityContext: {}
      affinity: {}
      schedulerName: default-scheduler
  serviceName: nacos-standalone
  podManagementPolicy: OrderedReady
  updateStrategy:
    type: RollingUpdate
    rollingUpdate:
      partition: 0
  revisionHistoryLimit: 10
 ---
 kind: ConfigMap
apiVersion: v1
metadata:
  name: holo-nacos-custom
  namespace: middleware
  annotations:
    kubesphere.io/creator: admin
data:
  custom.properties: >
    server.contextPath=/nacos

    server.servlet.contextPath=/nacos

    server.port=8848

    nacos.cmdb.dumpTaskInterval=3600

    nacos.cmdb.eventTaskInterval=10

    nacos.cmdb.labelTaskInterval=300

    nacos.cmdb.loadDataAtStart=false

    management.metrics.export.elastic.enabled=false

    management.metrics.export.influx.enabled=false

    server.tomcat.accesslog.enabled=true

    server.tomcat.accesslog.pattern=%h %l %u %t "%r" %s %b %D %{User-Agent}i

    nacos.security.ignore.urls=/,/**/*.css,/**/*.js,/**/*.html,/**/*.map,/**/*.svg,/**/*.png,/**/*.ico,/console-fe/public/**,/v1/auth/login,/v1/console/health/**,/v1/cs/**,/v1/ns/**,/v1/cmdb/**,/actuator/**,/v1/console/server/**

    nacos.naming.distro.taskDispatchThreadCount=1

    nacos.naming.distro.taskDispatchPeriod=200

    nacos.naming.distro.batchSyncKeyCount=1000

    nacos.naming.distro.initDataRatio=0.9

    nacos.naming.distro.syncRetryDelay=5000

    nacos.naming.data.warmup=true

    nacos.naming.expireInstance=true

```

