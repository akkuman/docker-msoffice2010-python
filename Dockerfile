FROM tobix/wine:stable AS finally
MAINTAINER Akkuman "Akkuman<akkumans@qq.com> (https://hacktech.cn)"

ARG DEBIAN_FRONTEND=noninteractive

ENV LANG='C.UTF-8' \
    LC_ALL='C.UTF-8' \
    WINEDEBUG=-all \
    WINEPREFIX=/opt/wineprefix \
    WINEARCH=win32

WORKDIR /root

RUN apt-get update && \
    apt-get install -y cabextract && \
    apt autoremove -y && \
    apt clean -y && \
    rm -rf /var/lib/apt/lists/* && \
    rm -fr /tmp/*

# umask 0 for permissions
RUN umask 0 && \
    # download python
    curl -o /root/python-3.7.9.exe -L https://www.python.org/ftp/python/3.7.9/python-3.7.9.exe && \
    # download winetricks
    curl -o /root/winetricks -L https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks && \
    chmod +x winetricks && \
    # download office2010 3in1
    curl -o /root/xb21cn.com_Office2010_4in1_20210124.tgz -L https://github.com/akkuman/docker-msoffice2010-python/releases/download/v0.0/xb21cn.com_Office2010_4in1_20210124.tgz && \
    tar zxvf /root/xb21cn.com_Office2010_4in1_20210124.tgz && \
    rm -rf /root/xb21cn.com_Office2010_4in1_20210124.tgz && \
    # install deps, ref: https://github.com/Winetricks/winetricks/issues/1236
    mkdir -p ~/.cache/wine && \
    curl -o ~/.cache/wine/wine-mono-7.0.0-x86.msi -L https://dl.winehq.org/wine/wine-mono/7.0.0/wine-mono-7.0.0-x86.msi && \
    curl -o ~/.cache/wine/wine-gecko-2.47.2-x86.msi -L http://dl.winehq.org/wine/wine-gecko/2.47.2/wine-gecko-2.47.2-x86.msi && \
    xvfb-run /root/winetricks riched20 gdiplus msxml6 mspatcha mfc100 -q && \
    # install office2010, https://www.xb21cn.com/267.html
    xvfb-run winecfg -v winxp && \
    curl -o /opt/wineprefix/drive_c/windows/Fonts/simsun.ttc -L https://github.com/akkuman/docker-msoffice2010-python/releases/download/v0.0/simsun.ttc && \
    xvfb-run wine /root/Office2010_4in1_20210124.exe /S && \
    # install python
    xvfb-run winecfg -v win7 && \
    xvfb-run wine /root/python-3.7.9.exe /quiet InstallAllUsers=1 PrependPath=1 Include_doc=0 && \
    # ensure the normal running of office2010
    xvfb-run winecfg -v winxp && \
    # clean
    rm -rf /root/python-3.7.9.exe /root/winetricks /root/Office2010_4in1_20210124.exe ~/.cache/wine/wine-mono-7.0.0-x86.msi ~/.cache/wine/wine-gecko-2.47.2-x86.msi
