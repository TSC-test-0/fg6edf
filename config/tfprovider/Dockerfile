##################################################################################################################################################
# LICENSE
# This Dockerfile is provided under the LICENSE defined in the Github repository
# at https://github.com/SAP-samples/btp-setup-automator
##################################################################################################################################################
# STARTING WITH ALL THE SAP TOOLS FIRST
##################################################################################################################################################
FROM golang:alpine

## Install necessary packages to donwload and install tools
RUN echo "http://dl-4.alpinelinux.org/alpine/latest-stable/community" >> /etc/apk/repositories \
    && apk update \
    && apk upgrade \
    && apk add --no-cache curl jq terraform\
    && update-ca-certificates

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
               curl \
               git \
               jq \
               make \
               sudo \
               libc6-compat \
    && rm -rf /tmp/pip-tmp \
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

RUN git clone https://github.com/SAP/terraform-provider-btp.git \
    && cd terraform-provider-btp\
    && make install

COPY --chown=$USERNAME:$USERNAME config/tfprovider/provider-config-local.txt      $HOME_FOLDER/.terraformrc

# Customize the prompt
ENV PS1 "\[\e]0;\w\a\]\[\033[33;1m\]btp-setup-automator: \[\033[36m\]\$(basename \w) \$\[\033[m\] "

# For using outside of VS Code context:
CMD ["bash"]