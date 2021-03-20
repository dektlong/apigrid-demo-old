
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
- GitOps for APIs - e.g. pipeline driven configuration of routes per lifecycle stage       

## Collaborative micro-APIs 
- Deploy backend service and expose its internal APIs through a dev-friendly 'app' Gateway, including simple to use SSO
- Frontend developers discover, test and reuse backend APIs via an auto-populated Hub
- Backend team add functionality leveraging 'brownfield APIs' from off-platform services 
- Publish app and configure live traffic via the gateway

## COMPLETE BEFORE STARTING !!

- Create a folder named ```secrets``` in the dekt4pets parent directory

- Create ```dekt4pets-jwk.txt``` and ```dekt4pets-sso.txt``` credential files and place them in the ```secrets``` directory
  - see example in ```https://github.com/spring-cloud-services-samples/animal-rescue/blob/main/k8s/deploy_to_k8s.md```

- Copy ```config-values-UPDATE_ME``` to ```secrets``` directory and renamed it to ```config-values.env```

- Set all variables in ```config-values.env```
  - Note: all yaml files that are updated in runtime will be copied to ```.config``` sub-directory in their respective directories during the init-demo phase

- The ingress setup is based on GoDaddy DNS, if you are using a different one, please modify ```k8s-builders/install-ingress-controller.sh``` 

## Installing the demo

- ```./init-demo.sh [aks | tkg]```

## Suggested demo flow

### The starting experience
- Access TSS on ```tss.<SUB_DOMAIN>.<DOMAIN>```
- Admin view: Show available Starters and Generators
- Admin view: Create a new backend-api-for-online-stores with online-store as the tag
  - see example of a generator source repo here: ```https://github.com/dektlong/generator-boot-api-k8s```
  - see example of an accelerator source repo here: ```https://github.com/dektlong/store-backend-api```
- Developer view: Click on online-store tag and show both frontend and backend Starters
- Developer view: Select the new ```backend-api-for-online-stores``` Starter and provide your own name (e.g. dekt4pets-backend)
- Generate and open the zip in your local IDE
  - Show immediate local build with ```mvn clean spring-boot:build-image```
  - Show the pre-generated API configs

### The path-to-prod
- ```./run-pipeline.sh info``` 
- ```./run-pipeline.sh deploy-backend```
- Show how build service detects git-repo changes and auto re-build backend-image (if required)
- Show how the ```dekt4pets-gateway``` micro-gateway starts quickly as just a component of your app
- Access API Hub on ```localhost:8080/apis```
  - Show the dekt4Pets API group auto-populated with the API spec you defined
  - now the frontend team can easily discover and test the backend APIs and reuse
  - Show the other API groups ('brownfield APIs')
- ```./run-pipeline.sh deploy-frontend```
- Access Spring Boot Observer at ```http://sbo.<SUB_DOMAIN>.<DOMAIN>/apps``` to show actuator information on the backend application 
- Show the new frontend APIs that where auto-populated to the hub
- ```./run-pipeline.sh open-store```
  - External traffic can only routed via the micro-gateway
  - Frontend and backend microservices still cannot be accessed directly) 
  - Access the application on 
  ```
  https://dekt4pets.<SUB_DOMAIN>.<DOMAIN>
  ```
  - login and show SSO functionality 
- Demo Tanzu Serverless
  - ```./run-pipeline.sh deploy-knative-app```

### Changes in production
- now the backend team will leverage the 'brownfield' APIs to add background check functionality on potential adopters
- access the 'datacheck' API group and test adoption-history and background-check APIs
- explain that now our backend team can know exactly how to use a verified working version of both APIs (no tickets to off platform teams)
- In ```backend/routes/dekt4pets-backend-routes.yaml``` add
```
    - predicates:
        - Path=/api/check-adopter
        - Method=GET
      ssoEnabled: true
      tokenRelay: true          
```
- In ```backend/src/main/.../AnimalController.java``` add
```
  @GetMapping("/check-adopter")
	public String checkAdopter(Principal adopter) {

    	String adopterId = adopter.getName();
    
		  //check for valid adoption history
		 	//	e.g. curl -X GET "https://datacheck.apps.dekt.io/adoption-history/*" -H "accept: */*"
			LOGGER.info("adopterId " + adopterId + " has succefully completed adoption history check");

    	// check for clear criminal-record
	  	//	e.g. curl -X GET "https://datacheck.apps.dekt.io/criminal-record/*" -H "accept: */*"
		  LOGGER.info("adopterId " + adopterId + " has succefully completed criminal record check");

  		String displayResults = "<h1>Congratulations,</h1>" + 
								"<h2>You are cleared to adopt your next best friend.</h2>" +
								"<p>token:"+adopterId+"</p>";
		
	  	return displayResults;
  }
```
- ```./run-pipeline.sh patch-backend "add check-adopter api"```
- show how build-service is invoking a new image build based on the git-commit-id
- run the new check-adopter api 
```
dekt4pets.<SUB_DOMAIN>.<DOMAIN>/api/check-adopter
```
- you should see the 'Congratulations...' message with the same token you received following login

## Cleanup

- ```./init-demo.sh cleanup```

# Enjoy!
