FROM fluxcapacitor/package-spark-2.0.1

# Based on the following:  https://github.com/jupyterhub/jupyterhub/blob/master/Dockerfile

# install nodejs, utf8 locale
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get -y update && \
    apt-get -y upgrade && \
    apt-get -y install npm nodejs nodejs-legacy wget locales git

# libav-tools for matplotlib anim
RUN apt-get update && \
    apt-get install -y --no-install-recommends libav-tools && \
    apt-get clean 
#    rm -rf /var/lib/apt/lists/*

# Overcomes current limitation with conda matplotlib (1.5.1)
RUN \
  apt-get install -y python-qt4

# Install JupyterHub dependencies
RUN npm install -g configurable-http-proxy && rm -rf ~/.npm

WORKDIR /root

# Install Python with conda
RUN wget -q https://repo.continuum.io/miniconda/Miniconda3-4.1.11-Linux-x86_64.sh -O /tmp/miniconda.sh  && \
    echo '874dbb0d3c7ec665adf7231bbb575ab2 */tmp/miniconda.sh' | md5sum -c - && \
    bash /tmp/miniconda.sh -f -b -p /opt/conda && \
    /opt/conda/bin/conda install --yes python=3.5 sqlalchemy tornado jinja2 traitlets requests pip && \
    /opt/conda/bin/pip install --upgrade pip && \
    rm /tmp/miniconda.sh

ENV PATH=/opt/conda/bin:$PATH

# Install non-secure dummyauthenticator for jupyterhub (dev purposes only)
RUN \
  pip install jupyterhub-dummyauthenticator

RUN \
  conda install --yes scikit-learn numpy scipy ipython jupyter matplotlib pandas 

RUN \
  pip install https://storage.googleapis.com/tensorflow/linux/cpu/tensorflow-0.10.0-cp35-cp35m-linux_x86_64.whl

RUN \
  conda install --yes -c conda-forge py4j

RUN \
  conda install --yes -c conda-forge jupyterhub=0.6.1 \
  && conda install --yes -c conda-forge ipykernel=4.5.0 \
  && conda install --yes -c conda-forge notebook=4.2.3 \
  && conda install --yes -c conda-forge findspark=1.0.0 

RUN \
  pip install jupyterhub-dummyauthenticator

# Add guest accounts
RUN \
  adduser guest1 --gecos GECOS --disabled-password \
  && adduser guest2 --gecos GECOS --disabled-password 

COPY notebooks/ /home/guest1/notebooks/
COPY notebooks/ /home/guest2/notebooks/

COPY run run
COPY jupyterhub_config.py jupyterhub_config.py
COPY notebooks/ notebooks/ 
COPY lib/ lib/
COPY profiles/ /root/.ipython/ 

EXPOSE 8754

CMD ["supervise", "."]
