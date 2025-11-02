FROM base

# -- Layer: Notebooks and data

ADD workspace/ ${SHARED_WORKSPACE}/

# -- Layer: JupyterLab + Python kernel for PySpark

ARG spark_version
ARG jupyterlab_version

RUN pip3 install --upgrade pip && \
    pip3 install wget==3.2 pyspark==${spark_version} jupyterlab==${jupyterlab_version}

# -- Layer: Create non-privileged user

# Create jovyan user with UID 1000 and home directory
RUN useradd -m -u 1000 -s /bin/bash jovyan && \
    # Set ownership of shared workspace to jovyan
    chown -R jovyan:jovyan "${SHARED_WORKSPACE}" && \
    # Set ownership of Jupyter config directory
    mkdir -p /home/jovyan/.jupyter && \
    chown -R jovyan:jovyan /home/jovyan/.jupyter && \
    # Remove sudo capabilities (if installed) for jovyan
    if command -v sudo >/dev/null 2>&1; then \
        deluser jovyan sudo 2>/dev/null || true; \
    fi && \
    # Restrict write access to dpkg database (prevent apt/dpkg)
    chmod 755 /var/lib/dpkg 2>/dev/null || true

# -- Runtime

EXPOSE 8888

# Switch to non-privileged user
USER jovyan

WORKDIR ${SHARED_WORKSPACE}

# Default token value (can be overridden via environment variable)
ENV JUPYTER_TOKEN=""

# Start JupyterLab with token authentication from environment variable
CMD jupyter lab --ip='*' --port=8888 --no-browser --ServerApp.token="${JUPYTER_TOKEN}"
