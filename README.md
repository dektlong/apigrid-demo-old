
# dekt4Pets ♥️😺 ♥️🐶

This repo contains artifacts to run a demo illustrating the vision of Tanzu Micro API Fabric.

It is designed to run on any k8s substrate.

## Curated Start                                                   
- Architects create patterns                                      
- Devs start quickly via curated ‘starters’                           
- API-first design boiler-plate code                                  

## Consistent Builds                                                    
- Local dev to pipeline-initiated builds                          
- Follows standard Boot tools (no docker files required)               
- Prod-optimized images, air-gapped artifacts, lifecycle support        

## Collaborative micro-APIs 
- Deploy backend service and expose its internal APIs through a dev-friendly 'app' Gateway, including simple to use SSO
- Frontend devs discover, test and reuse backend APIs via an auto-populated Hub
- Backend team add 'backgroud-checks' leveraging 'brownfield APIs' from off-platform services 
- Publish app and configure live traffic via the gateway

## COMPLETE BEFORE STARTING !!

- Create a 'secrets' folder

- Create secrets/dekt4pets-jwk.txt & secrets/dekt4pets-sso.txt credential files
    (see example in https://github.com/spring-cloud-services-samples/animal-rescue/blob/main/k8s/deploy_to_k8s.md)

- Rename and move config-values-UPDATE_ME to secrets/config-values.env

- Set all variables in config-values.env

- (temp) modify hub/run-local-api-hub-server.sh with the location of your api-hub-server-###.jar
 
- The ingress setup is based on GoDaddy DNS, if you are using a different one, please modify k8sbuilders/install-ingress-controller.sh 

- Update the image locations in all k8s Deployments yamls with your Image Registy info (feel free to contribue a dynamic setup here)

- Spring Boot Observer (very early, use at your own risk!) 

  - build and push images to your repo 
  - Update /sbo yamls 
  - The observer UI should be available at http://sbo.<DEMO_APP_SUBDOMAIN>.<DEMO_DOMAIN>/apps


## Installing the demo

- ./init-demo.sh [aks | tkg]

## Suggested demo flow

### The starting experience
- Access TSS on tss.apps.<DEMO_DOMAIN>
- Admin view: Show available Starters and Generators
- Admin view: Create a new backend-api-for-online-stores with online-store as the tag
   (see example of Starter source repo here: https://github.com/dektlong/store-backend-api)
- Developer view: Click on online-store tag and show both frontend and backend Starters
- Developer view: Select the new backend-api-for-online-stores Starter and provide your own name (e.g. dekt4pets-backend)
- Generate and open the zip in your local IDE
  - Show immediate local build with mvn clean spring-boot:build-image
  - Show the pre-generated API configs

### The path-to-prod
- ./run-pipeline.sh info 
- ./run-pipeline.sh deploy-backend
- Access API Hub on localhost:8080/apis
  - Show the dekt4Pets API group auto-populated with the API spec you defined
    (now the frontend team can easily discover and test the backend APIs and reuse)
  - Show the 'brownfield' API groups
- ./run-pipeline.sh deploy-frontend
- Show the new frontend APIs that where auto-populated to the hub
- ./run-pipeline.sh open-store
  - Explain now, via the ingress rule to the micro-gateway, is the only time external traffic can be enabled
  - Access the application on dekt4pets.<DEMO_APP_SUBDOMAIN>.<DEMO_DOMAIN>

### Changes in production
- 'now the backend team will leverage the 'brownfield' APIs to add background check functionality on potential adopters
- In backend/routes/dekt4pets-backend-routes.yaml add
```
- predicates:
    - Path=/api/check-adopter
    - Method=GET
  ssoEnabled: true
  tokenRelay: true        
```
- In backend/src/main/.../AnimalController.java add
```
@GetMapping("/check-adopter")
public String checkAdopter(Principal adopter) {

    	String adopterId = adopter.getName();
    
	//verify adoption history via datacheck api

    	//run background check  via datacheck api

	String displayResults = "<B>Congratulations !!!</B><BR><BR>You are cleared to adopt your next best friend<BR><BR><I>token:"+adopterId+"</I>";
		
	return displayResults;
}
```
- ./run-pipeline.sh patch-backend "add check-adopter api"
- show how build-service is invoking a new image build based on the git-commit-id
- run the new check-adopter api 
     dekt4pets.<DEMO_APP_SUBDOMAIN>.<DEMO_DOMAIN>/api/check-adopter
- you should see the 'Congratulations...' message with the same token you received following login

## Cleanup

- ./init-demo.sh cleanup

# Enjoy!
