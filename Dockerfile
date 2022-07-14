ARG NUXEO_VERSION
FROM ucldc/nuxeo-base:${NUXEO_VERSION}

ARG UCLDC_CONF=./ucldc.conf
COPY $UCLDC_CONF /etc/nuxeo/conf.d/ucldc.conf

# install packages
ARG CLID
ARG CONNECT_URL=https://connect.nuxeo.com/nuxeo/site/
RUN /install-packages.sh --clid ${CLID} --connect-url ${CONNECT_URL} \
    amazon-s3-online-storage \
    nuxeo-drive \
    nuxeo-platform-3d-jsf-ui \
    nuxeo-quota \
    nuxeo-virtualnavigation

# become root
USER 0

# install blender v2.78
RUN yum -y install curl \
    bzip2 \
    mesa-libGLU
ENV BLENDER_BZ2_URL https://download.blender.org/release/Blender2.78/blender-2.78-linux-glibc219-x86_64.tar.bz2
WORKDIR /usr/local/blender
RUN curl -SL "$BLENDER_BZ2_URL" -o blender.tar.bz2
RUN tar -xvf blender.tar.bz2 --strip-components=1
RUN rm blender.tar.bz2
WORKDIR /

# install collada2gltf (current version)
RUN yum -y install \
    git \
    epel-release cmake3 \
    make \
    gcc-c++
WORKDIR /usr/local/collada2gltf
RUN git clone --recursive https://github.com/KhronosGroup/COLLADA2GLTF.git .
RUN mkdir build
RUN cmake3 .
RUN make install
RUN cp COLLADA2GLTF-bin /usr/local/bin/collada2gltf
WORKDIR /

# install docker override script
RUN yum install -y python3
ENV OVERRIDE_SCRIPTS_DIR /usr/local/bin/override_scripts
WORKDIR $OVERRIDE_SCRIPTS_DIR
COPY --chown=900:0 ./files/docker-override/docker_override.py .
COPY ./files/docker-override/docker_cmd.sh /usr/bin/docker
RUN chmod +x /usr/bin/docker
WORKDIR /

# create dirs for 3D processing
WORKDIR /var/lib/3d
RUN chown 900:0 .
RUN mkdir in
RUN chown 900:0 in
RUN mkdir out
RUN chown 900:0 out

# set back original user
USER 900

