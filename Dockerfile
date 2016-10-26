FROM lsiobase/xenial
MAINTAINER sparklyballs

# set environment variables
ARG DEBIAN_FRONTEND="noninteractive"

#add extra environment settings
ENV CONFIG="/config"
ENV APPDIRNAME="sonarr"
ENV APP_ROOT="/app"
ENV APP_OPTS="-nobrowser -data=${CONFIG}"
ENV APP_EXEC="NzbDrone.exe"
ENV APP_COMP="mono"
ENV REPOURL="http://apt.sonarr.tv/"
ENV REPOBRANCH="develop"

#make life easy for yourself
ENV TERM=xterm-color
RUN echo $'#!/bin/bash\nls -alF --color=auto --group-directories-first --time-style=+"%H:%M %d/%m/%Y" --block-size="\'1" $@' > /usr/bin/ll
RUN chmod +x /usr/bin/ll

ENV XDG_CONFIG_HOME="${CONFIG}/xdg"

# add sonarr repository
RUN \
 apt-key adv --keyserver keyserver.ubuntu.com --recv-keys FDA5DFFC && \
 echo "deb ${REPOURL} ${REPOBRANCH} main" > \
	/etc/apt/sources.list.d/sonarr.list && \

# install packages
 apt-get update && \
 apt-get install -y \
	libcurl3 \
	nzbdrone \
	nano && \

# cleanup
 apt-get clean && \
 rm -rf \
	/tmp/* \
	/var/lib/apt/lists/* \
	/var/tmp/*

# add local files
COPY root/ /

# ports and volumes
EXPOSE 8989
VOLUME "${CONFIG}" /mnt
