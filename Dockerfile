# Based on the following:  https://github.com/jupyterhub/jupyterhub/blob/master/Dockerfile
FROM fluxcapacitor/package-spark-2.0.1

# install nodejs, utf8 locale
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get -y update && \
    apt-get -y upgrade && \
    apt-get -y install npm nodejs nodejs-legacy wget locales git

# libav-tools for matplotlib anim
RUN apt-get update && \
    apt-get install -y --no-install-recommends libav-tools && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

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
  conda create --yes -n py3 python=3.5 anaconda \
  && conda create --yes -n py2 python=2.7 anaconda

RUN \
  conda install --yes -n py3 -c conda-forge tensorflow \
  && conda install --yes -n py3 -c conda-forge matplotlib \
  && conda install --yes -n py3 -c conda-forge pandas \
  && conda install --yes -n py3 -c anaconda scikit-learn \
  && conda install --yes -n py3 -c conda-forge py4j \
  && conda install --yes -n py2 -c conda-forge tensorflow \
  && conda install --yes -n py2 -c conda-forge matplotlib \
  && conda install --yes -n py2 -c conda-forge pandas \
  && conda install --yes -n py2 -c anaconda scikit-learn \
  && conda install --yes -n py2 -c conda-forge py4j 

RUN \
  conda install --yes -n py3 ipython jupyter \
  && conda install --yes -n py2 ipython jupyter 

RUN \
  conda install --yes -c conda-forge -n py3 jupyterhub=0.6.1 \
  && conda install --yes -c conda-forge -n py3 ipykernel=4.5.0 \
  && conda install --yes -c conda-forge -n py2 ipykernel=4.5.0 \
  && conda install --yes -c conda-forge -n py3 notebook=4.2.3 \
  && conda install --yes -c conda-forge -n py2 notebook=4.2.3 \ 
  && conda install --yes -c conda-forge -n py3 findspark=1.0.0 \
  && conda install --yes -c conda-forge -n py2 findspark=1.0.0 \
  && conda install --yes -c anaconda -n py3 ipykernel

# Add guest accounts
RUN \
  adduser guest1 --gecos GECOS --disabled-password \
  && adduser guest2 --gecos GECOS --disabled-password 

COPY notebooks/ /home/guest1/notebooks/
COPY notebooks/ /home/guest2/notebooks/

WORKDIR /root

COPY run run
COPY jupyterhub_config.py jupyterhub_config.py
COPY notebooks/ notebooks/ 
COPY lib/ lib/
COPY kernels/ kernels/ 
COPY profiles/ profiles/

ENV SPARK_HOME=/root/spark-2.0.1-SNAPSHOT-bin-fluxcapacitor
ENV PYTHONPATH=$SPARK_HOME/python:$SPARK_HOME/python/lib/py4j-0.10.3-src.zip
ENV PATH=$SPARK_HOME/bin:$PATH

EXPOSE 8754

CMD ["supervise", "."]
