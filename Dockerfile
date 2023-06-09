FROM bitnami/minideb:bullseye

# Install dependencies
RUN apt update && apt upgrade -y && apt install -y \
    curl \
    jq \
    git \
    python3 \
    python3-pip

# install detect-secrets
RUN pip3 install detect-secrets

# copy shell script
COPY simple-secret-scanner.sh /usr/local/bin/

# define requirements
ENV GITHUB_TOKEN=""
ENV GITHUB_ORG_NAME=""

# start the script
CMD ["/bin/bash", "/usr/local/bin/simple-secret-scanner.sh", "$GITHUB_TOKEN", "$GITHUB_ORG_NAME"]
