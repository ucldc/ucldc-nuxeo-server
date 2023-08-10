# https://doc.nuxeo.com/nxdoc/build-a-custom-docker-image/
ARG NUXEO_VERSION
FROM docker-private.packages.nuxeo.com/nuxeo/nuxeo:${NUXEO_VERSION}

ARG CLID
ARG CONNECT_URL=https://connect.nuxeo.com/nuxeo/site/
ARG NUXEO_CUSTOM_PACKAGE
ARG UCLDC_CONF=./ucldc.conf

# put custom conf file in place
COPY $UCLDC_CONF /etc/nuxeo/conf.d/ucldc.conf

# install hotfixes
COPY --chown=900:0 ./files/install-hotfixes.sh /install-hotfixes.sh
RUN /install-hotfixes.sh --clid ${CLID} --connect-url ${CONNECT_URL}

# install packages
RUN /install-packages.sh --clid ${CLID} --connect-url ${CONNECT_URL} \
    ${NUXEO_CUSTOM_PACKAGE} \
    nuxeo-jsf-ui \
    nuxeo-platform-3d-jsf-ui \
    nuxeo-web-ui \
    amazon-s3-online-storage \
    nuxeo-drive \
    nuxeo-quota \
    nuxeo-quota-jsf-ui \
    nuxeo-virtualnavigation

# register
COPY ./instance.clid /var/lib/nuxeo/instance.clid

# become root
USER 0

# install ffmpeg
RUN yum -y localinstall --nogpgcheck https://mirrors.rpmfusion.org/free/el/rpmfusion-free-release-7.noarch.rpm
RUN yum -y install ffmpeg

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

# install collada2gltf v1.0-draft2
ENV GLTF_VERSION v1.0-draft2
RUN yum -y install \
    git \
    epel-release cmake3 \
    make \
    gcc-c++ \
    libpng-devel \
    libxml2-devel \
    pcre-devel \
    zlib-devel
WORKDIR /usr/local/collada2gltf
RUN git clone https://github.com/KhronosGroup/glTF.git .
RUN git checkout ${GLTF_VERSION}
RUN git submodule init
RUN git submodule update
WORKDIR /usr/local/collada2gltf/COLLADA2GLTF
RUN cmake3 .
RUN make install
RUN cp ./bin/collada2gltf /usr/local/bin/
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
WORKDIR /

# update packages
RUN yum update

# set back original user
USER 900