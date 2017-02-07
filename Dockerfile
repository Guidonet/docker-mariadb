# MariaDB 10.1 Container Build
# docker build ./ -t mariadb:latest
# On the slaves, run: mkdir -p /var/lib/mysql/mysql before running container for first time 
# Add to docker run after validation: --restart=unless-stopped
# Must change IP to match node and cluster addresses to match the addresses you have, use names if possible
# On first run of master: docker run -d -p 3306:3306 -p 4567:4567 -p 4444:4444 -p 4568:4568 -e CLUSTER=BOOTSTRAP -e CLUSTER_NAME=mariadb -e MYSQL_ROOT_PASSWORD=password -e IP=192.168.1.165 -v /data/mariadb:/var/lib/mysql --name mariadb1 mariadb 
# On additional nodes: docker run -d -p 3306:3306 -p 4567:4567 -p 4444:4444 -p 4568:4568 -e CLUSTER=192.168.1.165,192.168.1.162,192.168.1.156,192.168.1.157 -e CLUSTER_NAME=mariadb -e MYSQL_ROOT_PASSWORD=password -e IP=192.168.1.162 -v /data/mariadb:/var/lib/mysql --name mariadb2 mariadb

FROM centos:7
MAINTAINER derek andrews <derek.andrews@usbank.com>

# Add Maria Repo
RUN echo -e "[mariadb] \nname = MariaDB \nbaseurl = http://yum.mariadb.org/10.1/centos7-amd64 \ngpgkey=https://yum.mariadb.org/RPM-GPG-KEY-MariaDB \ngpgcheck=1 \n " > /etc/yum.repos.d/MariaDB.repo

# Install required packages
RUN yum -y install epel-release
RUN yum -y install mariadb-server mariadb-client pwgen
RUN mkdir /docker-entrypoint-initdb.d

RUN rm -rf /var/lib/mysql && mkdir /var/lib/mysql

COPY server.cnf /etc/my.cnf.d/server.cnf
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chown -R mysql:mysql /var/lib/mysql/
RUN chmod 777 /var/lib/mysql/

EXPOSE 3306 4444 4567 4568
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["mysqld"]
