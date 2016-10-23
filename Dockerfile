FROM mechatronics3d/jcontrolengine_base
MAINTAINER Behzad Samadi <behzad@mechatronics3d.com>

USER root

ENV JM_PKGS="cython jcc subversion ant openjdk-7-jdk python-dev python-svn python-lxml python-nose zlib1g-dev libboost-dev dpkg-dev build-essential libwebkitgtk-dev libjpeg-dev libtiff-dev libgtk2.0-dev libsdl1.2-dev libgstreamer-plugins-base0.10-dev libnotify-dev freeglut3 freeglut3-dev"

# Install required packages
RUN apt-get update && \
    apt-get install -y --install-recommends $JM_PKGS

RUN pip install --upgrade --trusted-host wxpython.org --pre -f http://wxpython.org/Phoenix/snapshot-builds/ wxPython_Phoenix

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
ENV CPPAD_HOME=$JMODELICA_HOME/ThirdParty/CppAD/
ENV SUNDIALS_HOME=$JMODELICA_HOME/ThirdParty/Sundials
ENV PYTHONPATH=:$JMODELICA_HOME/Python::$PYTHONPATH
ENV LD_LIBRARY_PATH=:$IPOPT_HOME/lib/:$SUNDIALS_HOME/lib:$JMODELICA_HOME/ThirdParty/CasADi/lib:$LD_LIBRARY_PATH
ENV SEPARATE_PROCESS_JVM=/usr/lib/jvm/java-7-openjdk-amd64/

RUN chown -R $NB_USER $DL

RUN chown -R $NB_USER $WS

USER $NB_USER
