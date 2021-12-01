FROM debian:stable-slim


# Prepare build arguments
ARG NODE_VERSION=v12.16.1
ARG NPM_CONFIG_LOGLEVEL=info
ARG NEWMAN_HOME=/opt/newman

# Provide environments
ENV NODE_HOME=/opt/nodejs

# Install tools + purge all the things
RUN apt-get update && apt-get install -y \
    apt-transport-https \
    ca-certificates \
    wget \
    --no-install-recommends \
    && apt-get purge \
    && rm -rf /var/lib/apt/lists/*

# Install Node
RUN echo "[INFO] Install Node $NODE_VERSION." && \
    mkdir -p "${NODE_HOME}" && \
    mkdir -p "${NEWMAN_HOME}" && \
    wget -qO- "http://nodejs.org/dist/${NODE_VERSION}/node-${NODE_VERSION}-linux-x64.tar.gz" | tar -xzf - -C "${NODE_HOME}" && \
    ln -s "${NODE_HOME}/node-${NODE_VERSION}-linux-x64/bin/node" /usr/local/bin/node && \
    ln -s "${NODE_HOME}/node-${NODE_VERSION}-linux-x64/bin/npm" /usr/local/bin/npm && \
    ln -s "${NODE_HOME}/node-${NODE_VERSION}-linux-x64/bin/npx" /usr/local/bin/ && \
    # Install newman
    npm i -g newman && \
    ln -s "${NODE_HOME}/node-${NODE_VERSION}-linux-x64/bin/newman" /usr/local/bin/newman

# Create user inside container
RUN echo "[INFO] handle users permission." && \
    # Handle users permission
    useradd --home-dir "${NEWMAN_HOME}" --create-home --shell /bin/bash --user-group --uid 1000 --comment 'Newman CLI user' --password "$(echo HeyLuke |openssl passwd -1 -stdin)" newman && \
    # Allow anybody to write into the images HOME
    chmod a+w "${NEWMAN_HOME}"

USER newman