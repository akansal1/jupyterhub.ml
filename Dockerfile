# Based on the following:  https://github.com/jupyterhub/jupyterhub/blob/master/Dockerfile
FROM fluxcapacitor/package-spark-2.0.1

# install nodejs, utf8 locale
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get -y update && \
    apt-get -y upgrade && \
    apt-get -y install npm nodejs nodejs-legacy wget locales git

# install Python with conda
RUN wget -q https://repo.continuum.io/miniconda/Miniconda3-4.0.5-Linux-x86_64.sh -O /tmp/miniconda.sh  && \
    echo 'a7bcd0425d8b6688753946b59681572f63c2241aed77bf0ec6de4c5edc5ceeac */tmp/miniconda.sh' | shasum -a 256 -c - && \
    bash /tmp/miniconda.sh -f -b -p /opt/conda && \
    /opt/conda/bin/conda install --yes python=3.5 sqlalchemy tornado jinja2 traitlets requests pip && \
    /opt/conda/bin/pip install --upgrade pip && \
    rm /tmp/miniconda.sh

ENV PATH=/opt/conda/bin:$PATH

# install js dependencies
RUN npm install -g configurable-http-proxy && rm -rf ~/.npm

# Setup py3 and py2 environments for jupyterhub
RUN \
  conda create --yes -n py3 python=3 anaconda \
  && conda create --yes -n py2 python=2 anaconda

RUN \
  conda install --yes notebook

#RUN \
#  source activate py3 && conda install --yes -c conda-forge tensorflow

RUN \
  pip install jupyterhub \
  && pip install jupyterhub-dummyauthenticator

# Add guest account
RUN \
  adduser guest --gecos GECOS --disabled-password

WORKDIR /root

COPY start.sh /root
COPY jupyterhub_config.py /root

EXPOSE 8764

CMD ["supervise", "."]
