FROM maven:3.6.1-jdk-7

RUN cd /root/ \
       && wget http://downloads.sourceforge.net/project/jboss/JBoss/JBoss-4.0.2/jboss-4.0.2.tar.gz \
       && tar xzf jboss-4.0.2.tar.gz \
       && rm -rf jboss-4.0.2.tar.gz

ENV JAVA_OPTS="-Xms1G -Xmx1G -XX:MaxPermSize=256M -server"
ENV JBOSS_HOME=/root/jboss-4.0.2
ENV PATH=$PATH:/root/jboss-4.0.2/bin
ENV TZ=America/Indiana/Indianapolis

Add ./local/Docker_files/ifxjdbc.jar /root/jboss-4.0.2/server/default/lib/
Add ./web/i /root/jboss-4.0.2/server/default/deploy/jbossweb-tomcat55.sar/ROOT.war/i
Add ./web/css /root/jboss-4.0.2/server/default/deploy/jbossweb-tomcat55.sar/ROOT.war/css
Add ./web/js /root/jboss-4.0.2/server/default/deploy/jbossweb-tomcat55.sar/ROOT.war/js

Add ./target/review /root/jboss-4.0.2/server/default/deploy/review.war

RUN mkdir -p /root/web/conf
Add ./conf/distribution_scripts /root/web/conf/distribution_scripts
RUN mkdir -p /root/temp/dist-gen
RUN mkdir -p /nfs_shares/tcssubmissions
RUN mkdir -p /nfs_shares/studiofiles/submissions
RUN mkdir -p /nfs_shares/tcs-downloads

## tokenized
Add ./jboss_files/deploy/tcs_informix-ds.xml /root/
Add ./token.properties /root/
RUN cat /root/token.properties | grep -v '^#' | grep -v '^$'| sed s/\\//\\\\\\//g | awk -F '=' '{print "s/@"$1"@/"$2"/g"}' | sed -f /dev/stdin /root/tcs_informix-ds.xml >> /root/jboss-4.0.2/server/default/deploy/informix-ds.xml
RUN rm /root/token.properties
RUN rm /root/tcs_informix-ds.xml

Add ./local/Docker_files/AuthorizationHelper.class /root/jboss-4.0.2/server/default/deploy/review.war/WEB-INF/classes/com/cronos/onlinereview/util/

CMD ["/root/jboss-4.0.2/bin/run.sh","-DFOREGROUND"]