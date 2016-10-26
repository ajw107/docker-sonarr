FROM lsiobase/xenial
MAINTAINER sparklyballs

# set environment variables
ARG DEBIAN_FRONTEND="noninteractive"

#add extra environment settings
ENV CONFIG="/config"
ENV APPDIRNAME="NzbDrone"
ENV APP_ROOT="/opt"
ENV APP_OPTS="-nobrowser -data=${CONFIG}"
ENV APP_EXEC="NzbDrone.exe"
ENV APP_COMP="mono"
ENV REPOURL="http://apt.sonarr.tv/"
ENV REPOBRANCH="develop"

#make life easy for yourself
ENV TERM=xterm-color
# The horribly complex echo command is causing probelms, and docker
# is not telling me what the problem is, it would appear it's to do
# with having to start pairing up quotes once you run it through
# sh -c which needs you include yet another level of quotes around
# the whole command and rediversion.  This script helped immensly:
# http://unix.stackexchange.com/a/187452/197090
#still nit working, so just copying the file
#RUN ["/bin/echo", '#!/bin/bash\nls -alF --color=auto --group-directories-first --time-style=+"%H:%M:%S %d/%m/%Y" --block-size="\'\''1" $@ > /tmp/ll']
#RUN mv /tmp/ll /usr/bin/ll
COPY ll /usr/bin
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
	mono \
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
