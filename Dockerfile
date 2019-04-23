FROM frolvlad/alpine-glibc:alpine-3.8

RUN apk add --no-cache curl tar python2 gcc g++ scons 

RUN mkdir -p /opt/nsis
RUN curl -L https://ufpr.dl.sourceforge.net/project/nsis/NSIS%203/3.03/nsis-3.03-src.tar.bz2 > /tmp/nsis-3.03-src.tar.bz2
RUN tar -xf /tmp/nsis-3.03-src.tar.bz2 -C /opt/nsis && unlink /tmp/nsis-3.03-src.tar.bz2 

RUN apk add --no-cache zlib-dev

ENV BUILD_PACKAGES="wget build-base autoconf re2c libtool"
RUN apk --no-cache --progress add $BUILD_PACKAGES \
# Install GNU libiconv
&& cd /opt \
&& curl -L http://ftp.gnu.org/pub/gnu/libiconv/libiconv-1.15.tar.gz > ./libiconv-1.15.tar.gz \
&& tar xzf libiconv-1.15.tar.gz \
&& cd libiconv-1.15 \
&& sed -i 's/_GL_WARN_ON_USE (gets, "gets is a security hole - use fgets instead");/#if HAVE_RAW_DECL_GETS\n_GL_WARN_ON_USE (gets, "gets is a security hole - use fgets instead");\n#endif/g' srclib/stdio.in.h \
&& ./configure --prefix=/usr/local \
&& make \
&& make install

RUN curl -L https://ufpr.dl.sourceforge.net/project/nsis/NSIS%203/3.03/nsis-3.03.zip > /tmp/nsis-3.03.zip
RUN unzip /tmp/nsis-3.03.zip -d /opt/nsis && unlink /tmp/nsis-3.03.zip 

RUN cd /opt/nsis/nsis-3.03-src/ && \
scons SKIPSTUBS=all SKIPPLUGINS=all SKIPUTILS=all SKIPMISC=all NSIS_CONFIG_CONST_DATA=no PREFIX=/opt/nsis/nsis-3.03-src install-compiler

RUN ln -s /opt/nsis/nsis-3.03-src/bin/makensis /opt/nsis/makensis \
&& mkdir /opt/nsis/nsis-3.03-src/share \
&& cd /opt/nsis/nsis-3.03-src/share \
&& ln -s /opt/nsis/nsis-3.03 nsis

RUN chmod +x /opt/nsis/nsis-3.03-src/bin/makensis \
&& ln -s /opt/nsis/nsis-3.03-src/bin/makensis /usr/local/bin/makensis

RUN ls /opt/nsis/nsis-3.03-src

RUN apk del $BUILD_PACKAGES \
&& rm -rf /opt/libiconv* \
&& rm -rf /var/cache/apk/* \
&& rm -rf /usr/share/*

RUN mkdir /project
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
