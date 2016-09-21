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
  conda create --yes -n py3 python=3 anaconda \
  && conda create --yes -n py2 python=2 anaconda

RUN \
  conda install --yes notebook

#################################################
# TODO:  integrate the following:
#   https://github.com/jupyter/docker-stacks/
# and spawn docker conatiners
#################################################

RUN \
  pip install py4j \
  && pip2 install py4j

RUN conda install --yes -c conda-forge tensorflow
RUN conda install --yes -c conda-forge matplotlib
RUN conda install --yes -c conda-forge pandas
RUN conda install --yes -c anaconda scikit-learn

RUN conda install --yes -n py2 -c conda-forge tensorflow
RUN conda install --yes -n py2 -c conda-forge matplotlib
RUN conda install --yes -n py2 -c conda-forge pandas
RUN conda install --yes -n py2 -c anaconda scikit-learn

#RUN \
#  conda install --yes \
#    'tensorflow' 
#    'ipywidgets=5.1*' \
#    'pandas=0.18*' \
#    'numexpr=2.5*' \
#    'matplotlib=1.5*' \
#    'scipy=0.17*' \
#    'seaborn=0.7*' \
#    'scikit-learn=0.17*' \
#    'scikit-image=0.11*' \
#    'sympy=1.0*' \
#    'cython=0.23*' \
#    'patsy=0.4*' \
#    'statsmodels=0.6*' \
#    'cloudpickle=0.1*' \
#    'dill=0.2*' \
#    'numba=0.23*' \
#    'bokeh=0.11*' \
#    'sqlalchemy=1.0*' \
#    'hdf5=1.8.17' \
#    'h5py=2.6*' \
#  && conda remove --quiet --yes --force qt pyqt \
#  && conda clean -tipsy

#RUN \ 
#  conda install --yes -n py3 \
#    'tensorflow' 
#    'ipywidgets=5.1*' \
#    'pandas=0.18*' \
#    'numexpr=2.5*' \
#    'matplotlib=1.5*' \
#    'scipy=0.17*' \
#    'seaborn=0.7*' \
#    'scikit-learn=0.17*' \
#    'scikit-image=0.11*' \
#    'sympy=1.0*' \
#    'cython=0.23*' \
#    'patsy=0.4*' \
#    'statsmodels=0.6*' \
#    'cloudpickle=0.1*' \
#    'dill=0.2*' \
#    'numba=0.23*' \
#    'bokeh=0.11*' \
#    'sqlalchemy=1.0*' \
#    'hdf5=1.8.17' \
#    'h5py=2.6*' \
#  && conda remove --quiet --yes --force qt pyqt \ 
#  && conda clean -tipsy

#RUN \
#  source activate py3 && conda install --yes -c conda-forge tensorflow

RUN \
  pip install jupyterhub \
  && pip install jupyterhub-dummyauthenticator

# Add guest account
RUN \
  adduser guest --gecos GECOS --disabled-password

WORKDIR /root

COPY run .
COPY jupyterhub_config.py .

ENV PYTHONPATH=$SPARK_HOME/python/:$PYTHONPATH
ENV PATH=$SPARK_HOME/bin:$PATH

EXPOSE 8764

CMD ["supervise", "."]
