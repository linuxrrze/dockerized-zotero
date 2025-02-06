FROM node:lts

RUN \
apt update && \
apt -y upgrade && \
apt install -y bash git git-lfs python3 rsync openssl perl zip curl p7zip-full binutils xz-utils file ncurses-bin xxd 
# Missing for windows build: cygpath upx

# Install AWS client
RUN \
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
unzip awscliv2.zip && \
./aws/install && \
rm awscliv2.zip

COPY ./entrypoint.sh /
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/bin/bash", "-c", "/entrypoint.sh"]

# More info: https://www.zotero.org/support/dev/client_coding/building_the_desktop_app
