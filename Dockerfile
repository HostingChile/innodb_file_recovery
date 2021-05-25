FROM bitnami/mysql:5.7.34

USER root

RUN apt-get update && apt-get install -y \
    git \
    python2.7 \
    python-pip

RUN pip install mysql-connector

RUN git clone https://github.com/mysql/mysql-utilities.git /mysql-utilites && \
    cd /mysql-utilites && \
    git checkout release-1.6.5

WORKDIR /mysql-utilites

RUN python2.7 setup.py install