# Use public ECR image as a base image
FROM public.ecr.aws/lambda/python:3.11-arm64

# Build arguments
ARG LO_VERSION=24.2.1
ENV LO=libreoffice-${LO_VERSION}
ENV LO_TAR=${LO}.1.tar.xz

# Install build dependencies
RUN yum update -y
RUN yum install -y yum-utils tar xz which wget
RUN yum groupinstall -y "Development Tools"
RUN yum install -y fontconfig-devel

# Get and extract LibreOffice source
WORKDIR /
RUN wget https://download.documentfoundation.org/libreoffice/src/${LO_VERSION}/${LO_TAR}
RUN tar -xJf ${LO_TAR}

