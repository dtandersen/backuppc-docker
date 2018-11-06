FROM alpine:3.8

ARG BACKUPPC_XS_VERSION=0.57

RUN apk update
RUN apk --no-cache --update --virtual build-dependencies add gcc g++ libgcc linux-headers autoconf automake make git patch perl-dev python3-dev expat-dev curl wget
RUN apk add perl

RUN git clone https://github.com/backuppc/backuppc-xs.git --branch ${BACKUPPC_XS_VERSION} /root/backuppc-xs 
RUN cd /root/backuppc-xs \
    && perl Makefile.PL && make && make test && make install

#RUN cd BackupPC-XS-0.50 \
#    && perl Makefile.PL \
#    && make \
#    && make test \
#    && make install
#RUN perlbrew install-cpanm
#RUN cpanm install IPC::Run
ENV PERL_MM_USE_DEFAULT=1
RUN apk add bash
RUN curl -L https://install.perlbrew.pl | bash
RUN ~/perl5/perlbrew/bin/perlbrew install-cpanm
RUN /root/perl5/perlbrew/bin/cpanm install Archive::Zip
RUN /root/perl5/perlbrew/bin/cpanm install XML::RSS
RUN /root/perl5/perlbrew/bin/cpanm install CGI
RUN /root/perl5/perlbrew/bin/cpanm install File::Listing
RUN /root/perl5/perlbrew/bin/cpanm install Net::FTP
RUN /root/perl5/perlbrew/bin/cpanm install --no-interactive --verbose  --notest Net::FTP::RetrHandle
RUN /root/perl5/perlbrew/bin/cpanm install Net::FTP::AutoReconnect

RUN cd / \
    && wget -q https://github.com/backuppc/backuppc/releases/download/4.2.1/BackupPC-4.2.1.tar.gz \
    && tar zxvf BackupPC-4.2.1.tar.gz \
    && cd /BackupPC-4.2.1 \
    && perl configure.pl \
       --batch \
       --cgi-dir /var/www/cgi-bin/BackupPC \
       --data-dir /data/BackupPC \
       --hostname myHost \
       --html-dir /var/www/html/BackupPC \
       --html-dir-url /BackupPC \
       --install-dir /usr/local/BackupPC


#RUN perl -MCPAN -e 'install Archive::Zip'
#RUN perl -MCPAN -e 'install XML::RSS'
#RUN perl -MCPAN -e 'install CGI'
#RUN perl -MCPAN -e 'install File::Listing, Net::FTP, Net::FTP::RetrHandle, Net::FTP::AutoReconnect'
#RUN pip3 install --upgrade pip
#RUN echo x
#RUN pip3 install git+https://github.com/Supervisor/supervisor.git#egg=supervisor
#RUN apk add which
#RUN pip3 show -f supervisor
#RUN ls -al /bin | grep sup
#RUN which supervisord
#RUN which supervisor
#RUN /bin/supervisord
#RUN ls -al /usr/lib/python3.6/site-packages
RUN apk add supervisor
RUN ls -al /



RUN apk del build-dependencies

COPY files /
RUN ls -al /etc | grep sup
CMD supervisord -c /etc/supervisord.conf -n
