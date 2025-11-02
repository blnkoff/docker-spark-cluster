ARG debian_buster_image_tag=17-jdk-slim
FROM openjdk:${debian_buster_image_tag}

# -- Layer: OS + Python 3.13

ARG shared_workspace=/opt/workspace
ARG PYTHON_VERSION=3.13.0

RUN mkdir -p ${shared_workspace}/data && \
    mkdir -p /usr/share/man/man1 && \
    apt-get update -y && \
    apt-get install -y curl wget build-essential libssl-dev zlib1g-dev \
        libbz2-dev libreadline-dev libsqlite3-dev libncursesw5-dev \
        libffi-dev liblzma-dev r-base && \
    wget https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tgz && \
    tar -xf Python-${PYTHON_VERSION}.tgz && \
    cd Python-${PYTHON_VERSION} && \
    ./configure --enable-optimizations --with-ensurepip=install && \
    make -j $(nproc) && \
    make altinstall && \
    cd .. && \
    rm -rf Python-${PYTHON_VERSION} Python-${PYTHON_VERSION}.tgz && \
    PYTHON_MAJOR_MINOR=$(echo ${PYTHON_VERSION} | cut -d. -f1,2) && \
    ln -sf /usr/local/bin/python${PYTHON_MAJOR_MINOR} /usr/bin/python3 && \
    ln -sf /usr/local/bin/python${PYTHON_MAJOR_MINOR} /usr/bin/python && \
    ln -sf /usr/local/bin/pip${PYTHON_MAJOR_MINOR} /usr/bin/pip3 && \
    ln -sf /usr/local/bin/pip${PYTHON_MAJOR_MINOR} /usr/bin/pip && \
    apt-get remove -y wget build-essential && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*

ENV SHARED_WORKSPACE=${shared_workspace}

# -- Runtime

VOLUME ${shared_workspace}
CMD ["bash"]
