#!/bin/bash
# 从主库复制数据文件（需挂载共享卷或通过scp，此处简化为占位）
cp /tmp/standby.ctl $ORACLE_HOME/oradata/XE/control01.ctl

# 启动到Mount状态
sqlplus / as sysdba <<EOF
STARTUP NOMOUNT;
ALTER DATABASE MOUNT STANDBY DATABASE;
ALTER DATABASE RECOVER MANAGED STANDBY DATABASE DISCONNECT FROM SESSION;
EOF
