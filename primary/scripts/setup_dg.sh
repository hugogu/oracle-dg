#!/bin/bash
source $ORACLE_HOME/bin/oracle_env.sh
# 等待数据库启动
while true; do
  if $ORACLE_HOME/bin/tnsping primary >/dev/null 2>&1; then
    if $ORACLE_HOME/bin/sqlplus -S sys/oracle@primary as sysdba <<< "exit" >/dev/null 2>&1; then
      break
    fi
  fi
  echo "Waiting for database and listener..."
  sleep 5
done

# 启用归档模式
sqlplus sys/oracle@primary as sysdba <<EOF
SHUTDOWN IMMEDIATE;
STARTUP MOUNT;
ALTER DATABASE ARCHIVELOG;
ALTER DATABASE OPEN;
ALTER SYSTEM SET LOG_ARCHIVE_CONFIG='DG_CONFIG=(primary,standby)';
ALTER SYSTEM SET LOG_ARCHIVE_DEST_1='LOCATION=/u01/app/oracle/arch VALID_FOR=(ALL_LOGFILES,ALL_ROLES) DB_UNIQUE_NAME=primary';
ALTER SYSTEM SET LOG_ARCHIVE_DEST_2='SERVICE=standby:1521 ASYNC VALID_FOR=(ONLINE_LOGFILES,PRIMARY_ROLE) DB_UNIQUE_NAME=standby';
ALTER SYSTEM SET FAL_SERVER=standby;
ALTER SYSTEM SET STANDBY_FILE_MANAGEMENT=AUTO;
EOF

# 创建Standby Redo Logs（根据实际日志组大小调整）
sqlplus sys/oracle@primary as sysdba <<EOF
ALTER DATABASE ADD STANDBY LOGFILE GROUP 4 '/u01/app/oracle/oradata/XE/std_redo04.log' SIZE 50M;
ALTER DATABASE ADD STANDBY LOGFILE GROUP 5 '/u01/app/oracle/oradata/XE/std_redo05.log' SIZE 50M;
ALTER DATABASE ADD STANDBY LOGFILE GROUP 6 '/u01/app/oracle/oradata/XE/std_redo06.log' SIZE 50M;
EOF

# 生成备库初始化控制文件
sqlplus sys/oracle@primary as sysdba <<EOF
ALTER DATABASE CREATE STANDBY CONTROLFILE AS '/tmp/standby.ctl';
EOF
