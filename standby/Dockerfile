FROM oracleinanutshell/oracle-xe-11g:latest
# 切换到 oracle 用户
# USER oracle

ENV ORACLE_HOME=/u01/app/oracle/product/11.2.0/xe \
    PATH=$ORACLE_HOME/bin:$PATH

# 复制配置文件和脚本
COPY listener.ora /tmp/
COPY tnsnames.ora /tmp/
COPY scripts/ /docker-entrypoint-initdb.d/

RUN mv /tmp/listener.ora $ORACLE_HOME/network/admin/ && \
    mv /tmp/tnsnames.ora $ORACLE_HOME/network/admin/ && \
    chmod +x /docker-entrypoint-initdb.d/*.sh

EXPOSE 1521
