# https://doc.nuxeo.com/nxdoc/build-a-custom-docker-image/
ARG NUXEO_VERSION=latest
FROM docker-private.packages.nuxeo.com/nuxeo/nuxeo:${NUXEO_VERSION}

ARG NUXEO_CLID
# NUXEO_CLID needs to be set in container environment as this triggers registration
ENV NUXEO_CLID=${NUXEO_CLID}
ARG NUXEO_CUSTOM_PACKAGE
ARG DEV

# install CDL's nuxeo custom package
RUN if [[ -n "${NUXEO_CUSTOM_PACKAGE}" ]] ; then \
        /install-packages.sh --clid $NUXEO_CLID --connect-url https://connect.nuxeo.com/nuxeo/site/ \
        ${NUXEO_CUSTOM_PACKAGE} ; \
    fi

# install production-only packages
RUN if [[ ${DEV} != true ]]; then \
    /install-packages.sh --clid $NUXEO_CLID --connect-url https://connect.nuxeo.com/nuxeo/site/ \
    amazon-s3-online-storage ; \
fi

# install remaining nuxeo packages
RUN /install-packages.sh --clid $NUXEO_CLID --connect-url https://connect.nuxeo.com/nuxeo/site/ \
    nuxeo-jsf-ui \
    nuxeo-web-ui \
    nuxeo-drive \
    nuxeo-quota \
    nuxeo-quota-jsf-ui \
    nuxeo-virtualnavigation

# install system packages
USER 0
RUN dnf -y --allowerasing update \
   && dnf -y install epel-release \
   && dnf -y config-manager --set-enabled ol9_codeready_builder \
   && dnf -y config-manager --set-enabled ol9_developer_EPEL \
   && dnf -y install --nogpgcheck https://mirrors.rpmfusion.org/free/el/rpmfusion-free-release-9.noarch.rpm
# reinstall ImageMagick7, which was removed by dnf update
RUN dnf -y --enablerepo=remi --exclude=python3-setuptools install ImageMagick7
RUN dnf -y install ffmpeg \
    #GraphicsMagick \
    libreoffice \
    python3 \
    python3-pip \
    python3-setuptools \
    python3-pip-wheel
USER 900

# put client config script in place
WORKDIR /client_config
COPY client_config/templates/ ./templates/
COPY client_config/requirements.txt .
COPY --chmod=744 client_config/configure.py .
RUN pip install -r requirements.txt

# put docker entrypoint script in place
WORKDIR /
COPY --chown=900:0 --chmod=744 ./ucldc-docker-entrypoint.sh /ucldc-docker-entrypoint.sh

# create alias for `identify` command that points to GraphicsMagick's `identify`
# ImageMagick isn't available in Linux Oracle 9
#RUN echo 'alias identify="gm identify"' >> ~/.bashrc

# create java truststore for SASL authentication to MSK cluster
USER 0
RUN cp /usr/lib/jvm/jre/lib/security/cacerts /kafka.client.truststore.jks
USER 900

ENTRYPOINT ["/ucldc-docker-entrypoint.sh"]
CMD ["nuxeoctl", "console"]