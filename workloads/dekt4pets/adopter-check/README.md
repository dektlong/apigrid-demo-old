# Accelerator generated project - Spring Cloud Function JVM/Native on K8s/Knative

This sample app provides a simple `Hello` web app based on Spring Boot and Spring Cloud Functions.
It provides multiple deployment options and common Knative use-cases which developers are looking for.

`Currently Tracked Versions:`
* Spring Boot 2.5.2 - as of June 2021
* Spring Native 0.10.1 (Spring Native Beta) - as of June 20210
* OpenJDK
    * openjdk version "11.0.11" 2021-04-20
* GraalVM CE
    *  OpenJDK Runtime Environment GraalVM CE 21.1.0 (build 11.0.11+8-jvmci-21.1-b05)
    *  OpenJDK 64-Bit Server VM GraalVM CE 21.1.0 (build 11.0.11+8-jvmci-21.1-b05, mixed mode, sharing)
    
Build Options:
* JVM application, leveraging OpenJDK
* Native Application, leveraging GraalVM

Deployment Models:
* Standalone web app
* Kubernetes Deployment and Service
* Knative Service

Source code tree:
```
src
├── main
│   ├── java
│   │   └── com
│   │       └── example
│   │           └── hello
│   │               └── SpringNativeFunctionKnativeApplication.java
│   └── resources
│       ├── application.properties
│       ├── static
│       └── templates
└── test
    └── java
        └── com
            └── example
                └── hello
                    └── SpringNativeFunctionKnativeApplicationTests.java

# The function used in this app is available in SpringNativeFunctionKnativeApplication.java
```

# Build

Building the code with the Spring Boot Maven wrapper leverages the following Maven profiles:
* `native-image` - build a Spring Native image leveraging GraalVM
* `jvm-image` - build a Spring JVM-based image leveraging OpenJDK

Building an executable application with the GraalVM compiler leverages the following Maven profile and requires the installation of the GraalVM and the native-image builder utility:
* `native`

## Build code as a JVM app using the Spring Boot Maven plugin with embedded Netty HTTP server
```bash 
# build and run code using
$ ./mvnw clean package spring-boot:run

# test locally
$ curl -w'\n' -H 'Content-Type: text/plain' localhost:8080 -d "from a Function"
```
## Build code as a Native JVM app using the GraalVM compiler with embedded Netty HTTP server
```bash 
# switch to the GraalVM JDK for this build
# ex, when using SDKman
$ sdk use java 21.1.0.r11-grl

# build and run code using
$ ./mvnw clean package -Pnative

# start the native executable
$ ./target/hello-function

# test locally
$ curl -w'\n' -H 'Content-Type: text/plain' localhost:8080 -d "from a Function"
```

## Build code as a JVM image using the Spring Boot Maven plugin and Java Paketo Buildpacks
```bash 
# build image with default configuration
$ ./mvnw clean spring-boot:build-image

# build image with the CNB Paketo buildpack of your choice
$ ./mvnw clean spring-boot:build-image -Pjvm-image

# start Docker image
$ docker run -p 8080:8080 hello-function-jvm:latest

# test Docker image locally
$ curl -w'\n' -H 'Content-Type: text/plain' localhost:8080 -d "from a Function"
```

## Build code as a Spring Native image using the Spring Boot Maven plugin and the Java Native Paketo Buildpacks
```bash 
# build image with the CNB Paketo buildpack of your choice
$ ./mvnw clean spring-boot:build-image -Pnative-image

# start Docker image
$ docker run -p 8080:8080 hello-function-native:latest

# test Docker image locally
$ curl -w'\n' -H 'Content-Type: text/plain' localhost:8080 -d "from a Function"
```


# Deploy Knative

```shell
# Docker run
# run a JVM image
docker run --rm -p 8080:8080 gcr.io/pa-ddobrin/hello-function-jvm:latest 

# run a Native image
docker run --rm -p 8080:8080 gcr.io/pa-ddobrin/hello-function-native:latest 

# Knative Service

# create function with Knative CLI
# JVM image
kn service create hello-function -n hello-function --image gcr.io/pa-ddobrin/hello-function-jvm:latest --env TARGET="from Serverless Test - Spring Function on JVM" --revision-name hello-function-v1 

# Native image
kn service create hello-function -n hello-function --image gcr.io/pa-ddobrin/hello-function-native:latest --env TARGET="from Serverless Test - Spring Function on JVM" --revision-name hello-function-v1 

# delete a service
kn service delete hello-function -n hello-function

# Skaffold 

# deploy a JVM image
skaffold -f kubernetes/k8s/skaffold/skaffold.yaml dev -p local  --port-forward
skaffold -f kubernetes/k8s/skaffold/skaffold.yaml run -p local  --port-forward

# delete a JVM image
skaffold -f kubernetes/k8s/skaffold/skaffold.yaml delete -p local 


# deploy a Native image
skaffold -f kubernetes/k8s/skaffold/skaffold.yaml dev  -p native  --port-forward
skaffold -f kubernetes/k8s/skaffold/skaffold.yaml run -p native  --port-forward

# delete a Native image
skaffold -f kubernetes/k8s/skaffold/skaffold.yaml delete -p native

```
# CI/CD integration - Build a JVM / Native Docker image with kpack / Tanzu Build Service

