# Use public ECR image as a base image.
FROM public.ecr.aws/lambda/python:3.12-arm64

# Build arguments.
ARG LO_VERSION=24.2.1
ENV LO=libreoffice-${LO_VERSION}
ENV LO_TAR=${LO}.1.tar.xz

# Install build dependencies.
RUN dnf upgrade -y
RUN dnf install -y tar wget gzip bzip2 xz perl autoconf automake make gcc-c++ zlib-devel \
    which glibc-locale-source glibc-all-langpacks cups-devel fontconfig-devel fontconfig \
    gperf java-17-amazon-corretto java-17-amazon-corretto-devel libxslt libxslt-devel \
    python3-devel nss nss-devel nspr nspr-devel libX11-devel libXext-devel libXrender-devel \
    libXtst-devel libxcb-devel libICE-devel libSM-devel libXt-devel libXmu-devel libXpm-devel \
    libXrandr-devel bison flex patch gtk3-devel atk-devel cairo-devel glib2-devel git meson \
    ninja-build pkgconfig libxml2-devel texinfo ant
RUN localedef -i en_US -f UTF-8 en_US.UTF-8
RUN python3 -m pip install setuptools

# Download and compile gcc.
RUN mkdir /usr/bin/GCC-12 && \
    cd / && \
    wget https://ftp.gnu.org/gnu/gcc/gcc-12.3.0/gcc-12.3.0.tar.gz && \
    tar xzf gcc-12.3.0.tar.gz && \
    cd /gcc-12.3.0 && \
    ./contrib/download_prerequisites && \
    cd / && \
    mkdir objdir && \
    cd /objdir && \
    ../gcc-12.3.0/configure --prefix=/usr/bin/GCC-12 --enable-languages=c,c++ --disable-multilib --with-system-zlib  && \
    make && \
    make install && \
    rm -rf /objdir && \
    rm /gcc-12.3.0.tar.gz && \
    rm -rf /gcc-12.3.0
ENV PATH=/usr/bin/GCC-12/bin:$PATH
ENV LD_LIBRARY_PATH=/usr/bin/GCC-12/lib/../lib64:$LD_LIBRARY_PATH

## Get and extract LibreOffice source then build.
WORKDIR /
RUN wget https://download.documentfoundation.org/libreoffice/src/${LO_VERSION}/${LO_TAR}
RUN tar -xJf ${LO_TAR}
WORKDIR /${LO}.1
RUN ./autogen.sh \
    --disable-cairo-canvas \
    --disable-coinmp \
    --disable-community-flavor \
    --disable-cups \
    --disable-cve-tests \
    --disable-dconf \
    --disable-dbus \
    --disable-dependency-tracking \
    --disable-extension-update \
    --disable-firebird-sdbc \
    --disable-gstreamer-1-0 \
    --disable-gtk3 \
    --disable-gui \
    --disable-ldap \
    --disable-lpsolve \
    --disable-mariadb-sdbc \
    --disable-postgresql-sdbc \
    --disable-report-builder \
    --disable-sdremote \
    --disable-sdremote-bluetooth \
    --disable-split-debug \
    --with-system-zlib \
    --without-junit \
    --with-parallelism=2 && \
    make v=1 && \
    make install && \
    cd / && \
    rm -rf /${LO}.1 && \
    rm /${LO_TAR}

## Define custom INSTDIR for LibreOffice installation.
ENV INSTDIR=/usr/local/lib/libreoffice
ENV FONTDIR=${INSTDIR}/share/fonts

## Create and write the fonts.conf file.
RUN mkdir -p ${INSTDIR}/user/fonts && \
    echo '<?xml version="1.0"?>' > ${INSTDIR}/user/fonts/fonts.conf && \
    echo '<!DOCTYPE fontconfig SYSTEM "fonts.dtd">' >> ${INSTDIR}/user/fonts/fonts.conf && \
    echo '<fontconfig>' >> ${INSTDIR}/user/fonts/fonts.conf && \
    echo "  <dir>${FONTDIR}</dir>" >> ${INSTDIR}/user/fonts/fonts.conf && \
    echo '  <!-- This may or not require font family specs.' >> ${INSTDIR}/user/fonts/fonts.conf && \
    echo '       Currently the only purpose is to stop fontconfig complaining. -->' >> ${INSTDIR}/user/fonts/fonts.conf && \
    echo '</fontconfig>' >> ${INSTDIR}/user/fonts/fonts.conf

# Test conversion, should fail the first time.
# This is necessary to create some final configuration for libreoffice.
# There are various other run time tricks to do this. BUt doing it at container build time
# makes it easier to manage.
RUN echo '{\\rtf1\\ansi\\ansicpg1252\\cocoartf1671\\cocoasubrtf600{\\fonttbl\\f0\\fswiss\\fcharset0 Helvetica;}\\f0\\fs24 \\cf0 This is a line of content in my RTF file.}' > /tmp/my_temp_file.rtf
RUN /usr/local/lib/libreoffice/program/soffice.bin \
    --headless \
    --invisible \
    --nodefault \
    --nofirststartwizard \
    --nolockcheck \
    --nologo \
    --norestore \
    --writer \
    --convert-to pdf \
    --outdir /tmp \
    /tmp/my_temp_file.rtf || [ $? -eq 81 ]
