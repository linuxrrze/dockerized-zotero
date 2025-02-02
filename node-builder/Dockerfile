FROM ubuntu:latest

# Prepare nodejs installation
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash -

# install packages
RUN apt update && apt -y upgrade && apt -y install git rsync nodejs

COPY ./entrypoint.sh /
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/bin/bash", "-c", "/entrypoint.sh"]
