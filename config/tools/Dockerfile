##################################################################################################################################################
# LICENSE
# This Dockerfile is provided under the LICENSE defined in the Github repository
# at https://github.com/SAP-samples/btp-setup-automator
##################################################################################################################################################
# STARTING WITH ALL THE SAP TOOLS FIRST
##################################################################################################################################################
FROM --platform=linux/amd64 alpine:3 AS base
ENV ARCH=linux-amd64
ENV TOOLS_URL=tools.hana.ondemand.com
ENV CPCLI_URL=cpcli.cf.eu10.hana.ondemand.com

## Install necessary packages to donwload and install tools
RUN echo "http://dl-4.alpinelinux.org/alpine/latest-stable/community" >> /etc/apk/repositories \
    && apk update \
    && apk upgrade \
    && apk add --no-cache curl jq \
    && update-ca-certificates

##########################################################################################
# Retrieve the CloudFoundry CLI
##########################################################################################
FROM --platform=linux/amd64 cloudfoundry/cli:8.6.1 as cf_cli

##########################################################################################
## Retrieve the SAP btp CLI
## Latest is always at https://tools.hana.ondemand.com/additional/btp-cli-linux-amd64-latest.tar.gz
## Currently we look at https://cpcli.cf.eu10.hana.ondemand.com/actuator/info to find out what the
## latest supported version on the server side is and use that, specifically.
##########################################################################################
FROM base AS btp_cli
SHELL ["/bin/ash", "-eo", "pipefail", "-c"]
WORKDIR /tmp/tools

RUN BTP_CLI_VERSION="2.38.0" \
  && curl --fail --silent --location --cookie eula_3_1_agreed="$TOOLS_URL/developer-license-3_1.txt" \
    --url "https://$TOOLS_URL/additional/btp-cli-$ARCH-$BTP_CLI_VERSION.tar.gz" \
    | tar -xzf - --strip-components 1 "$ARCH/btp"

########################################################################################
# Retrieve the MTA build tool
########################################################################################
FROM base AS mta_build_tool
SHELL ["/bin/ash", "-eo", "pipefail", "-c"]
WORKDIR /tmp/tools
RUN MBT_VERSION="1.2.23" \
  && curl --fail --silent --location --url "https://github.com/SAP/cloud-mta-build-tool/releases/download/v${MBT_VERSION}/cloud-mta-build-tool_${MBT_VERSION}_Linux_amd64.tar.gz" \
    | tar -xzf - mbt

########################################################################################
# Add some utilities
########################################################################################
FROM base as utilities
SHELL ["/bin/ash", "-eo", "pipefail", "-c"]
WORKDIR /tmp/tools
ENV VER_FX=24.1.0
ENV VER_IJQ=0.4.1
RUN curl -fsSL -o fx --url "https://github.com/antonmedv/fx/releases/download/${VER_FX}/fx_${ARCH//-/_}" \
  && chmod +x fx
RUN curl -fsSL --url "https://git.sr.ht/~gpanders/ijq/refs/download/v${VER_IJQ}/ijq-${VER_IJQ}-${ARCH}.tar.gz" \
  | tar --extract -z --file - --strip-components 1 "ijq-${VER_IJQ}/ijq"

########################################################################################
# Bring the tools together into the final base stage
########################################################################################
FROM --platform=linux/amd64 alpine:3 as tools
WORKDIR /usr/local/bin
COPY --from=cf_cli                 /usr/local/bin/cf8  .
COPY --from=btp_cli                /tmp/tools/         .
COPY --from=mta_build_tool         /tmp/tools/         .
COPY --from=utilities              /tmp/tools/         .
ARG BTPSA_VERSION_GIT_ARG=default

##################################################################################################################################################
# Now putting all pieces together
##################################################################################################################################################
FROM --platform=linux/amd64 python:3.10-alpine3.16 AS final_build
ENV USERNAME=user
ENV HOME_FOLDER /home/$USERNAME
ENV CONTAINER_NAME=btp-tooling

# Add config folders according to https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html
ENV XDG_CONFIG_HOME=$HOME_FOLDER/.config
ENV XDG_DATA_HOME=$HOME_FOLDER/.local/share
ENV XDG_STATE_HOME=$HOME_FOLDER/.local/state

ENV CF_HOME=$XDG_CONFIG_HOME/cf
ENV BTP_CLIENTCONFIG=$XDG_CONFIG_HOME/btp/config.json

RUN adduser \
    --disabled-password \
    --gecos "" \
    --home "$HOME_FOLDER" \
    "$USERNAME" \
    && apk update \
    && apk upgrade \
    && apk add --no-cache \
               bash \
               coreutils \
               curl \
               git \
               jq \
               make \
               nodejs \
               npm \
               sudo \
               libc6-compat \
    && rm -rf /tmp/pip-tmp \
    ## Set the right timezone in the container image
    && cp /usr/share/zoneinfo/Europe/Berlin /etc/localtime \
##########################################################################################
# Install CAP CDS
# - currently (Jun 7th, 2022) it's no longer possible to install CDS
# - to be determined what the root cause is (seems related to deprecation of v1.x Cloud SDK)
##########################################################################################
    && npm install -g @sap/cds-dk --allow-root \
    && npm cache clean --force \
##########################################################################################
# Add user to sudo user
##########################################################################################
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME

##########################################################################################
# Fill the image with the necessary resources
##########################################################################################
USER $USERNAME
WORKDIR $HOME_FOLDER

## Copy all necessary executables from the tools stage
#COPY --chown=root:root --from=tools /usr/local/bin/cf  /usr/local/bin
COPY --chown=root:root --from=tools /usr/local/bin/cf8     /usr/local/bin/cf
COPY --chown=root:root --from=tools /usr/local/bin/btp     /usr/local/bin
COPY --chown=root:root --from=tools /usr/local/bin/mbt     /usr/local/bin
COPY --chown=root:root --from=tools /usr/local/bin/fx      /usr/local/bin
COPY --chown=root:root --from=tools /usr/local/bin/ijq     /usr/local/bin

## Install the CF plugin for deploying MTAs on Cloudfoundry
RUN cf install-plugin -f https://github.com/cloudfoundry-incubator/multiapps-cli-plugin/releases/latest/download/multiapps-plugin.linux64

# Customize the prompt
ENV PS1 "\[\e]0;\w\a\]\[\033[33;1m\]btp-setup-automator: \[\033[36m\]\$(basename \w) \$\[\033[m\] "

# For using outside of VS Code context:
CMD ["bash"]