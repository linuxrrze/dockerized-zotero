# s. .nvmrc: iron/lts = 20
FROM node:iron-bullseye

# install packages
RUN apt update && apt -y upgrade && apt -y install git rsync

## In order to build a specific version use this:
#RUN git clone --recursive "https://github.com/zotero/web-library.git" /web-library && cd /web-library && git checkout tags/v1.5.7
RUN git clone --recursive "https://github.com/zotero/web-library.git" /web-library
WORKDIR /web-library
RUN npm ci && npm cache clean --force
RUN npm run build

#CMD ["npm", "run", "serve"]
# s. Execute NodeJS (not NPM script) to handle SIGTERM and SIGINT signals.
CMD ["nodejs", "./scripts/server.cjs" ]
