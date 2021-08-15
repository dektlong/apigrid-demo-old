# Accelerator Log

## Options
```json
{
  "activeProfiles" : [ "jvm", "native-image" ],
  "artifactId" : "adopter-check",
  "deploymentType" : "knative-resource-simple",
  "projectDescription" : "",
  "projectName" : "adpoter-check"
}
```
## Log
```
┏ engine (Chain)
┃  Info Running Chain(Combo, UniquePath)
┃ ┏ engine.transformations[0] (Combo)
┃ ┃  Info Combo running as Chain(Merge(merge), UniquePath(UseLast))
┃ ┃ engine.transformations[0].merge (Chain)
┃ ┃  Info Running Chain(Merge, UniquePath)
┃ ┃ ┏ engine.transformations[0].merge.transformations[0] (Merge)
┃ ┃ ┃  Info Running Merge(Combo, Combo, Combo, Combo, Combo, Combo, Combo, Combo, Combo)
┃ ┃ ┃ ┏ engine.transformations[0].merge.transformations[0].sources[0] (Combo)
┃ ┃ ┃ ┃  Info Combo running as Chain(Include, Exclude)
┃ ┃ ┃ ┃ engine.transformations[0].merge.transformations[0].sources[0].<combo> (Chain)
┃ ┃ ┃ ┃  Info Running Chain(Include, Exclude)
┃ ┃ ┃ ┃ ┏ engine.transformations[0].merge.transformations[0].sources[0].<combo>.transformations[0] (Include)
┃ ┃ ┃ ┃ ┃  Info Will include [**]
┃ ┃ ┃ ┃ ┃ Debug compile.sh matched [**] -> included
┃ ┃ ┃ ┃ ┃ Debug .mvn/wrapper/MavenWrapperDownloader.java matched [**] -> included
┃ ┃ ┃ ┃ ┃ Debug .mvn/wrapper/maven-wrapper.jar matched [**] -> included
┃ ┃ ┃ ┃ ┃ Debug .mvn/wrapper/maven-wrapper.properties matched [**] -> included
┃ ┃ ┃ ┃ ┃ Debug mvnw matched [**] -> included
┃ ┃ ┃ ┃ ┃ Debug pom.xml matched [**] -> included
┃ ┃ ┃ ┃ ┃ Debug README.md matched [**] -> included
┃ ┃ ┃ ┃ ┃ Debug LICENSE matched [**] -> included
┃ ┃ ┃ ┃ ┃ Debug build.sh matched [**] -> included
┃ ┃ ┃ ┃ ┃ Debug mvnw.cmd matched [**] -> included
┃ ┃ ┃ ┃ ┃ Debug demo/demo.txt matched [**] -> included
┃ ┃ ┃ ┃ ┃ Debug kubernetes/kpack/new/image.yaml matched [**] -> included
┃ ┃ ┃ ┃ ┃ Debug kubernetes/kpack/new-native/image-native.yaml matched [**] -> included
┃ ┃ ┃ ┃ ┃ Debug kubernetes/skaffold/skaffold.yaml matched [**] -> included
┃ ┃ ┃ ┃ ┃ Debug kubernetes/docs/README.md matched [**] -> included
┃ ┃ ┃ ┃ ┃ Debug kubernetes/docs/DEPLOY-K8s.md matched [**] -> included
┃ ┃ ┃ ┃ ┃ Debug kubernetes/docs/KPACK.md matched [**] -> included
┃ ┃ ┃ ┃ ┃ Debug kubernetes/docs/DEPLOY-KN.md matched [**] -> included
┃ ┃ ┃ ┃ ┃ Debug kubernetes/k8s/new/service.yaml matched [**] -> included
┃ ┃ ┃ ┃ ┃ Debug kubernetes/k8s/new/deployment.yaml matched [**] -> included
┃ ┃ ┃ ┃ ┃ Debug kubernetes/k8s/new-native/service-native.yaml matched [**] -> included
┃ ┃ ┃ ┃ ┃ Debug kubernetes/k8s/new-native/deployment-native.yaml matched [**] -> included
┃ ┃ ┃ ┃ ┃ Debug kubernetes/kn/new/service.yaml matched [**] -> included
┃ ┃ ┃ ┃ ┃ Debug kubernetes/kn/new-native/service-native.yaml matched [**] -> included
┃ ┃ ┃ ┃ ┃ Debug src/test/java/com/example/hello/SpringNativeFunctionKnativeApplicationTests.java matched [**] -> included
┃ ┃ ┃ ┃ ┃ Debug src/main/resources/application.properties matched [**] -> included
┃ ┃ ┃ ┃ ┗ Debug src/main/java/com/example/hello/SpringNativeFunctionKnativeApplication.java matched [**] -> included
┃ ┃ ┃ ┃ ┏ engine.transformations[0].merge.transformations[0].sources[0].<combo>.transformations[1] (Exclude)
┃ ┃ ┃ ┃ ┃  Info Will exclude [kubernetes/**, README.md]
┃ ┃ ┃ ┃ ┃ Debug compile.sh didn't match [kubernetes/**, README.md] -> included
┃ ┃ ┃ ┃ ┃ Debug .mvn/wrapper/MavenWrapperDownloader.java didn't match [kubernetes/**, README.md] -> included
┃ ┃ ┃ ┃ ┃ Debug .mvn/wrapper/maven-wrapper.jar didn't match [kubernetes/**, README.md] -> included
┃ ┃ ┃ ┃ ┃ Debug .mvn/wrapper/maven-wrapper.properties didn't match [kubernetes/**, README.md] -> included
┃ ┃ ┃ ┃ ┃ Debug mvnw didn't match [kubernetes/**, README.md] -> included
┃ ┃ ┃ ┃ ┃ Debug pom.xml didn't match [kubernetes/**, README.md] -> included
┃ ┃ ┃ ┃ ┃ Debug README.md matched [kubernetes/**, README.md] -> excluded
┃ ┃ ┃ ┃ ┃ Debug LICENSE didn't match [kubernetes/**, README.md] -> included
┃ ┃ ┃ ┃ ┃ Debug build.sh didn't match [kubernetes/**, README.md] -> included
┃ ┃ ┃ ┃ ┃ Debug mvnw.cmd didn't match [kubernetes/**, README.md] -> included
┃ ┃ ┃ ┃ ┃ Debug demo/demo.txt didn't match [kubernetes/**, README.md] -> included
┃ ┃ ┃ ┃ ┃ Debug kubernetes/kpack/new/image.yaml matched [kubernetes/**, README.md] -> excluded
┃ ┃ ┃ ┃ ┃ Debug kubernetes/kpack/new-native/image-native.yaml matched [kubernetes/**, README.md] -> excluded
┃ ┃ ┃ ┃ ┃ Debug kubernetes/skaffold/skaffold.yaml matched [kubernetes/**, README.md] -> excluded
┃ ┃ ┃ ┃ ┃ Debug kubernetes/docs/README.md matched [kubernetes/**, README.md] -> excluded
┃ ┃ ┃ ┃ ┃ Debug kubernetes/docs/DEPLOY-K8s.md matched [kubernetes/**, README.md] -> excluded
┃ ┃ ┃ ┃ ┃ Debug kubernetes/docs/KPACK.md matched [kubernetes/**, README.md] -> excluded
┃ ┃ ┃ ┃ ┃ Debug kubernetes/docs/DEPLOY-KN.md matched [kubernetes/**, README.md] -> excluded
┃ ┃ ┃ ┃ ┃ Debug kubernetes/k8s/new/service.yaml matched [kubernetes/**, README.md] -> excluded
┃ ┃ ┃ ┃ ┃ Debug kubernetes/k8s/new/deployment.yaml matched [kubernetes/**, README.md] -> excluded
┃ ┃ ┃ ┃ ┃ Debug kubernetes/k8s/new-native/service-native.yaml matched [kubernetes/**, README.md] -> excluded
┃ ┃ ┃ ┃ ┃ Debug kubernetes/k8s/new-native/deployment-native.yaml matched [kubernetes/**, README.md] -> excluded
┃ ┃ ┃ ┃ ┃ Debug kubernetes/kn/new/service.yaml matched [kubernetes/**, README.md] -> excluded
┃ ┃ ┃ ┃ ┃ Debug kubernetes/kn/new-native/service-native.yaml matched [kubernetes/**, README.md] -> excluded
┃ ┃ ┃ ┃ ┃ Debug src/test/java/com/example/hello/SpringNativeFunctionKnativeApplicationTests.java didn't match [kubernetes/**, README.md] -> included
┃ ┃ ┃ ┃ ┃ Debug src/main/resources/application.properties didn't match [kubernetes/**, README.md] -> included
┃ ┃ ┃ ┗ ┗ Debug src/main/java/com/example/hello/SpringNativeFunctionKnativeApplication.java didn't match [kubernetes/**, README.md] -> included
┃ ┃ ┃ ┏ engine.transformations[0].merge.transformations[0].sources[1] (Combo)
┃ ┃ ┃ ┃  Info Combo running as Chain(chain)
┃ ┃ ┃ ┃ engine.transformations[0].merge.transformations[0].sources[1].chain (Chain)
┃ ┃ ┃ ┃  Info Running Chain(Combo, ReplaceText, ReplaceText, ReplaceText, ReplaceText, ReplaceText, ReplaceText)
┃ ┃ ┃ ┃ ┏ engine.transformations[0].merge.transformations[0].sources[1].chain.transformations[0] (Combo)
┃ ┃ ┃ ┃ ┃  Info Combo running as Include
┃ ┃ ┃ ┃ ┃ engine.transformations[0].merge.transformations[0].sources[1].chain.transformations[0].include (Include)
┃ ┃ ┃ ┃ ┃  Info Will include [pom.xml]
┃ ┃ ┃ ┃ ┃ Debug compile.sh didn't match [pom.xml] -> excluded
┃ ┃ ┃ ┃ ┃ Debug .mvn/wrapper/MavenWrapperDownloader.java didn't match [pom.xml] -> excluded
┃ ┃ ┃ ┃ ┃ Debug .mvn/wrapper/maven-wrapper.jar didn't match [pom.xml] -> excluded
┃ ┃ ┃ ┃ ┃ Debug .mvn/wrapper/maven-wrapper.properties didn't match [pom.xml] -> excluded
┃ ┃ ┃ ┃ ┃ Debug mvnw didn't match [pom.xml] -> excluded
┃ ┃ ┃ ┃ ┃ Debug pom.xml matched [pom.xml] -> included
┃ ┃ ┃ ┃ ┃ Debug README.md didn't match [pom.xml] -> excluded
┃ ┃ ┃ ┃ ┃ Debug LICENSE didn't match [pom.xml] -> excluded
┃ ┃ ┃ ┃ ┃ Debug build.sh didn't match [pom.xml] -> excluded
┃ ┃ ┃ ┃ ┃ Debug mvnw.cmd didn't match [pom.xml] -> excluded
┃ ┃ ┃ ┃ ┃ Debug demo/demo.txt didn't match [pom.xml] -> excluded
┃ ┃ ┃ ┃ ┃ Debug kubernetes/kpack/new/image.yaml didn't match [pom.xml] -> excluded
┃ ┃ ┃ ┃ ┃ Debug kubernetes/kpack/new-native/image-native.yaml didn't match [pom.xml] -> excluded
┃ ┃ ┃ ┃ ┃ Debug kubernetes/skaffold/skaffold.yaml didn't match [pom.xml] -> excluded
┃ ┃ ┃ ┃ ┃ Debug kubernetes/docs/README.md didn't match [pom.xml] -> excluded
┃ ┃ ┃ ┃ ┃ Debug kubernetes/docs/DEPLOY-K8s.md didn't match [pom.xml] -> excluded
┃ ┃ ┃ ┃ ┃ Debug kubernetes/docs/KPACK.md didn't match [pom.xml] -> excluded
┃ ┃ ┃ ┃ ┃ Debug kubernetes/docs/DEPLOY-KN.md didn't match [pom.xml] -> excluded
┃ ┃ ┃ ┃ ┃ Debug kubernetes/k8s/new/service.yaml didn't match [pom.xml] -> excluded
┃ ┃ ┃ ┃ ┃ Debug kubernetes/k8s/new/deployment.yaml didn't match [pom.xml] -> excluded
┃ ┃ ┃ ┃ ┃ Debug kubernetes/k8s/new-native/service-native.yaml didn't match [pom.xml] -> excluded
┃ ┃ ┃ ┃ ┃ Debug kubernetes/k8s/new-native/deployment-native.yaml didn't match [pom.xml] -> excluded
┃ ┃ ┃ ┃ ┃ Debug kubernetes/kn/new/service.yaml didn't match [pom.xml] -> excluded
┃ ┃ ┃ ┃ ┃ Debug kubernetes/kn/new-native/service-native.yaml didn't match [pom.xml] -> excluded
┃ ┃ ┃ ┃ ┃ Debug src/test/java/com/example/hello/SpringNativeFunctionKnativeApplicationTests.java didn't match [pom.xml] -> excluded
┃ ┃ ┃ ┃ ┃ Debug src/main/resources/application.properties didn't match [pom.xml] -> excluded
┃ ┃ ┃ ┃ ┗ Debug src/main/java/com/example/hello/SpringNativeFunctionKnativeApplication.java didn't match [pom.xml] -> excluded
┃ ┃ ┃ ┃ ┏ engine.transformations[0].merge.transformations[0].sources[1].chain.transformations[1] (ReplaceText)
┃ ┃ ┃ ┃ ┗  Info Will replace [hello-function->adopter-check]
┃ ┃ ┃ ┃ ┏ engine.transformations[0].merge.transformations[0].sources[1].chain.transformations[2] (ReplaceText)
┃ ┃ ┃ ┃ ┗  Info Will replace [registryPrefix->docker.io/triathlonguy]
┃ ┃ ┃ ┃ ┏ engine.transformations[0].merge.transformations[0].sources[1].chain.transformations[3] (ReplaceText)
┃ ┃ ┃ ┃ ┃  Info Condition (!(#activeProfiles.contains('jvm'))) evaluated to false
┃ ┃ ┃ ┃ ┗ null ()
┃ ┃ ┃ ┃ ┏ engine.transformations[0].merge.transformations[0].sources[1].chain.transformations[4] (ReplaceText)
┃ ┃ ┃ ┃ ┃  Info Condition (!(#activeProfiles.contains('jvm-image'))) evaluated to true
┃ ┃ ┃ ┃ ┗  Info Will replace [<!--end-jvm-image-->->end-jvm-image-->, <!--start-jvm-image-->-><!--start-jvm-image]
┃ ┃ ┃ ┃ ┏ engine.transformations[0].merge.transformations[0].sources[1].chain.transformations[5] (ReplaceText)
┃ ┃ ┃ ┃ ┃  Info Condition (!(#activeProfiles.contains('native'))) evaluated to true
┃ ┃ ┃ ┃ ┗  Info Will replace [<!--end-native-->->end-native-->, <!--start-native-->-><!--start-native]
┃ ┃ ┃ ┃ ┏ engine.transformations[0].merge.transformations[0].sources[1].chain.transformations[6] (ReplaceText)
┃ ┃ ┃ ┃ ┃  Info Condition (!(#activeProfiles.contains('native-image'))) evaluated to false
┃ ┃ ┃ ┗ ┗ null ()
┃ ┃ ┃ ┏ engine.transformations[0].merge.transformations[0].sources[2] (Combo)
┃ ┃ ┃ ┃  Info Condition (#deploymentType == 'knative-resource-simple') evaluated to true
┃ ┃ ┃ ┃  Info Combo running as Chain(Include, Chain(chain))
┃ ┃ ┃ ┃ engine.transformations[0].merge.transformations[0].sources[2].<combo> (Chain)
┃ ┃ ┃ ┃  Info Condition (#deploymentType == 'knative-resource-simple') evaluated to true
┃ ┃ ┃ ┃  Info Running Chain(Include, Chain)
┃ ┃ ┃ ┃ ┏ engine.transformations[0].merge.transformations[0].sources[2].<combo>.transformations[0] (Include)
┃ ┃ ┃ ┃ ┃  Info Will include [kubernetes/kn/*/service*.yaml]
┃ ┃ ┃ ┃ ┃ Debug compile.sh didn't match [kubernetes/kn/*/service*.yaml] -> excluded
┃ ┃ ┃ ┃ ┃ Debug .mvn/wrapper/MavenWrapperDownloader.java didn't match [kubernetes/kn/*/service*.yaml] -> excluded
┃ ┃ ┃ ┃ ┃ Debug .mvn/wrapper/maven-wrapper.jar didn't match [kubernetes/kn/*/service*.yaml] -> excluded
┃ ┃ ┃ ┃ ┃ Debug .mvn/wrapper/maven-wrapper.properties didn't match [kubernetes/kn/*/service*.yaml] -> excluded
┃ ┃ ┃ ┃ ┃ Debug mvnw didn't match [kubernetes/kn/*/service*.yaml] -> excluded
┃ ┃ ┃ ┃ ┃ Debug pom.xml didn't match [kubernetes/kn/*/service*.yaml] -> excluded
┃ ┃ ┃ ┃ ┃ Debug README.md didn't match [kubernetes/kn/*/service*.yaml] -> excluded
┃ ┃ ┃ ┃ ┃ Debug LICENSE didn't match [kubernetes/kn/*/service*.yaml] -> excluded
┃ ┃ ┃ ┃ ┃ Debug build.sh didn't match [kubernetes/kn/*/service*.yaml] -> excluded
┃ ┃ ┃ ┃ ┃ Debug mvnw.cmd didn't match [kubernetes/kn/*/service*.yaml] -> excluded
┃ ┃ ┃ ┃ ┃ Debug demo/demo.txt didn't match [kubernetes/kn/*/service*.yaml] -> excluded
┃ ┃ ┃ ┃ ┃ Debug kubernetes/kpack/new/image.yaml didn't match [kubernetes/kn/*/service*.yaml] -> excluded
┃ ┃ ┃ ┃ ┃ Debug kubernetes/kpack/new-native/image-native.yaml didn't match [kubernetes/kn/*/service*.yaml] -> excluded
┃ ┃ ┃ ┃ ┃ Debug kubernetes/skaffold/skaffold.yaml didn't match [kubernetes/kn/*/service*.yaml] -> excluded
┃ ┃ ┃ ┃ ┃ Debug kubernetes/docs/README.md didn't match [kubernetes/kn/*/service*.yaml] -> excluded
┃ ┃ ┃ ┃ ┃ Debug kubernetes/docs/DEPLOY-K8s.md didn't match [kubernetes/kn/*/service*.yaml] -> excluded
┃ ┃ ┃ ┃ ┃ Debug kubernetes/docs/KPACK.md didn't match [kubernetes/kn/*/service*.yaml] -> excluded
┃ ┃ ┃ ┃ ┃ Debug kubernetes/docs/DEPLOY-KN.md didn't match [kubernetes/kn/*/service*.yaml] -> excluded
┃ ┃ ┃ ┃ ┃ Debug kubernetes/k8s/new/service.yaml didn't match [kubernetes/kn/*/service*.yaml] -> excluded
┃ ┃ ┃ ┃ ┃ Debug kubernetes/k8s/new/deployment.yaml didn't match [kubernetes/kn/*/service*.yaml] -> excluded
┃ ┃ ┃ ┃ ┃ Debug kubernetes/k8s/new-native/service-native.yaml didn't match [kubernetes/kn/*/service*.yaml] -> excluded
┃ ┃ ┃ ┃ ┃ Debug kubernetes/k8s/new-native/deployment-native.yaml didn't match [kubernetes/kn/*/service*.yaml] -> excluded
┃ ┃ ┃ ┃ ┃ Debug kubernetes/kn/new/service.yaml matched [kubernetes/kn/*/service*.yaml] -> included
┃ ┃ ┃ ┃ ┃ Debug kubernetes/kn/new-native/service-native.yaml matched [kubernetes/kn/*/service*.yaml] -> included
┃ ┃ ┃ ┃ ┃ Debug src/test/java/com/example/hello/SpringNativeFunctionKnativeApplicationTests.java didn't match [kubernetes/kn/*/service*.yaml] -> excluded
┃ ┃ ┃ ┃ ┃ Debug src/main/resources/application.properties didn't match [kubernetes/kn/*/service*.yaml] -> excluded
┃ ┃ ┃ ┃ ┗ Debug src/main/java/com/example/hello/SpringNativeFunctionKnativeApplication.java didn't match [kubernetes/kn/*/service*.yaml] -> excluded
┃ ┃ ┃ ┃ ┏ engine.transformations[0].merge.transformations[0].sources[2].<combo>.transformations[1] (Chain)
┃ ┃ ┃ ┃ ┃  Info Running Chain(ReplaceText)
┃ ┃ ┃ ┃ ┃ ┏ engine.transformations[0].merge.transformations[0].sources[2].<combo>.transformations[1].transformations[0] (ReplaceText)
┃ ┃ ┃ ┗ ┗ ┗  Info Will replace [hello-function->adopter-check]
┃ ┃ ┃ ┏ engine.transformations[0].merge.transformations[0].sources[3] (Combo)
┃ ┃ ┃ ┃  Info Condition (#deploymentType == 'kubernetes-resource-simple') evaluated to false
┃ ┃ ┃ ┗ null ()
┃ ┃ ┃ ┏ engine.transformations[0].merge.transformations[0].sources[4] (Combo)
┃ ┃ ┃ ┃  Info Condition (#includeSkaffold) evaluated to true
┃ ┃ ┃ ┃  Info Combo running as Chain(Include, Chain(chain))
┃ ┃ ┃ ┃ engine.transformations[0].merge.transformations[0].sources[4].<combo> (Chain)
┃ ┃ ┃ ┃  Info Condition (#includeSkaffold) evaluated to true
┃ ┃ ┃ ┃  Info Running Chain(Include, Chain)
┃ ┃ ┃ ┃ ┏ engine.transformations[0].merge.transformations[0].sources[4].<combo>.transformations[0] (Include)
┃ ┃ ┃ ┃ ┃  Info Will include [kubernetes/skaffold/skaffold.yaml]
┃ ┃ ┃ ┃ ┃ Debug compile.sh didn't match [kubernetes/skaffold/skaffold.yaml] -> excluded
┃ ┃ ┃ ┃ ┃ Debug .mvn/wrapper/MavenWrapperDownloader.java didn't match [kubernetes/skaffold/skaffold.yaml] -> excluded
┃ ┃ ┃ ┃ ┃ Debug .mvn/wrapper/maven-wrapper.jar didn't match [kubernetes/skaffold/skaffold.yaml] -> excluded
┃ ┃ ┃ ┃ ┃ Debug .mvn/wrapper/maven-wrapper.properties didn't match [kubernetes/skaffold/skaffold.yaml] -> excluded
┃ ┃ ┃ ┃ ┃ Debug mvnw didn't match [kubernetes/skaffold/skaffold.yaml] -> excluded
┃ ┃ ┃ ┃ ┃ Debug pom.xml didn't match [kubernetes/skaffold/skaffold.yaml] -> excluded
┃ ┃ ┃ ┃ ┃ Debug README.md didn't match [kubernetes/skaffold/skaffold.yaml] -> excluded
┃ ┃ ┃ ┃ ┃ Debug LICENSE didn't match [kubernetes/skaffold/skaffold.yaml] -> excluded
┃ ┃ ┃ ┃ ┃ Debug build.sh didn't match [kubernetes/skaffold/skaffold.yaml] -> excluded
┃ ┃ ┃ ┃ ┃ Debug mvnw.cmd didn't match [kubernetes/skaffold/skaffold.yaml] -> excluded
┃ ┃ ┃ ┃ ┃ Debug demo/demo.txt didn't match [kubernetes/skaffold/skaffold.yaml] -> excluded
┃ ┃ ┃ ┃ ┃ Debug kubernetes/kpack/new/image.yaml didn't match [kubernetes/skaffold/skaffold.yaml] -> excluded
┃ ┃ ┃ ┃ ┃ Debug kubernetes/kpack/new-native/image-native.yaml didn't match [kubernetes/skaffold/skaffold.yaml] -> excluded
┃ ┃ ┃ ┃ ┃ Debug kubernetes/skaffold/skaffold.yaml matched [kubernetes/skaffold/skaffold.yaml] -> included
┃ ┃ ┃ ┃ ┃ Debug kubernetes/docs/README.md didn't match [kubernetes/skaffold/skaffold.yaml] -> excluded
┃ ┃ ┃ ┃ ┃ Debug kubernetes/docs/DEPLOY-K8s.md didn't match [kubernetes/skaffold/skaffold.yaml] -> excluded
┃ ┃ ┃ ┃ ┃ Debug kubernetes/docs/KPACK.md didn't match [kubernetes/skaffold/skaffold.yaml] -> excluded
┃ ┃ ┃ ┃ ┃ Debug kubernetes/docs/DEPLOY-KN.md didn't match [kubernetes/skaffold/skaffold.yaml] -> excluded
┃ ┃ ┃ ┃ ┃ Debug kubernetes/k8s/new/service.yaml didn't match [kubernetes/skaffold/skaffold.yaml] -> excluded
┃ ┃ ┃ ┃ ┃ Debug kubernetes/k8s/new/deployment.yaml didn't match [kubernetes/skaffold/skaffold.yaml] -> excluded
┃ ┃ ┃ ┃ ┃ Debug kubernetes/k8s/new-native/service-native.yaml didn't match [kubernetes/skaffold/skaffold.yaml] -> excluded
┃ ┃ ┃ ┃ ┃ Debug kubernetes/k8s/new-native/deployment-native.yaml didn't match [kubernetes/skaffold/skaffold.yaml] -> excluded
┃ ┃ ┃ ┃ ┃ Debug kubernetes/kn/new/service.yaml didn't match [kubernetes/skaffold/skaffold.yaml] -> excluded
┃ ┃ ┃ ┃ ┃ Debug kubernetes/kn/new-native/service-native.yaml didn't match [kubernetes/skaffold/skaffold.yaml] -> excluded
┃ ┃ ┃ ┃ ┃ Debug src/test/java/com/example/hello/SpringNativeFunctionKnativeApplicationTests.java didn't match [kubernetes/skaffold/skaffold.yaml] -> excluded
┃ ┃ ┃ ┃ ┃ Debug src/main/resources/application.properties didn't match [kubernetes/skaffold/skaffold.yaml] -> excluded
┃ ┃ ┃ ┃ ┗ Debug src/main/java/com/example/hello/SpringNativeFunctionKnativeApplication.java didn't match [kubernetes/skaffold/skaffold.yaml] -> excluded
┃ ┃ ┃ ┃ ┏ engine.transformations[0].merge.transformations[0].sources[4].<combo>.transformations[1] (Chain)
┃ ┃ ┃ ┃ ┃  Info Running Chain(ReplaceText, ReplaceText)
┃ ┃ ┃ ┃ ┃ ┏ engine.transformations[0].merge.transformations[0].sources[4].<combo>.transformations[1].transformations[0] (ReplaceText)
┃ ┃ ┃ ┃ ┃ ┗  Info Will replace [hello-function->adopter-check]
┃ ┃ ┃ ┃ ┃ ┏ engine.transformations[0].merge.transformations[0].sources[4].<combo>.transformations[1].transformations[1] (ReplaceText)
┃ ┃ ┃ ┗ ┗ ┗  Info Will replace [registryPrefix->docker.io/triathlonguy]
┃ ┃ ┃ ┏ engine.transformations[0].merge.transformations[0].sources[5] (Combo)
┃ ┃ ┃ ┃  Info Condition (#includeKpackImage) evaluated to true
┃ ┃ ┃ ┃  Info Combo running as Chain(Include, Chain(chain))
┃ ┃ ┃ ┃ engine.transformations[0].merge.transformations[0].sources[5].<combo> (Chain)
┃ ┃ ┃ ┃  Info Condition (#includeKpackImage) evaluated to true
┃ ┃ ┃ ┃  Info Running Chain(Include, Chain)
┃ ┃ ┃ ┃ ┏ engine.transformations[0].merge.transformations[0].sources[5].<combo>.transformations[0] (Include)
┃ ┃ ┃ ┃ ┃  Info Will include [kubernetes/kpack/*/image*.yaml]
┃ ┃ ┃ ┃ ┃ Debug compile.sh didn't match [kubernetes/kpack/*/image*.yaml] -> excluded
┃ ┃ ┃ ┃ ┃ Debug .mvn/wrapper/MavenWrapperDownloader.java didn't match [kubernetes/kpack/*/image*.yaml] -> excluded
┃ ┃ ┃ ┃ ┃ Debug .mvn/wrapper/maven-wrapper.jar didn't match [kubernetes/kpack/*/image*.yaml] -> excluded
┃ ┃ ┃ ┃ ┃ Debug .mvn/wrapper/maven-wrapper.properties didn't match [kubernetes/kpack/*/image*.yaml] -> excluded
┃ ┃ ┃ ┃ ┃ Debug mvnw didn't match [kubernetes/kpack/*/image*.yaml] -> excluded
┃ ┃ ┃ ┃ ┃ Debug pom.xml didn't match [kubernetes/kpack/*/image*.yaml] -> excluded
┃ ┃ ┃ ┃ ┃ Debug README.md didn't match [kubernetes/kpack/*/image*.yaml] -> excluded
┃ ┃ ┃ ┃ ┃ Debug LICENSE didn't match [kubernetes/kpack/*/image*.yaml] -> excluded
┃ ┃ ┃ ┃ ┃ Debug build.sh didn't match [kubernetes/kpack/*/image*.yaml] -> excluded
┃ ┃ ┃ ┃ ┃ Debug mvnw.cmd didn't match [kubernetes/kpack/*/image*.yaml] -> excluded
┃ ┃ ┃ ┃ ┃ Debug demo/demo.txt didn't match [kubernetes/kpack/*/image*.yaml] -> excluded
┃ ┃ ┃ ┃ ┃ Debug kubernetes/kpack/new/image.yaml matched [kubernetes/kpack/*/image*.yaml] -> included
┃ ┃ ┃ ┃ ┃ Debug kubernetes/kpack/new-native/image-native.yaml matched [kubernetes/kpack/*/image*.yaml] -> included
┃ ┃ ┃ ┃ ┃ Debug kubernetes/skaffold/skaffold.yaml didn't match [kubernetes/kpack/*/image*.yaml] -> excluded
┃ ┃ ┃ ┃ ┃ Debug kubernetes/docs/README.md didn't match [kubernetes/kpack/*/image*.yaml] -> excluded
┃ ┃ ┃ ┃ ┃ Debug kubernetes/docs/DEPLOY-K8s.md didn't match [kubernetes/kpack/*/image*.yaml] -> excluded
┃ ┃ ┃ ┃ ┃ Debug kubernetes/docs/KPACK.md didn't match [kubernetes/kpack/*/image*.yaml] -> excluded
┃ ┃ ┃ ┃ ┃ Debug kubernetes/docs/DEPLOY-KN.md didn't match [kubernetes/kpack/*/image*.yaml] -> excluded
┃ ┃ ┃ ┃ ┃ Debug kubernetes/k8s/new/service.yaml didn't match [kubernetes/kpack/*/image*.yaml] -> excluded
┃ ┃ ┃ ┃ ┃ Debug kubernetes/k8s/new/deployment.yaml didn't match [kubernetes/kpack/*/image*.yaml] -> excluded
┃ ┃ ┃ ┃ ┃ Debug kubernetes/k8s/new-native/service-native.yaml didn't match [kubernetes/kpack/*/image*.yaml] -> excluded
┃ ┃ ┃ ┃ ┃ Debug kubernetes/k8s/new-native/deployment-native.yaml didn't match [kubernetes/kpack/*/image*.yaml] -> excluded
┃ ┃ ┃ ┃ ┃ Debug kubernetes/kn/new/service.yaml didn't match [kubernetes/kpack/*/image*.yaml] -> excluded
┃ ┃ ┃ ┃ ┃ Debug kubernetes/kn/new-native/service-native.yaml didn't match [kubernetes/kpack/*/image*.yaml] -> excluded
┃ ┃ ┃ ┃ ┃ Debug src/test/java/com/example/hello/SpringNativeFunctionKnativeApplicationTests.java didn't match [kubernetes/kpack/*/image*.yaml] -> excluded
┃ ┃ ┃ ┃ ┃ Debug src/main/resources/application.properties didn't match [kubernetes/kpack/*/image*.yaml] -> excluded
┃ ┃ ┃ ┃ ┗ Debug src/main/java/com/example/hello/SpringNativeFunctionKnativeApplication.java didn't match [kubernetes/kpack/*/image*.yaml] -> excluded
┃ ┃ ┃ ┃ ┏ engine.transformations[0].merge.transformations[0].sources[5].<combo>.transformations[1] (Chain)
┃ ┃ ┃ ┃ ┃  Info Running Chain(ReplaceText, ReplaceText)
┃ ┃ ┃ ┃ ┃ ┏ engine.transformations[0].merge.transformations[0].sources[5].<combo>.transformations[1].transformations[0] (ReplaceText)
┃ ┃ ┃ ┃ ┃ ┗  Info Will replace [hello-function->adopter-check]
┃ ┃ ┃ ┃ ┃ ┏ engine.transformations[0].merge.transformations[0].sources[5].<combo>.transformations[1].transformations[1] (ReplaceText)
┃ ┃ ┃ ┗ ┗ ┗  Info Will replace [registryPrefix->docker.io/triathlonguy]
┃ ┃ ┃ ┏ engine.transformations[0].merge.transformations[0].sources[6] (Combo)
┃ ┃ ┃ ┃  Info Condition (#deploymentType == 'knative-resource-simple') evaluated to true
┃ ┃ ┃ ┃  Info Combo running as Chain(Include, Chain(chain))
┃ ┃ ┃ ┃ engine.transformations[0].merge.transformations[0].sources[6].<combo> (Chain)
┃ ┃ ┃ ┃  Info Condition (#deploymentType == 'knative-resource-simple') evaluated to true
┃ ┃ ┃ ┃  Info Running Chain(Include, Chain)
┃ ┃ ┃ ┃ ┏ engine.transformations[0].merge.transformations[0].sources[6].<combo>.transformations[0] (Include)
┃ ┃ ┃ ┃ ┃  Info Will include [kubernetes/kn/*/service*.yaml]
┃ ┃ ┃ ┃ ┃ Debug compile.sh didn't match [kubernetes/kn/*/service*.yaml] -> excluded
┃ ┃ ┃ ┃ ┃ Debug .mvn/wrapper/MavenWrapperDownloader.java didn't match [kubernetes/kn/*/service*.yaml] -> excluded
┃ ┃ ┃ ┃ ┃ Debug .mvn/wrapper/maven-wrapper.jar didn't match [kubernetes/kn/*/service*.yaml] -> excluded
┃ ┃ ┃ ┃ ┃ Debug .mvn/wrapper/maven-wrapper.properties didn't match [kubernetes/kn/*/service*.yaml] -> excluded
┃ ┃ ┃ ┃ ┃ Debug mvnw didn't match [kubernetes/kn/*/service*.yaml] -> excluded
┃ ┃ ┃ ┃ ┃ Debug pom.xml didn't match [kubernetes/kn/*/service*.yaml] -> excluded
┃ ┃ ┃ ┃ ┃ Debug README.md didn't match [kubernetes/kn/*/service*.yaml] -> excluded
┃ ┃ ┃ ┃ ┃ Debug LICENSE didn't match [kubernetes/kn/*/service*.yaml] -> excluded
┃ ┃ ┃ ┃ ┃ Debug build.sh didn't match [kubernetes/kn/*/service*.yaml] -> excluded
┃ ┃ ┃ ┃ ┃ Debug mvnw.cmd didn't match [kubernetes/kn/*/service*.yaml] -> excluded
┃ ┃ ┃ ┃ ┃ Debug demo/demo.txt didn't match [kubernetes/kn/*/service*.yaml] -> excluded
┃ ┃ ┃ ┃ ┃ Debug kubernetes/kpack/new/image.yaml didn't match [kubernetes/kn/*/service*.yaml] -> excluded
┃ ┃ ┃ ┃ ┃ Debug kubernetes/kpack/new-native/image-native.yaml didn't match [kubernetes/kn/*/service*.yaml] -> excluded
┃ ┃ ┃ ┃ ┃ Debug kubernetes/skaffold/skaffold.yaml didn't match [kubernetes/kn/*/service*.yaml] -> excluded
┃ ┃ ┃ ┃ ┃ Debug kubernetes/docs/README.md didn't match [kubernetes/kn/*/service*.yaml] -> excluded
┃ ┃ ┃ ┃ ┃ Debug kubernetes/docs/DEPLOY-K8s.md didn't match [kubernetes/kn/*/service*.yaml] -> excluded
┃ ┃ ┃ ┃ ┃ Debug kubernetes/docs/KPACK.md didn't match [kubernetes/kn/*/service*.yaml] -> excluded
┃ ┃ ┃ ┃ ┃ Debug kubernetes/docs/DEPLOY-KN.md didn't match [kubernetes/kn/*/service*.yaml] -> excluded
┃ ┃ ┃ ┃ ┃ Debug kubernetes/k8s/new/service.yaml didn't match [kubernetes/kn/*/service*.yaml] -> excluded
┃ ┃ ┃ ┃ ┃ Debug kubernetes/k8s/new/deployment.yaml didn't match [kubernetes/kn/*/service*.yaml] -> excluded
┃ ┃ ┃ ┃ ┃ Debug kubernetes/k8s/new-native/service-native.yaml didn't match [kubernetes/kn/*/service*.yaml] -> excluded
┃ ┃ ┃ ┃ ┃ Debug kubernetes/k8s/new-native/deployment-native.yaml didn't match [kubernetes/kn/*/service*.yaml] -> excluded
┃ ┃ ┃ ┃ ┃ Debug kubernetes/kn/new/service.yaml matched [kubernetes/kn/*/service*.yaml] -> included
┃ ┃ ┃ ┃ ┃ Debug kubernetes/kn/new-native/service-native.yaml matched [kubernetes/kn/*/service*.yaml] -> included
┃ ┃ ┃ ┃ ┃ Debug src/test/java/com/example/hello/SpringNativeFunctionKnativeApplicationTests.java didn't match [kubernetes/kn/*/service*.yaml] -> excluded
┃ ┃ ┃ ┃ ┃ Debug src/main/resources/application.properties didn't match [kubernetes/kn/*/service*.yaml] -> excluded
┃ ┃ ┃ ┃ ┗ Debug src/main/java/com/example/hello/SpringNativeFunctionKnativeApplication.java didn't match [kubernetes/kn/*/service*.yaml] -> excluded
┃ ┃ ┃ ┃ ┏ engine.transformations[0].merge.transformations[0].sources[6].<combo>.transformations[1] (Chain)
┃ ┃ ┃ ┃ ┃  Info Running Chain(ReplaceText)
┃ ┃ ┃ ┃ ┃ ┏ engine.transformations[0].merge.transformations[0].sources[6].<combo>.transformations[1].transformations[0] (ReplaceText)
┃ ┃ ┃ ┗ ┗ ┗  Info Will replace [registryPrefix->docker.io/triathlonguy]
┃ ┃ ┃ ┏ engine.transformations[0].merge.transformations[0].sources[7] (Combo)
┃ ┃ ┃ ┃  Info Condition (#deploymentType == 'kubernetes-resource-simple') evaluated to false
┃ ┃ ┃ ┗ null ()
┃ ┃ ┃ ┏ README (Combo)
┃ ┃ ┃ ┃  Info Combo running as Chain(Merge(merge), UniquePath(Append))
┃ ┃ ┃ ┃ README.merge (Chain)
┃ ┃ ┃ ┃  Info Running Chain(Merge, UniquePath)
┃ ┃ ┃ ┃ ┏ README.merge.transformations[0] (Merge)
┃ ┃ ┃ ┃ ┃  Info Running Merge(Combo, Combo, Combo, Combo)
┃ ┃ ┃ ┃ ┃ ┏ README.merge.transformations[0].sources[0] (Combo)
┃ ┃ ┃ ┃ ┃ ┃  Info Combo running as Chain(Include, Chain(chain))
┃ ┃ ┃ ┃ ┃ ┃ README.merge.transformations[0].sources[0].<combo> (Chain)
┃ ┃ ┃ ┃ ┃ ┃  Info Running Chain(Include, Chain)
┃ ┃ ┃ ┃ ┃ ┃ ┏ README.merge.transformations[0].sources[0].<combo>.transformations[0] (Include)
┃ ┃ ┃ ┃ ┃ ┃ ┃  Info Will include [kubernetes/docs/README.md]
┃ ┃ ┃ ┃ ┃ ┃ ┃ Debug compile.sh didn't match [kubernetes/docs/README.md] -> excluded
┃ ┃ ┃ ┃ ┃ ┃ ┃ Debug .mvn/wrapper/MavenWrapperDownloader.java didn't match [kubernetes/docs/README.md] -> excluded
┃ ┃ ┃ ┃ ┃ ┃ ┃ Debug .mvn/wrapper/maven-wrapper.jar didn't match [kubernetes/docs/README.md] -> excluded
┃ ┃ ┃ ┃ ┃ ┃ ┃ Debug .mvn/wrapper/maven-wrapper.properties didn't match [kubernetes/docs/README.md] -> excluded
┃ ┃ ┃ ┃ ┃ ┃ ┃ Debug mvnw didn't match [kubernetes/docs/README.md] -> excluded
┃ ┃ ┃ ┃ ┃ ┃ ┃ Debug pom.xml didn't match [kubernetes/docs/README.md] -> excluded
┃ ┃ ┃ ┃ ┃ ┃ ┃ Debug README.md didn't match [kubernetes/docs/README.md] -> excluded
┃ ┃ ┃ ┃ ┃ ┃ ┃ Debug LICENSE didn't match [kubernetes/docs/README.md] -> excluded
┃ ┃ ┃ ┃ ┃ ┃ ┃ Debug build.sh didn't match [kubernetes/docs/README.md] -> excluded
┃ ┃ ┃ ┃ ┃ ┃ ┃ Debug mvnw.cmd didn't match [kubernetes/docs/README.md] -> excluded
┃ ┃ ┃ ┃ ┃ ┃ ┃ Debug demo/demo.txt didn't match [kubernetes/docs/README.md] -> excluded
┃ ┃ ┃ ┃ ┃ ┃ ┃ Debug kubernetes/kpack/new/image.yaml didn't match [kubernetes/docs/README.md] -> excluded
┃ ┃ ┃ ┃ ┃ ┃ ┃ Debug kubernetes/kpack/new-native/image-native.yaml didn't match [kubernetes/docs/README.md] -> excluded
┃ ┃ ┃ ┃ ┃ ┃ ┃ Debug kubernetes/skaffold/skaffold.yaml didn't match [kubernetes/docs/README.md] -> excluded
┃ ┃ ┃ ┃ ┃ ┃ ┃ Debug kubernetes/docs/README.md matched [kubernetes/docs/README.md] -> included
┃ ┃ ┃ ┃ ┃ ┃ ┃ Debug kubernetes/docs/DEPLOY-K8s.md didn't match [kubernetes/docs/README.md] -> excluded
┃ ┃ ┃ ┃ ┃ ┃ ┃ Debug kubernetes/docs/KPACK.md didn't match [kubernetes/docs/README.md] -> excluded
┃ ┃ ┃ ┃ ┃ ┃ ┃ Debug kubernetes/docs/DEPLOY-KN.md didn't match [kubernetes/docs/README.md] -> excluded
┃ ┃ ┃ ┃ ┃ ┃ ┃ Debug kubernetes/k8s/new/service.yaml didn't match [kubernetes/docs/README.md] -> excluded
┃ ┃ ┃ ┃ ┃ ┃ ┃ Debug kubernetes/k8s/new/deployment.yaml didn't match [kubernetes/docs/README.md] -> excluded
┃ ┃ ┃ ┃ ┃ ┃ ┃ Debug kubernetes/k8s/new-native/service-native.yaml didn't match [kubernetes/docs/README.md] -> excluded
┃ ┃ ┃ ┃ ┃ ┃ ┃ Debug kubernetes/k8s/new-native/deployment-native.yaml didn't match [kubernetes/docs/README.md] -> excluded
┃ ┃ ┃ ┃ ┃ ┃ ┃ Debug kubernetes/kn/new/service.yaml didn't match [kubernetes/docs/README.md] -> excluded
┃ ┃ ┃ ┃ ┃ ┃ ┃ Debug kubernetes/kn/new-native/service-native.yaml didn't match [kubernetes/docs/README.md] -> excluded
┃ ┃ ┃ ┃ ┃ ┃ ┃ Debug src/test/java/com/example/hello/SpringNativeFunctionKnativeApplicationTests.java didn't match [kubernetes/docs/README.md] -> excluded
┃ ┃ ┃ ┃ ┃ ┃ ┃ Debug src/main/resources/application.properties didn't match [kubernetes/docs/README.md] -> excluded
┃ ┃ ┃ ┃ ┃ ┃ ┗ Debug src/main/java/com/example/hello/SpringNativeFunctionKnativeApplication.java didn't match [kubernetes/docs/README.md] -> excluded
┃ ┃ ┃ ┃ ┃ ┃ ┏ README.merge.transformations[0].sources[0].<combo>.transformations[1] (Chain)
┃ ┃ ┃ ┃ ┃ ┃ ┃  Info Running Chain(RewritePath)
┃ ┃ ┃ ┃ ┃ ┃ ┃ ┏ README.merge.transformations[0].sources[0].<combo>.transformations[1].transformations[0] (RewritePath)
┃ ┃ ┃ ┃ ┃ ┗ ┗ ┗ Debug Path 'kubernetes/docs/README.md' matched '^(?<folder>.*/)?(?<filename>([^/]+?|)(?=(?<ext>\.[^/.]*)?)$)' with groups {ext=.md, folder=kubernetes/docs/, filename=README.md, g0=kubernetes/docs/README.md, g1=kubernetes/docs/, g2=README.md, g3=README.md, g4=.md} and was rewritten to 'README.md'
┃ ┃ ┃ ┃ ┃ ┏ README.merge.transformations[0].sources[1] (Combo)
┃ ┃ ┃ ┃ ┃ ┃  Info Condition (#deploymentType == 'kubernetes-resource-simple') evaluated to false
┃ ┃ ┃ ┃ ┃ ┗ null ()
┃ ┃ ┃ ┃ ┃ ┏ README.merge.transformations[0].sources[2] (Combo)
┃ ┃ ┃ ┃ ┃ ┃  Info Condition (#deploymentType == 'knative-resource-simple') evaluated to true
┃ ┃ ┃ ┃ ┃ ┃  Info Combo running as Chain(Include, Chain(chain))
┃ ┃ ┃ ┃ ┃ ┃ README.merge.transformations[0].sources[2].<combo> (Chain)
┃ ┃ ┃ ┃ ┃ ┃  Info Condition (#deploymentType == 'knative-resource-simple') evaluated to true
┃ ┃ ┃ ┃ ┃ ┃  Info Running Chain(Include, Chain)
┃ ┃ ┃ ┃ ┃ ┃ ┏ README.merge.transformations[0].sources[2].<combo>.transformations[0] (Include)
┃ ┃ ┃ ┃ ┃ ┃ ┃  Info Will include [kubernetes/docs/DEPLOY-KN.md]
┃ ┃ ┃ ┃ ┃ ┃ ┃ Debug compile.sh didn't match [kubernetes/docs/DEPLOY-KN.md] -> excluded
┃ ┃ ┃ ┃ ┃ ┃ ┃ Debug .mvn/wrapper/MavenWrapperDownloader.java didn't match [kubernetes/docs/DEPLOY-KN.md] -> excluded
┃ ┃ ┃ ┃ ┃ ┃ ┃ Debug .mvn/wrapper/maven-wrapper.jar didn't match [kubernetes/docs/DEPLOY-KN.md] -> excluded
┃ ┃ ┃ ┃ ┃ ┃ ┃ Debug .mvn/wrapper/maven-wrapper.properties didn't match [kubernetes/docs/DEPLOY-KN.md] -> excluded
┃ ┃ ┃ ┃ ┃ ┃ ┃ Debug mvnw didn't match [kubernetes/docs/DEPLOY-KN.md] -> excluded
┃ ┃ ┃ ┃ ┃ ┃ ┃ Debug pom.xml didn't match [kubernetes/docs/DEPLOY-KN.md] -> excluded
┃ ┃ ┃ ┃ ┃ ┃ ┃ Debug README.md didn't match [kubernetes/docs/DEPLOY-KN.md] -> excluded
┃ ┃ ┃ ┃ ┃ ┃ ┃ Debug LICENSE didn't match [kubernetes/docs/DEPLOY-KN.md] -> excluded
┃ ┃ ┃ ┃ ┃ ┃ ┃ Debug build.sh didn't match [kubernetes/docs/DEPLOY-KN.md] -> excluded
┃ ┃ ┃ ┃ ┃ ┃ ┃ Debug mvnw.cmd didn't match [kubernetes/docs/DEPLOY-KN.md] -> excluded
┃ ┃ ┃ ┃ ┃ ┃ ┃ Debug demo/demo.txt didn't match [kubernetes/docs/DEPLOY-KN.md] -> excluded
┃ ┃ ┃ ┃ ┃ ┃ ┃ Debug kubernetes/kpack/new/image.yaml didn't match [kubernetes/docs/DEPLOY-KN.md] -> excluded
┃ ┃ ┃ ┃ ┃ ┃ ┃ Debug kubernetes/kpack/new-native/image-native.yaml didn't match [kubernetes/docs/DEPLOY-KN.md] -> excluded
┃ ┃ ┃ ┃ ┃ ┃ ┃ Debug kubernetes/skaffold/skaffold.yaml didn't match [kubernetes/docs/DEPLOY-KN.md] -> excluded
┃ ┃ ┃ ┃ ┃ ┃ ┃ Debug kubernetes/docs/README.md didn't match [kubernetes/docs/DEPLOY-KN.md] -> excluded
┃ ┃ ┃ ┃ ┃ ┃ ┃ Debug kubernetes/docs/DEPLOY-K8s.md didn't match [kubernetes/docs/DEPLOY-KN.md] -> excluded
┃ ┃ ┃ ┃ ┃ ┃ ┃ Debug kubernetes/docs/KPACK.md didn't match [kubernetes/docs/DEPLOY-KN.md] -> excluded
┃ ┃ ┃ ┃ ┃ ┃ ┃ Debug kubernetes/docs/DEPLOY-KN.md matched [kubernetes/docs/DEPLOY-KN.md] -> included
┃ ┃ ┃ ┃ ┃ ┃ ┃ Debug kubernetes/k8s/new/service.yaml didn't match [kubernetes/docs/DEPLOY-KN.md] -> excluded
┃ ┃ ┃ ┃ ┃ ┃ ┃ Debug kubernetes/k8s/new/deployment.yaml didn't match [kubernetes/docs/DEPLOY-KN.md] -> excluded
┃ ┃ ┃ ┃ ┃ ┃ ┃ Debug kubernetes/k8s/new-native/service-native.yaml didn't match [kubernetes/docs/DEPLOY-KN.md] -> excluded
┃ ┃ ┃ ┃ ┃ ┃ ┃ Debug kubernetes/k8s/new-native/deployment-native.yaml didn't match [kubernetes/docs/DEPLOY-KN.md] -> excluded
┃ ┃ ┃ ┃ ┃ ┃ ┃ Debug kubernetes/kn/new/service.yaml didn't match [kubernetes/docs/DEPLOY-KN.md] -> excluded
┃ ┃ ┃ ┃ ┃ ┃ ┃ Debug kubernetes/kn/new-native/service-native.yaml didn't match [kubernetes/docs/DEPLOY-KN.md] -> excluded
┃ ┃ ┃ ┃ ┃ ┃ ┃ Debug src/test/java/com/example/hello/SpringNativeFunctionKnativeApplicationTests.java didn't match [kubernetes/docs/DEPLOY-KN.md] -> excluded
┃ ┃ ┃ ┃ ┃ ┃ ┃ Debug src/main/resources/application.properties didn't match [kubernetes/docs/DEPLOY-KN.md] -> excluded
┃ ┃ ┃ ┃ ┃ ┃ ┗ Debug src/main/java/com/example/hello/SpringNativeFunctionKnativeApplication.java didn't match [kubernetes/docs/DEPLOY-KN.md] -> excluded
┃ ┃ ┃ ┃ ┃ ┃ ┏ README.merge.transformations[0].sources[2].<combo>.transformations[1] (Chain)
┃ ┃ ┃ ┃ ┃ ┃ ┃  Info Running Chain(RewritePath)
┃ ┃ ┃ ┃ ┃ ┃ ┃ ┏ README.merge.transformations[0].sources[2].<combo>.transformations[1].transformations[0] (RewritePath)
┃ ┃ ┃ ┃ ┃ ┗ ┗ ┗ Debug Path 'kubernetes/docs/DEPLOY-KN.md' matched '^(?<folder>.*/)?(?<filename>([^/]+?|)(?=(?<ext>\.[^/.]*)?)$)' with groups {ext=.md, folder=kubernetes/docs/, filename=DEPLOY-KN.md, g0=kubernetes/docs/DEPLOY-KN.md, g1=kubernetes/docs/, g2=DEPLOY-KN.md, g3=DEPLOY-KN.md, g4=.md} and was rewritten to 'README.md'
┃ ┃ ┃ ┃ ┃ ┏ README.merge.transformations[0].sources[3] (Combo)
┃ ┃ ┃ ┃ ┃ ┃  Info Condition (#includeKpackImage) evaluated to true
┃ ┃ ┃ ┃ ┃ ┃  Info Combo running as Chain(Include, Chain(chain))
┃ ┃ ┃ ┃ ┃ ┃ README.merge.transformations[0].sources[3].<combo> (Chain)
┃ ┃ ┃ ┃ ┃ ┃  Info Condition (#includeKpackImage) evaluated to true
┃ ┃ ┃ ┃ ┃ ┃  Info Running Chain(Include, Chain)
┃ ┃ ┃ ┃ ┃ ┃ ┏ README.merge.transformations[0].sources[3].<combo>.transformations[0] (Include)
┃ ┃ ┃ ┃ ┃ ┃ ┃  Info Will include [kubernetes/docs/KPACK.md]
┃ ┃ ┃ ┃ ┃ ┃ ┃ Debug compile.sh didn't match [kubernetes/docs/KPACK.md] -> excluded
┃ ┃ ┃ ┃ ┃ ┃ ┃ Debug .mvn/wrapper/MavenWrapperDownloader.java didn't match [kubernetes/docs/KPACK.md] -> excluded
┃ ┃ ┃ ┃ ┃ ┃ ┃ Debug .mvn/wrapper/maven-wrapper.jar didn't match [kubernetes/docs/KPACK.md] -> excluded
┃ ┃ ┃ ┃ ┃ ┃ ┃ Debug .mvn/wrapper/maven-wrapper.properties didn't match [kubernetes/docs/KPACK.md] -> excluded
┃ ┃ ┃ ┃ ┃ ┃ ┃ Debug mvnw didn't match [kubernetes/docs/KPACK.md] -> excluded
┃ ┃ ┃ ┃ ┃ ┃ ┃ Debug pom.xml didn't match [kubernetes/docs/KPACK.md] -> excluded
┃ ┃ ┃ ┃ ┃ ┃ ┃ Debug README.md didn't match [kubernetes/docs/KPACK.md] -> excluded
┃ ┃ ┃ ┃ ┃ ┃ ┃ Debug LICENSE didn't match [kubernetes/docs/KPACK.md] -> excluded
┃ ┃ ┃ ┃ ┃ ┃ ┃ Debug build.sh didn't match [kubernetes/docs/KPACK.md] -> excluded
┃ ┃ ┃ ┃ ┃ ┃ ┃ Debug mvnw.cmd didn't match [kubernetes/docs/KPACK.md] -> excluded
┃ ┃ ┃ ┃ ┃ ┃ ┃ Debug demo/demo.txt didn't match [kubernetes/docs/KPACK.md] -> excluded
┃ ┃ ┃ ┃ ┃ ┃ ┃ Debug kubernetes/kpack/new/image.yaml didn't match [kubernetes/docs/KPACK.md] -> excluded
┃ ┃ ┃ ┃ ┃ ┃ ┃ Debug kubernetes/kpack/new-native/image-native.yaml didn't match [kubernetes/docs/KPACK.md] -> excluded
┃ ┃ ┃ ┃ ┃ ┃ ┃ Debug kubernetes/skaffold/skaffold.yaml didn't match [kubernetes/docs/KPACK.md] -> excluded
┃ ┃ ┃ ┃ ┃ ┃ ┃ Debug kubernetes/docs/README.md didn't match [kubernetes/docs/KPACK.md] -> excluded
┃ ┃ ┃ ┃ ┃ ┃ ┃ Debug kubernetes/docs/DEPLOY-K8s.md didn't match [kubernetes/docs/KPACK.md] -> excluded
┃ ┃ ┃ ┃ ┃ ┃ ┃ Debug kubernetes/docs/KPACK.md matched [kubernetes/docs/KPACK.md] -> included
┃ ┃ ┃ ┃ ┃ ┃ ┃ Debug kubernetes/docs/DEPLOY-KN.md didn't match [kubernetes/docs/KPACK.md] -> excluded
┃ ┃ ┃ ┃ ┃ ┃ ┃ Debug kubernetes/k8s/new/service.yaml didn't match [kubernetes/docs/KPACK.md] -> excluded
┃ ┃ ┃ ┃ ┃ ┃ ┃ Debug kubernetes/k8s/new/deployment.yaml didn't match [kubernetes/docs/KPACK.md] -> excluded
┃ ┃ ┃ ┃ ┃ ┃ ┃ Debug kubernetes/k8s/new-native/service-native.yaml didn't match [kubernetes/docs/KPACK.md] -> excluded
┃ ┃ ┃ ┃ ┃ ┃ ┃ Debug kubernetes/k8s/new-native/deployment-native.yaml didn't match [kubernetes/docs/KPACK.md] -> excluded
┃ ┃ ┃ ┃ ┃ ┃ ┃ Debug kubernetes/kn/new/service.yaml didn't match [kubernetes/docs/KPACK.md] -> excluded
┃ ┃ ┃ ┃ ┃ ┃ ┃ Debug kubernetes/kn/new-native/service-native.yaml didn't match [kubernetes/docs/KPACK.md] -> excluded
┃ ┃ ┃ ┃ ┃ ┃ ┃ Debug src/test/java/com/example/hello/SpringNativeFunctionKnativeApplicationTests.java didn't match [kubernetes/docs/KPACK.md] -> excluded
┃ ┃ ┃ ┃ ┃ ┃ ┃ Debug src/main/resources/application.properties didn't match [kubernetes/docs/KPACK.md] -> excluded
┃ ┃ ┃ ┃ ┃ ┃ ┗ Debug src/main/java/com/example/hello/SpringNativeFunctionKnativeApplication.java didn't match [kubernetes/docs/KPACK.md] -> excluded
┃ ┃ ┃ ┃ ┃ ┃ ┏ README.merge.transformations[0].sources[3].<combo>.transformations[1] (Chain)
┃ ┃ ┃ ┃ ┃ ┃ ┃  Info Running Chain(RewritePath)
┃ ┃ ┃ ┃ ┃ ┃ ┃ ┏ README.merge.transformations[0].sources[3].<combo>.transformations[1].transformations[0] (RewritePath)
┃ ┃ ┃ ┃ ┗ ┗ ┗ ┗ Debug Path 'kubernetes/docs/KPACK.md' matched '^(?<folder>.*/)?(?<filename>([^/]+?|)(?=(?<ext>\.[^/.]*)?)$)' with groups {ext=.md, folder=kubernetes/docs/, filename=KPACK.md, g0=kubernetes/docs/KPACK.md, g1=kubernetes/docs/, g2=KPACK.md, g3=KPACK.md, g4=.md} and was rewritten to 'README.md'
┃ ┃ ┃ ┃ ┏ README.merge.transformations[1] (UniquePath)
┃ ┃ ┗ ┗ ┗ Debug Multiple representations for path 'README.md', will concatenate them together
┃ ┃ ┏ engine.transformations[0].merge.transformations[1] (UniquePath)
┃ ┃ ┃ Debug Multiple representations for path 'kubernetes/kn/new-native/service-native.yaml', will use the one appearing last 
┃ ┃ ┃ Debug Multiple representations for path 'kubernetes/kn/new/service.yaml', will use the one appearing last 
┃ ┗ ┗ Debug Multiple representations for path 'pom.xml', will use the one appearing last 
┗ ╺ engine.transformations[1] (UniquePath)
```
