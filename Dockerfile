#This drone-auth-ecr image contains AWS credentials and lives on a private docker registry
#It is pulled by drone to auth to ECR and pull an ECR image as a step in the pipeline
FROM debian:9-slim

# AWS CLI needs the PYTHONIOENCODING environment varialbe to handle UTF-8 correctly:
ENV PYTHONIOENCODING=UTF-8
ENV PATH=/root/.local/bin:$PATH

## Copy AWS config, credentials should be automatically pulled from IAM role associated with drone instance
COPY config/config /root/.aws/config

#install the aws prereqs
RUN apt-get update \
    && apt-get install -y curl python\
    apt-transport-https \
    ca-certificates \
    gnupg2 \
    software-properties-common \
    && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add -
RUN add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/debian \
   $(lsb_release -cs) \
   stable"

#install aws cli
RUN curl -O https://bootstrap.pypa.io/get-pip.py \
    && echo 'export PATH=/root/.local/bin:$PATH' >> /root/.bash_profile \
    && python get-pip.py --user \
    && pip install awscli --upgrade --user

RUN apt-get update \
    && apt-get install -y docker-ce-cli \
    && rm -rf /var/lib/apt/lists/*