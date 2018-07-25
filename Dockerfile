FROM centos:7


# ====== TIMEZONE
ENV TZ=Australia/Sydney
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone


# ====== WORKSPACE =======
RUN mkdir -p /usr/workspace
WORKDIR /usr/workspace


# ====== YUM PACKAGES ======
RUN yum update -y && yum install -y wget curl grep sed unzip git bash make ca-certificates telnet which tree bzip2 yum-utils device-mapper-persistent-data lvm2


# ========= DOCKER ========
RUN yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
RUN yum install -y docker-ce
RUN systemctl enable docker


# ========= AWS SDK ========
RUN curl "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "awscli-bundle.zip"
RUN unzip awscli-bundle.zip
RUN ./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws

# ========= JQ ========
RUN wget https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64 -O /usr/local/bin/jq
RUN chmod 755 /usr/local/bin/jq

# ========= JAVA 8 =========
RUN yum -y install java-1.8.0-openjdk java-1.8.0-openjdk-devel

RUN echo "export JAVA_HOME=$(dirname $(dirname $(readlink $(readlink $(which javac)))))" > /etc/profile.d/java8.sh
RUN echo "export PATH=\$PATH:\$JAVA_HOME/bin" >> /etc/profile.d/java8.sh
RUN echo "export CLASSPATH=.:\$JAVA_HOME/jre/lib:\$JAVA_HOME/lib:\$JAVA_HOME/lib/tools.jar" >> /etc/profile.d/java8.sh

RUN source /etc/profile.d/java8.sh

RUN alternatives --install /usr/bin/java java $JAVA_HOME/bin/java 1
RUN alternatives --install /usr/bin/javac javac $JAVA_HOME/bin/javac 1

# --- replace the above with this section for oracle java 8 ---

#RUN wget -O jq https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64 \
#    && chmod +x ./jq \
#    && mv jq /usr/bin

#RUN wget -O jdk8.json https://lv.binarybabel.org/catalog-api/java/jdk8.json

#RUN wget --no-cookies --no-check-certificate --header "Cookie: oraclelicense=accept-securebackup-cookie" "$(cat jdk8.json | jq -r .downloads.tgz)" -O jdk-8-linux-x64.tar.gz
#RUN tar xzf jdk-8-linux-x64.tar.gz; mkdir -p /usr/java; mv jdk1.8.0_$(cat jdk8.json | jq -r .version_parsed.minor) /usr/java; ln -s /usr/java/jdk1.8.0_$(cat jdk8.json | jq -r .version_parsed.minor) /usr/java/latest; ln -s /usr/java/latest /usr/java/default

#RUN alternatives --install /usr/bin/java java /usr/java/latest/bin/java 1
#RUN alternatives --install /usr/bin/javac javac /usr/java/latest/bin/javac 1

#ENV JAVA_HOME /usr/java/latest

#RUN rm -f jdk-8-linux-x64.tar.gz; rm -f jdk8.json


# ========= SONAR ========
# https://github.com/newtmitch/docker-sonar-scanner/blob/master/Dockerfile.sonarscanner-3.0.3-full

ENV SONAR_SCANNER_VERSION 3.0.3.778

RUN curl --insecure -o /usr/workspace/sonarscanner.zip -L https://sonarsource.bintray.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-$SONAR_SCANNER_VERSION-linux.zip
RUN unzip sonarscanner.zip
RUN rm sonarscanner.zip

COPY sonar-runner.properties /usr/workspace/sonar-scanner-$SONAR_SCANNER_VERSION-linux/conf/sonar-scanner.properties

#   ensure Sonar uses the provided Java for musl instead of a borked glibc one
RUN sed -i 's/use_embedded_jre=true/use_embedded_jre=false/g' /usr/workspace/sonar-scanner-$SONAR_SCANNER_VERSION-linux/bin/sonar-scanner

RUN mkdir -p /opt/sonar
RUN mv ./sonar-scanner-$SONAR_SCANNER_VERSION-linux /opt/sonar/

ENV SONAR_RUNNER_HOME=/opt/sonar/sonar-scanner-$SONAR_SCANNER_VERSION-linux
ENV PATH $PATH:/opt/sonar/sonar-scanner-$SONAR_SCANNER_VERSION-linux/bin


# ========= MAVEN ========
# https://github.com/Zenika/alpine-maven/blob/master/jdk8/Dockerfile

#RUN find /usr/share/ca-certificates/mozilla/ -name "*.crt" -exec keytool -import -trustcacerts \
#  -keystore /usr/java/latest/jre/lib/security/cacerts -storepass changeit -noprompt \
#  -file {} -alias {} \; && \
#  keytool -list -keystore /usr/java/latest/jre/lib/security/cacerts --storepass changeit

ENV MAVEN_VERSION 3.5.2
ENV MAVEN_HOME /usr/lib/mvn
ENV PATH $MAVEN_HOME/bin:$PATH

RUN yum install -y wget && wget http://archive.apache.org/dist/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz && \
  tar -zxvf apache-maven-$MAVEN_VERSION-bin.tar.gz && \
  rm apache-maven-$MAVEN_VERSION-bin.tar.gz && \
  mv apache-maven-$MAVEN_VERSION /usr/lib/mvn


# ========= GRADLE ========
# https://github.com/keeganwitt/docker-gradle/blob/1fcbfdaa2566e3cf3fb055fbd1342f2aa462bb85/jdk8/Dockerfile

RUN mkdir -p /opt/gradle
ENV GRADLE_VERSION 4.6
ENV GRADLE_HOME /opt/gradle/gradle-${GRADLE_VERSION}

ARG GRADLE_DOWNLOAD_SHA256=98bd5fd2b30e070517e03c51cbb32beee3e2ee1a84003a5a5d748996d4b1b915
RUN set -o errexit -o nounset \
	&& echo "Downloading Gradle" \
	&& wget --no-verbose --output-document=gradle.zip "https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip" \
	\
	&& echo "Checking download hash" \
	&& echo "${GRADLE_DOWNLOAD_SHA256} *gradle.zip" | sha256sum -c - \
	\
	&& echo "Installing Gradle" \
	&& unzip gradle.zip \
	&& rm gradle.zip \
	&& mv "gradle-${GRADLE_VERSION}" "/opt/gradle/" \
	&& ln -s "${GRADLE_HOME}/bin/gradle" /usr/bin/gradle


# ========= NODE ========

RUN curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.8/install.sh | bash \
    && export NVM_DIR="$HOME/.nvm" \
    && . "$NVM_DIR/nvm.sh" \
    && nvm install 8.11.1

ENV PATH /root/.nvm/versions/node/v8.11.1/bin:$PATH
RUN export PATH=/root/.nvm/versions/node/v8.11.1/bin:$PATH

# ========= PIP =========
RUN curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py \
    && chmod 755 ./get-pip.py \
    && ./get-pip.py

# for sonar scanner
RUN npm install -g typescript
ENV NODE_PATH /root/.nvm/versions/node/v8.11.1/lib/node_modules

# yarn
RUN npm install -g yarn

# ========= SSH =========
RUN ssh-keygen -t rsa -b 4096 -f /root/.ssh/id_rsa -q -n ""
RUN eval $(ssh-agent -s) && ssh-add /root/.ssh/id_rsa
RUN echo "eval \$(ssh-agent -s)" >> /root/.bashrc

RUN echo -e "Host github.com\n\tStrictHostKeyChecking no\n" >> ~/.ssh/config

COPY workspace /usr/workspace
RUN chmod 755 /usr/workspace/*.sh

CMD /bin/bash