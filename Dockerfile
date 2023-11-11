# docker build -t amzlin:dev . --no-cache
# docker run --rm -it -v $PWD:/project --name native-dev amzlin:dev pwd
# docker run --rm -it -v $PWD:/project --name native-dev amzlin:dev /bin/sh native-image.sh
# docker image push amzlin:dev
FROM amazonlinux:2

RUN yum -y update \
    && yum install -y tar unzip gzip zip bzip2-devel ed gcc gcc-c++ gcc-gfortran \
    less libcurl-devel openssl openssl-devel readline-devel xz-devel \
    zlib-devel glibc-static libcxx libcxx-devel llvm-toolset-7 zlib-static \
    && rm -rf /var/cache/yum

ENV GRAAL_VERSION 21.0.1
ENV GRAAL_FOLDERNAME graalvm-ce-java21-${GRAAL_VERSION}
ENV GRAAL_FILENAME graalvm-community-jdk-${GRAAL_VERSION}_linux-x64_bin.tar.gz
RUN mkdir ${GRAAL_FOLDERNAME}
RUN curl -4 -L https://github.com/graalvm/graalvm-ce-builds/releases/download/jdk-${GRAAL_VERSION}/${GRAAL_FILENAME} | tar -xvz -C ${GRAAL_FOLDERNAME} --strip-components=1
RUN mv $GRAAL_FOLDERNAME /usr/lib/graalvm
RUN rm -rf $GRAAL_FOLDERNAME

# Graal maven plugin requires Maven 3.3.x
ENV MVN_VERSION 3.9.5
ENV MVN_FOLDERNAME apache-maven-${MVN_VERSION}
ENV MVN_FILENAME apache-maven-${MVN_VERSION}-bin.tar.gz
RUN curl -4 -L https://dlcdn.apache.org/maven/maven-3/${MVN_VERSION}/binaries/${MVN_FILENAME} | tar -xvz
RUN mv $MVN_FOLDERNAME /usr/lib/maven
RUN rm -rf $MVN_FOLDERNAME

# Gradle
ENV GRADLE_VERSION 8.3
ENV GRADLE_FOLDERNAME gradle-${GRADLE_VERSION}
ENV GRADLE_FILENAME gradle-${GRADLE_VERSION}-bin.zip
RUN curl -LO https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip
RUN unzip gradle-${GRADLE_VERSION}-bin.zip
RUN mv $GRADLE_FOLDERNAME /usr/lib/gradle
RUN rm -rf $GRADLE_FOLDERNAME

VOLUME /project
WORKDIR /project

ENV GRAALVM_HOME=/usr/lib/graalvm
ENV JAVA_HOME ${GRAALVM_HOME}
#RUN /usr/lib/graalvm/bin/gu install native-image
RUN ln -s /usr/lib/graalvm/bin/native-image /usr/bin/native-image
RUN ln -s /usr/lib/maven/bin/mvn /usr/bin/mvn
RUN ln -s /usr/lib/gradle/bin/gradle /usr/bin/gradle

RUN echo $PATH
ENV PATH="$PATH:$GRAALVM_HOME/bin"
RUN echo $PATH


CMD ["bash"]
