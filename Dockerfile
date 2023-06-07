FROM nginx:1.25.0
# 切换国内源
RUN sed -i 's/deb/#deb/g' /etc/apt/sources.list\
    && sed -i '$a\deb https://mirrors.tuna.tsinghua.edu.cn/debian/ bullseye main contrib non-free'  /etc/apt/sources.list\
    && sed -i '$a\deb https://mirrors.tuna.tsinghua.edu.cn/debian/ bullseye-updates main contrib non-free'  /etc/apt/sources.list\
    && sed -i '$a\deb https://mirrors.tuna.tsinghua.edu.cn/debian/ bullseye-backports main contrib non-free'  /etc/apt/sources.list\
    && sed -i '$a\deb https://security.debian.org/debian-security bullseye-security main contrib non-free'  /etc/apt/sources.list\
    && apt update\
    && apt -y upgrade
# 从sury/php的PPA存储库中安装PHP,并安装扩展
RUN apt install ca-certificates apt-transport-https software-properties-common -y\
    && apt install -y wget vim gpg\
    && echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/sury-php.list\
    && wget -qO - https://packages.sury.org/php/apt.gpg | apt-key add -\
    && apt update\
    && apt install php8.2-fpm php8.2-mysql php8.2-gd php8.2-imap php8.2-ldap php8.2-odbc php-pear php8.2-xml php8.2-xmlrpc -y

## 更新fpm用户权限
RUN sed -i 's/www-data/nginx/g' /etc/php/8.2/fpm/pool.d/www.conf
# 在/run目录下新建一个php目录, 否则启动php-fpm会报错
RUN mkdir /run/php

COPY default.conf /etc/nginx/conf.d/default.conf
COPY ntunnel_mysql.php /usr/share/nginx/html


RUN echo 'php-fpm8.2 --daemonize' >> start.sh
RUN echo 'nginx -g "daemon off;"' >> start.sh

ENTRYPOINT [ "bash", "start.sh" ]