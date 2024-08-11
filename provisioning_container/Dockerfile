# Use the official HashiCorp Terraform image as the base image
FROM hashicorp/terraform:latest

# Install dependencies
RUN apk update && apk add --no-cache \
gnupg \
ansible \
vim 

# Install Packerr
RUN wget https://releases.hashicorp.com/packer/1.11.2/packer_1.11.2_linux_amd64.zip \
    && unzip packer_1.11.2_linux_amd64.zip \
    && mv packer /usr/local/bin \
    && rm packer_1.11.2_linux_amd64.zip

# Clean up
RUN rm -rf /var/cache/apk/*

# Set the working directory
WORKDIR /workspace

# Clone down provisioning repository
#RUN git clone https://github.com/Vernify/homelab.git /homelab
#RUN rm -rf /homelab/.git
RUN mkdir ~/.ssh \
    && ssh-keygen -t ecdsa -b 521 -f ~/.ssh/id_ecdsa -N ""

# Turn off SSH host key checking
RUN echo "Host *\n\tStrictHostKeyChecking no\n\n" > ~/.ssh/config

# Set the entrypoint
ENTRYPOINT ["sh"]
