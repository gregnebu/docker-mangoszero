FROM ubuntu:xenial

ENV DEBIAN_FRONTEND noninteractive

ARG user=mangos
ARG version=zero
ARG branch=master

RUN apt-get update && \
    apt-get -y install git curl ninja-build libbz2-dev libace-dev libssl-dev libmysqlclient-dev g++ cmake && \
    rm -rf /var/lib/apt/lists/*

RUN useradd -m -d /home/$user $user && \
    usermod -L $user && \
    mkdir -p "/home/$user/$version/src"

RUN git clone http://github.com/mangos${version}/server.git "/home/$user/$version/src/server" -b $branch --recursive

RUN mkdir -p /home/$user/$version/src/server/build && \
    cd /home/$user/$version/src/server/build && \
    cmake .. -GNinja -DDEBUG=0 -DACE_USE_EXTERNAL=1 -DPOSTGRESQL=0 -DBUILD_TOOLS=0 -DSCRIPT_LIB_ELUNA=1 -DSCRIPT_LIB_SD3=1 -DSOAP=0 -DPLAYERBOTS=1 -DCMAKE_INSTALL_PREFIX="/home/$user/$version" -DBUILD_REALMD=0 -DBUILD_MANGOSD=1 && \
    ninja install && \
    ninja clean

RUN chown $user: -R /home/$user && \
    cd /home/$user/$version/etc && \
    mv mangosd.conf.dist mangosd.conf && \
    mv aiplayerbot.conf.dist aiplayerbot.conf && \
    rm -f *.dist

RUN ln -s /home/$user/$version/bin/mangosd /usr/bin && \
    ln -s /home/$user/$version/etc /etc/mangos

EXPOSE 8085

CMD ["/usr/bin/mangosd", "-c", "/etc/mangos/mangosd.conf"]
