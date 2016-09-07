# Based on the following:  https://github.com/jupyterhub/jupyterhub/blob/master/Dockerfile

FROM ubuntu:14.04

# install nodejs, utf8 locale
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get -y update && \
    apt-get -y upgrade && \
    apt-get -y install npm nodejs nodejs-legacy wget locales git 
    
#   &&\ /usr/sbin/update-locale LANG=C.UTF-8 && \
#    locale-gen C.UTF-8 && \
#    apt-get remove -y locales && \
#    apt-get clean && \
#    rm -rf /var/lib/apt/lists/*

# ENV LANG C.UTF-8

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

#RUN python setup.py js && pip install . && \
#    rm -rf $PWD ~/.cache ~/.npm

#RUN mkdir -p /jupyterhub/

#WORKDIR /jupyterhub/
RUN \
  apt-get install -y python3-pip \
  && pip3 install -y jupyterhub \
  && pip3 install --upgrade notebook \
  && ipython3 kernel install

#LABEL org.jupyter.service="jupyterhub"
WORKDIR /root

COPY jupyterhub_config.py /root

EXPOSE 8764

CMD ["jupyterhub"]
