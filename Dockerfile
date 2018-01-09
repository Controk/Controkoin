FROM ubuntu:16.04 as builder

RUN apt-get update && \
    apt-get --no-install-recommends --yes install \
        build-essential \
        git \
        cmake \
        libboost-all-dev

WORKDIR /src
COPY . .

ARG NPROC

RUN rm -rf build && \
    if [ -z "$NPROC" ];then make -j$(nproc);else make -j$NPROC;fi

# runtime stage
FROM ubuntu:16.04

RUN apt-get update && \
    apt-get --no-install-recommends --yes install ca-certificates && \
    apt-get clean && \
    rm -rf /var/lib/apt

    
COPY --from=builder /src/build/release/bin/* /usr/local/bin/

# Contains the blockchain
VOLUME /root/.controkoin

# Generate your wallet via accessing the container and run:
# cd /wallet
# controkoin-wallet-cli
VOLUME /wallet

# This port will be used by the daemon to establish connections with p2p network
EXPOSE 17236
# This port will be used by the daemon to interact with simlewallet
EXPOSE 18236

ENTRYPOINT ["controkoind", "--p2p-bind-ip=0.0.0.0", "--p2p-bind-port=17236", "--rpc-bind-ip=0.0.0.0", "--rpc-bind-port=18236", "--non-interactive", "--confirm-external-bind"] 