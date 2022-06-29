FROM ubuntu:20.04 AS downloader

ARG DEBIAN_FRONTEND=noninteractive
WORKDIR /root

RUN apt-get update \
    && apt-get install -y wget tar gzip
RUN wget -q https://github.com/akkuman/docker-msoffice2010-python/releases/download/v0.0/wine-python3.7.9-office2010.3in1.licensed.tgz \
    && tar zxf wine-python3.7.9-office2010.3in1.licensed.tgz



# reference: https://github.com/huan/docker-wine/blob/main/Dockerfile
FROM ubuntu:20.04 AS finally
LABEL maintainer="Akkuman<akkumans@qq.com> (https://hacktech.cn)"

ARG DEBIAN_FRONTEND=noninteractive

WORKDIR /root

ENV \
    LANG='C.UTF-8' \
    LC_ALL='C.UTF-8' \
    TZ=Asia/Shanghai \
    WINEPREFIX=/root/.wine-office2010 \
    WINEARCH=win32

ADD https://github.com/krallin/tini/releases/latest/download/tini /bin/tini

RUN chmod +x /bin/tini

RUN apt-get update \
    && apt-get install -y \
        # https://github.com/wszqkzqk/deepin-wine-ubuntu/issues/188#issuecomment-554599956
        # https://zj-linux-guide.readthedocs.io/zh_CN/latest/tool-install-configure/%5BUbuntu%5D%E4%B8%AD%E6%96%87%E4%B9%B1%E7%A0%81/
        ttf-wqy-microhei \
        ttf-wqy-zenhei \
        xfonts-wqy \
        \
        apt-transport-https \
        ca-certificates \
        cabextract \
        wget \
        gnupg2 \
        software-properties-common \
        tzdata \
        unzip \
        winbind \
        xvfb \
    && apt autoremove -y \
    && apt clean -y \
    && rm -rf /var/lib/apt/lists/* \
    && rm -fr /tmp/*

# https://wiki.winehq.org/Ubuntu
RUN dpkg --add-architecture i386 \
    && wget -nc https://dl.winehq.org/wine-builds/winehq.key && mv winehq.key /usr/share/keyrings/winehq-archive.key \
    && wget -nc https://dl.winehq.org/wine-builds/ubuntu/dists/focal/winehq-focal.sources && mv winehq-focal.sources /etc/apt/sources.list.d/ \
    && apt-get update \
    && apt-get install -y \
        winehq-stable \
    && apt autoremove -y \
    && apt clean -y \
    && rm -rf /var/lib/apt/lists/* \
    && rm -fr /tmp/*

COPY --from=downloader /root/.wine-office2010 /root/.wine-office2010

RUN chown root:root /root/.wine-office2010

# hide all debug info
ENV WINEDEBUG=-all
