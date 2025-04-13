#!/bin/bash
source $ORACLE_HOME/bin/oracle_env.sh

# 等待备库监听器和数据库就绪
while true; do
  if $ORACLE_HOME/bin/tnsping standby >/dev/null 2>&1; then
    if $ORACLE_HOME/bin/sqlplus -S sys/oracle@standby as sysdba <<< "exit" >/dev/null 2>&1; then
      break
    fi
  fi
  echo "Waiting for standby database and listener..."
  sleep 5
done

# 从主库复制数据文件（需挂载共享卷或通过scp，此处简化为占位）
cp /tmp/standby.ctl $ORACLE_HOME/oradata/XE/control01.ctl

# 启动到Mount状态
sqlplus sys/oracle@standby as sysdba <<EOF
STARTUP NOMOUNT;
ALTER DATABASE MOUNT STANDBY DATABASE;
ALTER DATABASE RECOVER MANAGED STANDBY DATABASE DISCONNECT FROM SESSION;
EOF
