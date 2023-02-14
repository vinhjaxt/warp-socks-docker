FROM ubuntu:22.04
RUN apt update -y && apt install -y apt-transport-https curl gnupg
RUN curl https://pkg.cloudflareclient.com/pubkey.gpg | gpg --yes --dearmor --output /usr/share/keyrings/cloudflare-warp-archive-keyring.gpg
RUN echo "deb [arch=amd64 signed-by=/usr/share/keyrings/cloudflare-warp-archive-keyring.gpg] https://pkg.cloudflareclient.com/ jammy main" | tee /etc/apt/sources.list.d/cloudflare-client.list
RUN apt update -y && apt install -y cloudflare-warp
RUN curl -L -o /usr/local/bin/tcp-tcp https://github.com/vinhjaxt/tcp-proxy/releases/download/ActionBuild_2022.06.28_03-05-11/tcp-tcp-linux-gnu-amd64 && \
  chmod +x /usr/local/bin/tcp-tcp
ENTRYPOINT /entrypoint.sh
