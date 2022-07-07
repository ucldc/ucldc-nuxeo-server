# https://doc.nuxeo.com/nxdoc/build-a-custom-docker-image/
ARG NUXEO_VERSION

FROM docker-private.packages.nuxeo.com/nuxeo/nuxeo:${NUXEO_VERSION}

ARG CLID
ARG CONNECT_URL=https://connect.nuxeo.com/nuxeo/site/
ARG NUXEO_CUSTOM_PACKAGE

COPY --chown=900:0 ./install-hotfixes.sh /install-hotfixes.sh
RUN /install-hotfixes.sh --clid ${CLID} --connect-url ${CONNECT_URL}

RUN /install-packages.sh --clid ${CLID} --connect-url ${CONNECT_URL} \
    ${NUXEO_CUSTOM_PACKAGE} \
    amazon-s3-online-storage \
    nuxeo-drive \
    nuxeo-jsf-ui \
    nuxeo-platform-3d-jsf-ui \
    nuxeo-quota \
    nuxeo-virtualnavigation \
    nuxeo-web-ui

# register
COPY ./instance.clid /var/lib/nuxeo/instance.clid

COPY ./ucldc.conf /etc/nuxeo/conf.d/ucldc.conf

# become root
USER 0

# install ffmpeg
RUN yum -y localinstall --nogpgcheck https://mirrors.rpmfusion.org/free/el/rpmfusion-free-release-7.noarch.rpm
RUN yum -y install ffmpeg

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
COPY --chown=900:0 ./override_scripts/docker_override.py .
COPY ./docker_cmd.sh /usr/bin/docker
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
COPY --chown=900:0 ./blender_scripts/ .
WORKDIR /

# set back original user
USER 900
