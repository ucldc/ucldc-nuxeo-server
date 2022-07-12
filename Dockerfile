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

# install blender v3.2.0 - precompiled binary available
# Nuxeo plugin uses blender 2.78, for which no precompiled binary is available
RUN yum -y install curl
ENV BLENDER_XZ_URL https://download.blender.org/release/Blender3.2/blender-3.2.0-linux-x64.tar.xz
WORKDIR /usr/local/blender
RUN curl -SL "$BLENDER_XZ_URL" -o blender.tar.xz
RUN tar -Jxvf blender.tar.xz --strip-components=1
RUN rm blender.tar.xz
WORKDIR /

# install collada2gltf
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
ENV OVERRIDE_SCRIPTS_DIR /usr/local/bin/override_scripts/
WORKDIR $OVERRIDE_SCRIPTS_DIR
COPY --chown=900:0 ./files/docker-override/docker_override.py .
COPY ./files/docker-override/docker_cmd.sh /usr/bin/docker
RUN chmod +x /usr/bin/docker
WORKDIR /

# create directories for 3D in/out files and blender pipeline scripts
RUN mkdir /var/lib/3d/
RUN chown 900:0 /var/lib/3d/
RUN mkdir /var/lib/3d/in
RUN chown 900:0 /var/lib/3d/in
RUN mkdir /var/lib/3d/out
RUN chown 900:0 /var/lib/3d/out

# install modified blender pipeline scripts
ENV PIPELINE_SCRIPTS_DIR /usr/local/bin/pipeline_scripts/
WORKDIR $PIPELINE_SCRIPTS_DIR
COPY --chown=900:0 ./files/blender/ .
WORKDIR /

# set back original user
USER 900
