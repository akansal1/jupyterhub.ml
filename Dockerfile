# Based on the following:  https://github.com/jupyterhub/jupyterhub/blob/master/Dockerfile

FROM ubuntu:14.04

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

#RUN \
#  apt-get install -y python3-pip \
#  && pip3 install jupyterhub \
#  && pip3 install --upgrade notebook \
#  && ipython3 kernel install \

# Install everything (except JupyterHub itself) with Python 2 and 3. 
#  (Jupyter is included in Anaconda.)
RUN \
  conda create --yes -n py3 python=3 anaconda \
  && conda create --yes -n py2 python=2 anaconda \
  # register py2 kernel
  && source activate py2 \
  && ipython kernel install \
  # same for py3, and install juptyerhub in the py3 env
  && source activate py3 \
  && ipython kernel install 

RUN \
  pip install jupyterhub \
  && pip install jupyterhub-dummyauthenticator

WORKDIR /root

COPY jupyterhub_config.py /root

EXPOSE 8764

CMD ["jupyterhub", "--config=jupyterhub_config.py"]
