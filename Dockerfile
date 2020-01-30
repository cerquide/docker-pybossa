FROM python:3.8-slim-buster

RUN apt-get update && apt-get install -y\
    #postgresql-dev\
    g++\
    gcc\ 
    git\ 
    #jpeg-dev\ 
    libffi-dev\ 
    #libjpeg\ 
    libxml2-dev\
    libxslt-dev\
    #linux-headers\ 
    musl-dev\ 
    openssl
    #zlib\
    #zlib-dev
RUN apt-get install -y\  
    postgresql\
    postgresql-server-dev-all\ 
    libpq-dev\ 
    python-psycopg2\ 
    libsasl2-dev\ 
    libldap2-dev\ 
    libssl-dev
RUN apt-get install -y\
    python-virtualenv
RUN apt-get install -y\
    python-dev build-essential libjpeg-dev libssl-dev libffi-dev
RUN apt-get install -y dbus libdbus-1-dev libdbus-glib-1-dev libldap2-dev libsasl2-dev
RUN set -x && \
    git clone --recursive https://github.com/cerquide/pybossa /opt/pybossa && \
    cd /opt/pybossa && \
    pip install -U pip setuptools && \
    pip install -r /opt/pybossa/reqs.txt
RUN set -x && \
    rm -rf /opt/pybossa/.git/ && \
    addgroup pybossa  && \
    useradd -g pybossa -s /bin/sh -d /opt/pybossa pybossa
#    passwd -u pybossa

ADD alembic.ini /opt/pybossa/
ADD settings_local.py /opt/pybossa/

# TODO: we shouldn't need write permissions on the whole folder
#   Known files written during runtime:
#     - /opt/pybossa/pybossa/themes/default/static/.webassets-cache
#     - /opt/pybossa/alembic.ini and /opt/pybossa/settings_local.py (from entrypoint.sh)
RUN chown -R pybossa:pybossa /opt/pybossa

ADD entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]

# run with unprivileged user
USER pybossa
WORKDIR /opt/pybossa
EXPOSE 8080

# Background worker is also necessary and should be run from another copy of this container
#   python app_context_rqworker.py scheduled_jobs super high medium low email maintenance
CMD ["python", "run.py"]
#CMD tail -f /dev/null
