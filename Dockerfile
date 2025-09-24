# UID0, GID0:root, UID1000:node, GID1000:node
# /usr - system-wide dirs
# /home - personal home dirs
FROM node:24-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    less \
    zsh \
    && rm -rf /var/lib/apt/lists/*

# create npm-global in system-wide and chown so non-root can install packages there
RUN mkdir -p /usr/local/share/npm-global && \
    chown -R node:node /usr/local/share

ARG USERNAME=node
# exit root
USER node

# change runtime variables so npm installs in npm-global (non-root) instead of /usr/lib/node-modules (root)
ENV NPM_CONFIG_PREFIX=/usr/local/share/npm-global
# add subsequent package executables to PATH
ENV PATH=$PATH:/usr/local/share/npm-global/bin

# COPY <host build context> <container filesystem>
# image slimming
COPY dist/personal.tgz personal.tgz
RUN npm install -g personal.tgz \
    && npm cache clean --force \
    && rm -rf /usr/local/share/npm-global/lib/node_modules/personal-cli/node_modules/.cache \