FROM alpine:3.8 AS stage0

MAINTAINER https://github.com/dtandersen/backuppc-docker

ENV BACKUPPC_XS_VERSION=0.57 \
    DATA=/var/lib/data \
    BPC_USER=backuppc

RUN apk --no-cache --virtual build-dependencies add gcc g++ libgcc linux-headers autoconf automake make git patch perl-dev python3-dev expat-dev curl wget perl-app-cpanminus
RUN apk --update --no-cache add perl supervisor nginx fcgiwrap bash su-exec && \
    cpanm install --notest Archive::Zip && \
    cpanm install --notest XML::RSS && \
    cpanm install --notest CGI && \
    cpanm install --notest File::Listing && \
    cpanm install --notest Net::FTP && \
    cpanm install --notest Net::FTP::RetrHandle && \
    cpanm install --notest Net::FTP::AutoReconnect && \
    adduser backuppc -S -g "" -G www-data && \
    rm -f /etc/nginx/conf.d/default.conf && \
    mkdir -p /run/nginx

FROM stage0 AS stage2
RUN git clone --quiet -c advice.detachedHead=false https://github.com/backuppc/backuppc-xs.git --branch ${BACKUPPC_XS_VERSION} /tmp/backuppc-xs
RUN cd /tmp/backuppc-xs&& \
    perl Makefile.PL && \
    make && \
    make test && \
    make install

FROM stage2 AS stage4
RUN curl -SL https://github.com/backuppc/backuppc/releases/download/4.2.1/BackupPC-4.2.1.tar.gz | tar zx -C /tmp && \
    cd /tmp/BackupPC-4.2.1 && \
    perl configure.pl \
       --batch \
       --backuppc-user=${BPC_USER} \
       --cgi-dir /usr/share/backuppc/cgi-bin/ \
       --data-dir ${DATA} \
       --hostname myHost \
       --html-dir /usr/share/backuppc/html \
       --html-dir-url /backuppc \
       --install-dir /usr/local/backuppc \
       --log-dir /var/log/backuppc

RUN apk del build-dependencies
RUN rm -rf /tmp/*
RUN rm -rf /root/.cpanm

FROM stage4
COPY files /
#COPY --from=stage4 /usr/share/backuppc /usr/share/backuppc
#COPY --from=stage4 /usr/local/backuppc /usr/local/backupp
#COPY --from=stage2 /usr/local/lib/perl5/site_perl/auto/BackupPC/XS/XS.so /usr/local/lib/perl5/site_perl/auto/BackupPC/XS/XS.so
#COPY --from=stage2 /usr/local/lib/perl5/site_perl/BackupPC/XS.pm /usr/local/lib/perl5/site_perl/BackupPC/XS.pm
#COPY --from=stage2 /usr/local/share/man/man3/BackupPC::XS.3pm /usr/local/share/man/man3/BackupPC::XS.3pm
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["supervisord", "-c", "/etc/supervisord.conf"]
