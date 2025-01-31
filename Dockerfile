# https://doc.nuxeo.com/nxdoc/build-a-custom-docker-image/
ARG NUXEO_VERSION=latest
FROM docker-private.packages.nuxeo.com/nuxeo/nuxeo:${NUXEO_VERSION}

ARG NUXEO_CLID
ENV NUXEO_CLID=${NUXEO_CLID}
ARG NUXEO_CUSTOM_PACKAGE
ENV NUXEO_CUSTOM_PACKAGE=${NUXEO_CUSTOM_PACKAGE}
ARG DEV
ENV DEV=${DEV}

# install CDL's nuxeo custom package
RUN if [[ -n $NUXEO_CUSTOM_PACKAGE ]] ; then \
        /install-packages.sh --clid $NUXEO_CLID --connect-url https://connect.nuxeo.com/nuxeo/site/ \
        $NUXEO_CUSTOM_PACKAGE ; \
    fi

# install production-only packages
RUN if [ $DEV != "true" ]; then \
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

# install ffmpeg
USER 0
RUN dnf -y --allowerasing update \
   && dnf -y install epel-release \
   && dnf -y config-manager --set-enabled ol9_codeready_builder \
   && dnf -y config-manager --set-enabled ol9_developer_EPEL \
   && dnf -y install --nogpgcheck https://mirrors.rpmfusion.org/free/el/rpmfusion-free-release-9.noarch.rpm
RUN dnf -y install ffmpeg
USER 900

# put docker entrypoint script in place
COPY --chown=900:0 --chmod=744 ./docker-entrypoint.sh /cdl-docker-entrypoint.sh

ENTRYPOINT ["/cdl-docker-entrypoint.sh"]
CMD ["nuxeoctl", "console"]