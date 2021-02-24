
# dekt4Pets ♥️😺 ♥️🐶

This repo contains artifacts to run a demo illustrating the vision of Tanzu Micro API Fabric on any k8s substrate.

## Curated Start                                                   
- Architects create patterns                                      
- Devs start quickly via curated ‘starters’                           
- API-first design boiler-plate code                                  

## Consistent Builds                                                    
- Local dev to pipeline-initiated builds                          
- Follows standard Boot tools (no docker files required               
- Prod-optimized images, air-gaped artifacts, lifecyle support        

## Collaborative micro-APIs 
- Deploy backend service and expose its internal APIs through a dev-friendly 'app' Gateway, including simple to use SSO
- Frontend devs discover, test and reuse backend APIs via an auto-populated Hub
- Backend team add 'backgroud-checks' leveraging 'brownfield APIs' from off-platform services 
- Publish app and configure live traffic via the gateway

## COMPLETE BEFORE STARTING !!

1. Update with your own values

2. Create a 'secrets' folder

3. Create secrets/dekt4pets-jwk.txt & secrets/dekt4pets-sso.txt credential files
    (see example in https://github.com/spring-cloud-services-samples/animal-rescue/blob/main/k8s/deploy_to_k8s.md)

4. Rename and move config-values-UPDATE_ME.txt to secrets/config-values.txt

5. Set all variables in config-values.txt

6. update image locations in deployment yamls

## Installing the demo

- ./init-demo [aks | tkg]

## Suggested demo flow

- The starting experience
    - Access TSS on tss.apps.<DEMO_DOMAIN>
    - Admin view: Show available Starters and Generators
    - Admin view: Create a new backend-api-for-online-stores with online-store as the tag
        (see example of Starter source repo here: https://github.com/dektlong/store-backend-api)
    - Developer view: Click on online-store tag and show both frontend and backend Starters
    - Developer view: Select the new backend-api-for-online-stores Starter and provide your own name (e.g. dekt4pets-backend)
    - Generate and open the zip in your local IDE
    - Show immediate local build with mvn clean spring-boot:build-image
    - Show the pre-generated API configs
- The path-to-prod
    - ./run-pipeline.sh info 
    - ./run-pipeline.sh deploy-backend
    - Access API Hub on localhost:8080/apis
    - Show the Anim


========== check-adopter api =========
    - predicates:
        - Path=/api/check-adopter
        - Method=GET
    ssoEnabled: true
    tokenRelay: true

    @GetMapping("/check-adopter")
	public String checkAdopter(Principal adopter) {

    	String adopterId = adopter.getName();
    
	    //verify adoption history via datacheck api

    	//run background check  via datacheck api

		String displayResults = "<B>Congratulations !!!</B><BR><BR>You are cleared to adopt your next best friend<BR><BR><I>token:"+adopterId+"</I>";
		
	    return displayResults;
	}
# Enjoy!
