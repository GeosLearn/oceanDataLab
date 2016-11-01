FROM tristansalles/usyd-uos-geos-base:v1.01

MAINTAINER Tristan Salles

# Install COVE model
COPY  COVE.zip /
RUN unzip -o /COVE.zip -d /COVE
  cd /COVE/COVE.0/driver_files && \
  make -f spiral_bay_make.make && \
  mv spiral_bay.out cove && \
  mv cove /usr/local/bin

# Install XBEACH model
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    automake \
    autoconf \
    libtool \
    shtool \
    autogen \
    mako \
    svn
    
RUN cd /usr/local && \
    svn checkout https://svn.oss.deltares.nl/repos/xbeach/trunk && \
    cd trunk && \
    sh autogen.sh && \
    ./configure --with-netcdf && \
    make
    sudo make install

# Install TRACPY
RUN git clone https://github.com/hetland/octant.git && \
    cd octant && \
    pip install --user . && \
    cd .. && \
    cp -r .local/lib/python2.7/site-packages/octant* /usr/lib/python2.7/dist-packages && \
    rm -r .local/lib/python2.7/site-packages/octant*

COPY  tools.py /
RUN git clone https://github.com/kthyng/tracpy.git && \
    cp tools.py tracpy/tracpy && \
    cd tracpy && \
    pip install --user . && \
    cd .. && \
    cp -r .local/lib/python2.7/site-packages/tracpy* /usr/lib/python2.7/dist-packages && \
    rm -r .local/lib/python2.7/site-packages/tracpy*

# Get debian base install and some unnecessary files, copy local data to workspace
RUN mkdir /workspace && \
    mkdir /workspace/volume

# Copy labs from github
RUN echo "!!!" && git clone https://github.com/GeosLearn/oceanDataLab.git /oceanData/ && \
    mv /oceanData/Lab/* /workspace

# expose notebook port
EXPOSE 8888

# setup space for working in
VOLUME /workspace/volume

# launch notebook
WORKDIR /workspace
EXPOSE 8888
ENTRYPOINT ["/usr/local/bin/tini", "--"]

CMD jupyter notebook --ip=0.0.0.0 --no-browser \
    --NotebookApp.default_url='StartHere.ipynb'
