
This repo contains artifacts to run a demo illustrating the vision of Tanzu Micro API Fabric on any k8s substrate.

1. Curated Start                                                   3. Collaborative APIs 
    Architects create patterns                                      Internal APIs
    Devs start quickly via curated ‘starters’                           Deploy backend service and expose its internal APIs 
    API-first design boiler-plate code                                  A dev-friendly 'app' Gateway
                                                                        API endpoints are auto populated to the Hub 
2. Consistent Builds                                                    Frontend devs reuses backend APIs via a Hub
    Local dev to pipeline-initiated builds                          External APIs
    follows standard Boot tools (no docker files required               Publish app and configure live traffic via the gateway
    Prod-optimized images, air-gaped artifacts, lifecyle support        Secret management and including simple to use SSO



######### COMPLETE BEFORE STARTING !! #########

1. Update with your own values

2. Create a 'secrets' folder

3. Create secrets/dekt4pets-jwk.txt & secrets/dekt4pets-sso.txt credential files
    (see example in https://github.com/spring-cloud-services-samples/animal-rescue/blob/main/k8s/deploy_to_k8s.md)

4. Move config-values.txt to secrets/config-values.txt

5. Set all variables in config-values.txt

5. update image locations in deployment yamls

Enjoy your demo!
