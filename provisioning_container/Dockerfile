# Use the official HashiCorp Terraform image as the base image
FROM hashicorp/terraform:latest

# Install dependencies
RUN apk update && apk add --no-cache \
gnupg \
ansible \
vim

# Clean up
RUN rm -rf /var/cache/apk/*

# Set the working directory
WORKDIR /workspace

# Clone down provisioning repository
#RUN git clone https://github.com/Vernify/homelab.git /homelab
#RUN rm -rf /homelab/.git
RUN mkdir ~/.ssh \
    && ssh-keygen -t ecdsa -b 521 -f ~/.ssh/id_ecdsa -N ""

# Set the entrypoint
ENTRYPOINT ["sh"]
