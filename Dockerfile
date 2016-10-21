FROM jupyter/datascience-notebook
MAINTAINER Behzad Samadi <behzad@mechatronics3d.com>

ENV CASADIVERSION=3.1.0-rc1

ENV DL=$HOME/Downloads

ENV WS=$HOME/work

ENV PKGS="wget unzip gcc g++ gfortran git cmake liblapack-dev pkg-config swig spyder time"
ENV Py2_PKGS="python-pip python-numpy python-scipy python-matplotlib"
ENV JM_PKGS="cython jcc subversion ant openjdk-6-jdk python-dev python-svn python-lxml python-nose zlib1g-dev libboost-dev dpkg-dev build-essential libwebkitgtk-dev libjpeg-dev libtiff-dev libgtk2.0-dev libsdl1.2-dev libgstreamer-plugins-base0.10-dev libnotify-dev freeglut3 freeglut3-dev"
ENV PIP2="jupyter vpython CVXcanon cvxpy"

# Install required packages
RUN apt-get update && \
    apt-get install -y --install-recommends $PKGS && \
    apt-get install -y --install-recommends $Py2_PKGS && \
    apt-get install -y --install-recommends $JM_PKGS

RUN pip install --upgrade pip

RUN pip install $PIP2

RUN pip install --upgrade --trusted-host wxpython.org --pre -f http://wxpython.org/Phoenix/snapshot-builds/ wxPython_Phoenix

# Install Ipopt for JModelica
RUN mkdir $DL
RUN wget http://www.coin-or.org/download/source/Ipopt/Ipopt-3.12.6.tgz -O $DL/Ipopt-3.12.6.tgz
RUN cd $DL && \
    tar -xvf Ipopt-3.12.6.tgz
RUN cd $DL/Ipopt-3.12.6/ThirdParty/ASL && ./get.ASL
RUN cd $DL/Ipopt-3.12.6/ThirdParty/Blas && ./get.Blas
RUN cd $DL/Ipopt-3.12.6/ThirdParty/Lapack && ./get.Lapack
RUN cd $DL/Ipopt-3.12.6/ThirdParty/Mumps && ./get.Mumps
RUN cd $DL/Ipopt-3.12.6/ThirdParty/Metis && ./get.Metis
RUN mkdir $DL/Ipopt-3.12.6/build
RUN cd $DL/Ipopt-3.12.6/build && \
    ../configure --prefix=$WS/Ipopt-3.12.6
RUN cd $DL/Ipopt-3.12.6/build && make install

# Install JPype
RUN cd $DL && \
    git clone https://github.com/originell/jpype.git && \
    cd jpype && python setup.py install

# Install JModelica
RUN cd $DL && mkdir JModelica.org && \ 
    svn co https://svn.jmodelica.org/trunk $DL/JModelica.org
RUN cd $DL/JModelica.org && \
    mkdir build && \
    cd build && \
    ../configure --prefix=$WS/JModelica.org \
             --with-ipopt=$WS/Ipopt-3.12.6 && \
    make install && \
    make casadi_interface

# Define environment variables for JModelica
ENV JAVA_HOME=/usr/lib/jvm/java-7-openjdk-amd64/
ENV JMODELICA_HOME=$WS/JModelica.org
ENV IPOPT_HOME=$WS/Ipopt-3.12.6
ENV CPPAD_HOME=$JMODELICA_HOME/ThirdParty/CppAD/
ENV SUNDIALS_HOME=$JMODELICA_HOME/ThirdParty/Sundials
ENV PYTHONPATH=:$JMODELICA_HOME/Python::$PYTHONPATH
ENV LD_LIBRARY_PATH=:$IPOPT_HOME/lib/:$SUNDIALS_HOME/lib:$JMODELICA_HOME/ThirdParty/CasADi/lib:$LD_LIBRARY_PATH
ENV SEPARATE_PROCESS_JVM=/usr/lib/jvm/java-7-openjdk-amd64/

RUN cd $WS && mkdir cvxpy && mkdir cvxflow

# Clone cvxpy
RUN git clone https://github.com/cvxgrp/cvx_short_course.git $WS/cvxpy

# Clone cvxflow
RUN git clone https://github.com/mwytock/cvxflow.git $WS/cvxflow

# Install CasADi 
RUN wget http://sourceforge.net/projects/casadi/files/CasADi/$CASADIVERSION/linux/casadi-py27-np1.9.1-v$CASADIVERSION.tar.gz/download \
    -O $DL/casadi-py27-np1.9.1-v$CASADIVERSION.tar.gz && \
    mkdir $WS/casadi-py27-np1.9.1-v$CASADIVERSION && \
    tar -zxvf $DL/casadi-py27-np1.9.1-v$CASADIVERSION.tar.gz \
    -C $WS/casadi-py27-np1.9.1-v$CASADIVERSION && \
    cd $WS/casadi-py27-np1.9.1-v$CASADIVERSION && mkdir build && cd build && \
    cmake -DWITH_PYTHON=ON ..

# Adding CasADi to PYTHONPATH
ENV PYTHONPATH=$PYTHONPATH:$WS/casadi-py27-np1.9.1-v$CASADIVERSION

# Install CasADi examples
RUN wget http://sourceforge.net/projects/casadi/files/CasADi/$CASADIVERSION/casadi-example_pack-v$CASADIVERSION.zip \
    -O $DL/casadi-example_pack-v$CASADIVERSION.zip && \
    mkdir $WS/casadi_examples && \
    unzip $DL/casadi-example_pack-v$CASADIVERSION.zip \
    -d $WS/casadi_examples
    
RUN chown -R $NB_USER $DL

RUN chown -R $NB_USER $WS

USER $NB_USER
