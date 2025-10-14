# Build stage
FROM ubuntu:24.04 AS builder

# Install build dependencies
RUN apt-get update \
    && apt-get install -y \
        ca-certificates \
        curl \
        gnupg \
        lsb-release \
        unzip \
        wget \
    && rm -rf /var/lib/apt/lists/*

# Install AWS CLI v2
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
    && unzip awscliv2.zip \
    && ./aws/install \
    && rm -rf awscliv2.zip aws

# Install Terraform
RUN curl -fsSL https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/hashicorp.list \
    && apt-get update \
    && apt-get install -y terraform \
    && rm -rf /var/lib/apt/lists/*

# Install kubectl
RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl \
    && chmod +x ./kubectl \
    && mv ./kubectl /usr/local/bin/kubectl

# Install kubeseal
RUN LATEST_KUBESEAL_VERSION=$(curl -s https://api.github.com/repos/bitnami-labs/sealed-secrets/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")') \
    && curl -L "https://github.com/bitnami-labs/sealed-secrets/releases/download/${LATEST_KUBESEAL_VERSION}/kubeseal-linux-amd64" -o /usr/local/bin/kubeseal \
    && chmod +x /usr/local/bin/kubeseal

# Runtime stage
FROM ubuntu:24.04 AS runtime

# Install only runtime dependencies
RUN apt-get update \
    && apt-get install -y \
        ca-certificates \
        curl \
        gnupg \
        lsb-release \
        make \
        openjdk-11-jdk \
        sudo \
        vim \
    && curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
        $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null \
    && apt-get update \
    && apt-get install -y \
        docker-ce \
        docker-ce-cli \
        containerd.io \
        docker-compose \
    && rm -rf /var/lib/apt/lists/*

# Copy binaries from builder stage
COPY --from=builder /usr/local/bin/aws /usr/local/bin/aws
COPY --from=builder /usr/bin/terraform /usr/local/bin/terraform
COPY --from=builder /usr/local/bin/kubectl /usr/local/bin/kubectl
COPY --from=builder /usr/local/bin/kubeseal /usr/local/bin/kubeseal

# Add Docker Insecure Registries
RUN mkdir -p /etc/docker \
    && echo "{ \"insecure-registries\": [\"192.168.2.207:18079\"] }" > /etc/docker/daemon.json

ENTRYPOINT ["/bin/bash"]