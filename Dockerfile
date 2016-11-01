FROM tristansalles/labs-dependencies:latest

MAINTAINER Tristan Salles

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

CMD jupyter notebook --ip=0.0.0.0 --no-browser
