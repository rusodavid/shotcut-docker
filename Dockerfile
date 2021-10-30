FROM nvidia-gui-app:latest

#
# Update repos and install dependencies
#
RUN set -e \
&&  apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends --yes \
    libavcodec-extra \
    libasound2 \
    libpulse0 \
    xz-utils \
    libcairo-gobject2 \
    libcairo2 \
    libcanberra-gtk-module \
    libcanberra-gtk3-module \
    libgcc1 \
    libgl1 \
    libglib2.0-0 \
    libpango-1.0-0 \
    libpangocairo-1.0-0 \
    libx11-xcb1 \
    libxcb-shm0 \
    libxcomposite1 \
    libxdamage1 \
    libxfixes3 \
    libxrender1 \
    libxt6 \
    libjack-jackd2-0 \ 
    netsurf-common \
    xdg-utils \
    libxcb-icccm4 \
    libxcb-image0 \
    libxcb-keysyms1 \
    libxcb-render-util0 \
    libxcb-xinerama0 

RUN apt-get update \
  && apt-get install -y -qq --no-install-recommends \
    libglvnd0 \
    libgl1 \
    libglx0 \
    libegl1 \
    libxext6 \
    libx11-6 


#
# Add mimetypes
#
RUN mkdir -p /usr/share/applications \
&&  printf '%s\n' \
    "[MIME Cache]" \
    "text/html=netsurf-gtk.desktop;" \
    "text/xml=netsurf-gtk.desktop;" \
    "x-scheme-handler/http=netsurf-gtk.desktop;" \
    "x-scheme-handler/https=netsurf-gtk.desktop;" > /usr/share/applications/mimeinfo.cache \
#
# Clean-up
#
&&  rm --recursive --force \
    /usr/share/doc/* \
    /usr/share/man/* \
    /var/cache/apt/archives/*.deb \
    /var/cache/apt/archives/partial/*.deb \
    /var/cache/apt/*.bin \
    /var/cache/debconf/*.old \
    /var/lib/apt/lists/* \
    /var/lib/dpkg/info/* \
    /var/log/apt \
    /var/log/*.log 
#
# Install application
#
RUN  appverdot=$( curl --location --silent --url https://shotcut.org/download/ | grep linux | \
    perl -nle 'print "${1}" if /Recommended Stable Version: (\K[^<]+)/' ) \
&&  appver=$( echo "${appverdot}" | tr -d . ) \
&&  echo https://github.com/mltframework/shotcut/releases/download/v"${appverdot}"/shotcut-linux-x86_64-"${appver}".txz \
&&  curl --location --silent --url \
    https://github.com/mltframework/shotcut/releases/download/v"${appverdot}"/shotcut-linux-x86_64-"${appver}".txz | \
    tar --extract --xz --directory /opt \
&&  chown --recursive "${uid}:${gid}" /opt/Shotcut
#

#RUN setenv QT_DEBUG_PLUGINS=1 

RUN groupadd -r shotcut && useradd -r -g shotcut -G audio,video shotcut \
    && mkdir -p /home/shotcut/Downloads \
    && chown -R shotcut:shotcut /home/shotcut

#ENTRYPOINT [ "/bin/bash"]
ENTRYPOINT [ "/opt/Shotcut/Shotcut.app/shotcut" ]