To build an image with Java or Java Native Paketo Buildpacks with kpack or the Tanzu Build Service, you can use the commands listed below.

To start, install the tools as follows:
* `kpack CLI` - https://github.com/vmware-tanzu/kpack-cli 
  * kpack commands - https://github.com/vmware-tanzu/kpack-cli/blob/master/docs/kp.md 
* `kpack` - https://github.com/pivotal/kpack 
* Tanzu Build Service - https://network.pivotal.io/products/build-service/ 
  * Build Service Documentation - https://docs.pivotal.io/build-service/1-1/ 

## Building JVM Docker images
To build the JVM image with the Java Paketo Buildpack, please run:
```shell
$ kp image save hello-function-jvm \ 
    --tag <your-repo-prefix>/hello-function-jvm:latest \ 
    --git https://github.com/ddobrin/spring-native-function-knative.git \
    --git-revision main \
    --cluster-builder base \ 
    --env BP_JVM_VERSION=11 \
    --env BP_MAVEN_BUILD_ARGUMENTS="-Dmaven.test.skip=true package spring-boot:repackage -Pjvm-image" \
    --wait 

* your-repo-prefix - prefix for your Container Registry. Ex. Docker-desktop hello-function:jvm, GCR gcr.io/pa-ddobrin/hello-function:jvm
* tag - image tag
* git - repo location 
* local-path - to build from a local download of the repo, replace "git" with "local-path"
        --local-path ~/spring-native-function-knative
* git-revision - the code branch in Git
* cluster-builder - the Paketo builder used to build the image
* BP_JVM_VERSION - Java version to build for, accepts 8, 11
* wait - if you wish to observe the build taking place
* BP_MAVEN_BUILD_ARGUMENTS - kpack/TBS works declaratively in K8s, therefore requires instructions for the `repackaging` goal to be triggered; local machine is imperative and `package` in pom.xml is sufficient. 
```

## Building Java Native Docker images
To build the JVM image with the Java Native Paketo Buildpack, please run:
```shell
$ kp image save hello-function-native \ 
    --tag <your-repo-prefix>/hello-function-native:latest \ 
    --git https://github.com/ddobrin/spring-native-function-knative.git \
    --git-revision main \
    --cluster-builder tiny \ 
    --env BP_BOOT_NATIVE_IMAGE=1 \
    --env BP_JVM_VERSION=11 \
    --env BP_MAVEN_BUILD_ARGUMENTS="-Dmaven.test.skip=true package spring-boot:repackage -Pnative-image" \
    --env BP_BOOT_NATIVE_IMAGE_BUILD_ARGUMENTS="-Dspring.spel.ignore=true -Dspring.xml.ignore=true -Dspring.native.remove-yaml-support=true --enable-all-security-services" \
    --wait 

* your-repo-prefix - prefix for your Container Registry. Ex. Docker-desktop hello-function:native, GCR gcr.io/pa-ddobrin/hello-function:native 
* tag - image tag
* git - repo location 
* local-path - to build from a local download of the repo, replace "git" with "local-path"
        --local-path ~/spring-native-function-knative
* git-revision - the code branch in Git
* cluster-builder - the Paketo builder used to build the image
* BP_BOOT_NATIVE_IMAGE - set to true builds a Spring Native image
* BP_JVM_VERSION - Java version to build for, accepts 8, 11
* wait - if you wish to observe the build taking place
* BP_MAVEN_BUILD_ARGUMENTS - kpack/TBS works declaratively in K8s, therefore requires instructions for the `repackaging` goal to be triggered; local machine is imperative and `package` in pom.xml is sufficient. 
* BP_BOOT_NATIVE_IMAGE_BUILD_ARGUMENTS - optimization arguments for the Native image to minimize image size
```