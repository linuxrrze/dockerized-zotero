FROM node:lts

# install packages
RUN apt update && apt -y upgrade && apt -y install git rsync

COPY ./entrypoint.sh /
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/bin/bash", "-c", "/entrypoint.sh"]
