ARG IMAGE_TO_TEST="mcr.microsoft.com/vscode/devcontainers/base:0-focal"
FROM $IMAGE_TO_TEST

ENV PATH=/front-dockerfile-pre-script:$PATH:/back-dockerfile-pre-script
ENV this_var=true

ARG DEFAULT_SHELL_TYPE=bash
COPY sshd-debian.sh test/sshd/*.sh /tmp/scripts/
ARG current_user=$USER
USER root
RUN apt-get update \
    && bash /tmp/scripts/sshd-debian.sh \
    && bash /tmp/scripts/test-prep.sh ${DEFAULT_SHELL_TYPE}
USER $current_user

ENV that_var=true
ENV PATH=/front-dockerfile-post-script:$PATH:/back-dockerfile-post-script

ENTRYPOINT [ "/usr/local/share/ssh-init.sh" ]
CMD [ "sleep", "infinity" ]