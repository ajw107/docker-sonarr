#FROM lsiobase/xenial
FROM lsiobase/mono:bionic
MAINTAINER sparklyballs, ajw107 (Alex Wood)

# environment settings
SHELL ["/bin/bash", "-c"]
ARG DEBIAN_FRONTEND="noninteractive"
ARG PROG_NAME="SONARR"
ARG PROG_VER
ARG VERSION_FILE_LOCATION=/VERSION/${PROG_NAME}_VER

#add extra environment settings
ENV VERSION_FILE=${VERSION_FILE_LOCATION}
ENV CONFIG="/config"
ENV APPDIRNAME="sonarr/bin"
ENV APP_ROOT="/usr/lib/"
ENV APP_OPTS="-nobrowser -data=${CONFIG}"
ENV APP_EXEC="Sonarr.exe"
ENV APP_COMP="mono"
ENV APP_COMP_OPTS="--debug"
ENV SONARRREPOURL="https://apt.sonarr.tv/debian"
ENV SONARRREPOBRANCH="stretch-develop"
ENV XDG_CONFIG_HOME="${CONFIG}/xdg"
#ENV MONOREPOBRANCH="stable-bionic"
#The variable below needs removing as soon as apt-key has been fully depreciated and replaced by something else
ENV APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=DontWarn

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
COPY get_version /get_version
COPY root/ /
RUN chmod +x /usr/bin/ll
VOLUME /VERSION

# install packages
#The apt-key code below needs changing as soon as apt-key has been fully depreciated and replaced by something else
RUN \
  #I'd rather use just apt as it won;t error out when organisations change their name (ie. google chrome), etc
  apt-get update && \
  apt-get install -y jq wget apt-transport-https  gnupg && \
  #echo "**** add mono repository ****" && \
  #apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF && \
  #echo "deb https://download.mono-project.com/repo/ubuntu ${MONOREPOBRANCH} main" | \
  #     tee /etc/apt/sources.list.d/mono-official-stable.list  && \
  echo "**** add mediainfo repository ****" && \
  wget https://mediaarea.net/repo/deb/repo-mediaarea_1.0-12_all.deb && \
  dpkg -i repo-mediaarea_1.0-12_all.deb && \
  echo "**** add sonarr repository ****" && \
  #apt-key adv --keyserver keyserver.ubuntu.com --recv-keys FDA5DFFC && \
  apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 2009837CBFFD68F45BC180471F4F90DE2A9B4BF8 && \
  echo "deb ${SONARRREPOURL} ${SONARRREPOBRANCH} main" > \
         /etc/apt/sources.list.d/sonarr.list
RUN \
  #I'd rather use just apt as it won;t error out when organisations change their name (ie. google chrome), etc
  apt-get update && \
  apt-get install -y \
    mediainfo \
    sqlite3 \
    nano \
    sonarr
#    nzbdrone
#    libmono-cil-dev \

#RUN sonarrVer=`apt-cache policy nzbdrone | grep Installed: | tr -d '[:space:]' | sed -e 's/^\w*:\ *//'`
#RUN apt-cache policy nzbdrone | grep Installed: | tr -d '[:space:]' | sed -e 's/^\w*:\ *//'>/VERSIONS/SONARR_VER
#RUN echo "$(curl -sX GET https://services.sonarr.tv/v1/download/phantom-develop | jq -r '.version')" > "/VERSION/${PROG_NAME}_VER"

#No reason to do this in the dockerfile, as docker run is required to add the bind mount to the VERSION volume
RUN \
  if [ -z ${PROG_VER+x} ]; \
  then \
       #PROG_VER gets set in get_version, hence why we source it rather than just run it
       #mounting the /VERSION volume before this code also is necessary for this
       source /get_version; \
       #declare PROG_VER=$(cat "/VERSION/${PROG_NAME}_VER"); \
#       echo "Cat:"; \
#       cat "/VERSION/${PROG_NAME}_VER"; \
#       echo "PROG_VER: [${PROG_VER}]"; \
  else \
       echo "PROG_VER set by build ARG: [${PROG_VER}]"; \
  fi && \
  echo "${PROG_NAME} Ver: [${PROG_VER}]" && \
  echo "UpdateMethod=docker\nBranch=${SONARR_BRANCH}\nPackageVersion=${PROG_VER}\nPackageAuthor=Alex Wood" > /usr/lib/sonarr/package_info

#LABEL build_version=${PROG_VER}

RUN \
# cleanup
  apt-get clean && \
  rm -rf \
    /tmp/* \
    /var/lib/apt/lists/* \
    /var/tmp/*

# ports and volumes
EXPOSE 8989
VOLUME "${CONFIG}" /mnt
