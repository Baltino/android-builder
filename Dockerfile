# http://phusion.github.io/baseimage-docker/
FROM phusion/baseimage:0.9.22

LABEL version="1.0.4" \
  maintainer="Gonzalo del Castillo" \
  maintainer.email="gdc@postack.com.ar" \
  description="Android Build Docker image" \
  repository="https://github.com/postack/android-builder"

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]

# setup deps & java
RUN apt-get update \
  && apt-get install lib32ncurses5 lib32z1 software-properties-common wget git unzip --yes \
  && echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections \
  && add-apt-repository ppa:webupd8team/java \
  && apt-get update \
  && apt-get install oracle-java8-set-default --yes \
# Clean up APT when done.
  && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# setup android sdk and android sdk licences
RUN wget -O /opt/android-tools.zip https://dl.google.com/android/repository/tools_r25.2.3-linux.zip \
  && unzip /opt/android-tools.zip -d /opt \
  && mkdir -p /opt/android-sdk/licenses \
  && mv /opt/tools /opt/android-sdk/tools \
  && rm /opt/android-tools.zip \
  && echo "d56f5187479451eabf01fb78af6dfcb131a6481e" > /opt/android-sdk/licenses/android-sdk-license \
  && mkdir ~/.android; echo "count=0" >> ~/.android/repositories.cfg

ENV JAVA_HOME=/usr/lib/jvm/java-8-oracle \
  ANDROID_HOME=/opt/android-sdk \
  JAVA_OPTS="-Xms2048m -Xmx5120m"

COPY android-packages /tmp/android-packages

# download android packages
RUN /opt/android-sdk/tools/bin/sdkmanager --package_file=/tmp/android-packages \
  && rm /tmp/android-packages

# wrap up
RUN mkdir /tmp/project \
  && echo "sdk.dir=$ANDROID_HOME" > /tmp/project/local.properties

RUN /opt/android-sdk/tools/bin/sdkmanager --update

WORKDIR /tmp/project
