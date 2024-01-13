FROM ubuntu:20.04

ENV DISPLAY ":0"
ENV DEBIAN_FRONTEND noninteractive

# Updating and installing the necessary packages
RUN apt-get update && \
    apt-get install --no-install-recommends -y wget ca-certificates git fluxbox xfonts-base xauth x11-xkb-utils xkb-data dbus-x11 eterm python3 python3-pip supervisor

# Downloading and installing tigervncserver
RUN apt-get update && \
    apt-get install -y curl && \
    wget --no-check-certificate "https://sourceforge.net/projects/tigervnc/files/stable/1.13.1/ubuntu-20.04LTS/$(dpkg --print-architecture)/tigervncserver_1.13.1-1ubuntu1_$(dpkg --print-architecture).deb" && \
    apt-get install -y ./tigervncserver_*.deb && \
    rm tigervncserver_*.deb

# Installing Python packages
RUN pip3 install -U setuptools wheel && \
    pip3 install -U git+https://github.com/devrt/websockify.git && \
    apt-get remove -y python3-pip && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Setting up noVNC
RUN mkdir /novnc && \
    wget -qO- "http://github.com/novnc/noVNC/tarball/master" | tar -zx --strip-components=1 -C /novnc

COPY . /app
RUN cp /app/index.html /novnc/

VOLUME /tmp/.X11-unix
EXPOSE 80

CMD ["supervisord", "-c", "/app/supervisord.conf"]
