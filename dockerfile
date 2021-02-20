FROM debian:buster-slim AS steam

LABEL maintener="Cyril TAVIAN <c.tavian@outlook.fr>"

RUN useradd -u 1000 -m steam \
    && apt update \
    && apt install -y gdb curl lib32gcc1 libc++-dev \ 
    && mkdir ~steam/Steam && cd ~steam/Steam && curl -sqL "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz" | tar zxvf - \ 
    && chown -R steam ~steam/Steam

FROM steam AS pavlov

USER steam

RUN ~/Steam/steamcmd.sh +login anonymous +force_install_dir /home/steam/pavlovserver +app_update 622970 -beta shack +exit \
    && ~/Steam/steamcmd.sh +login anonymous +app_update 1007 +quit \
    && mkdir -p ~/Steam/sdk64 \
    && cp ~steam/Steam/steamapps/common/Steamworks\ SDK\ Redist/linux64/steamclient.so ~/Steam/sdk64/steamclient.so \
    && cp ~steam/Steam/steamapps/common/Steamworks\ SDK\ Redist/linux64/steamclient.so ~/pavlovserver/Pavlov/Binaries/Linux/steamclient.so \
    && mkdir -p /home/steam/pavlovserver/Pavlov/Saved/Logs \
    && mkdir -p /home/steam/pavlovserver/Pavlov/Saved/Config/LinuxServer \
    && mkdir -p /home/steam/pavlovserver/Pavlov/Saved/maps

COPY --chown=steam configuration/Game.ini /home/steam/pavlovserver/Pavlov/Saved/Config/LinuxServer/Game.ini
COPY --chown=steam configuration/RconSettings.txt /home/steam/pavlovserver/Pavlov/Saved/Config/RconSettings.txt

EXPOSE 8177

CMD ["/bin/bash", "/home/steam/pavlovserver/PavlovServer.sh"]
