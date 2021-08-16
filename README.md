
# Demo of Tanzu API Grid ♥️😺 ♥️🐶

This repo contains artifacts to run a demo illustrating the vision and capabilities of Tanzu API Grid.

It is designed to run on any k8s.

- [Demo slides](https://docs.google.com/presentation/d/105sp3K633nnTPWn_PGxrLRb2X0atNmNN4Wlu10FgQ00/edit#slide=id.gdbf1731422_0_3)
- [Demo recording](https://bit.ly/api-grid)

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

- Create a folder named ```secrets``` in the APIGridDemo root directory

- Create ```dekt4pets-jwk.txt``` and ```dekt4pets-sso.txt``` credential files and place them in the ```secrets``` directory
  - see example in ```https://github.com/spring-cloud-services-samples/animal-rescue/blob/main/k8s/deploy_to_k8s.md```

- Copy ```config-values-UPDATE_ME``` to ```secrets``` directory and renamed it to ```config-values.env```

- Set all variables in ```config-values.env```
  - Note: all yaml files that are updated in runtime will be copied to ```config``` sub-directory in their respective directories during the demo-builder phase

- The ingress setup is based on GoDaddy DNS, if you are using a different one, please modify the ```update-dns``` function in ```demo-builder.sh``` 

- This demo was tested well on AKS with 7 nodes of type ```Standard_DS3_v2``` (4 vCPU, 14GB memory, 28GB temp disk). If you need to change that configuration, please modify the parameters in ```k8s-builders/build-aks-cluster.sh``` function

## API Grid

### Installation
- If you update / first install the core Tanzu services , run ```./demo-builder.sh upgrade core-images```
- run ```./demo-builder.sh init-aks apigrid```
- This script installs the following products
  - Spring Cloud Gateway
  - App Accelerator
  - Api portal
  - Spring Boot Observer
  - Build Service
- This script setup the following examples
  - Fortune sidecar for Spring Boot Observer
  - App Accelerators generators and accelerators
  - Brownfield APIs examples for API portal
  - Det4Pets backend TBS image
  - Det4Pets frontend TBS image

### The starting experience
- Access app accelerator developer instance  on ```acc.<SUB_DOMAIN>.<DOMAIN>```
- Development curated start 
  - Select ```onlinestore-dev``` tag
  - Select the ```Backend API for online-stores``` accelerator 
  - Select the options according to the project
  - Generate the zip file and import the folder to your favorite IDE
  - Show immediate local build with ```mvn clean spring-boot:build-image```
  - Show boiler-plate generated code configs
  - Show boiler-plate generated API configs
- DevOps curated start 
  - Select ```onlinestore-devops``` tag
  - Select the ```API Driven Microservices workflow``` accelerator 
  - Select the options according to your DevOps policies
  - Generate the zip file and import the folder to your favorite IDE
  - Show the supply chain created via ```./tanzu-apps.sh supplychain dekt4pets```
  - Show boiler-plate generated Build configs
  - Show boiler-plate generated API configs

### The path-to-prod
- ```./tanzu-apps.sh workload create backend```
- Show how build service detects git-repo changes and auto re-build backend-image (if required)
- Show how the ```dekt4pets-gateway``` micro-gateway starts quickly as just a component of your app
- Access API Hub on ```api-portal.<SUB_DOMAIN>.<DOMAIN>```
  - Show the dekt4Pets API group auto-populated with the API spec you defined
  - now the frontend team can easily discover and test the backend APIs and reuse
  - Show the other API groups ('brownfield APIs')
- ```./tanzu-apps.sh workload create frontend```
- Access Spring Boot Observer at ```http://sbo.<SUB_DOMAIN>.<DOMAIN>/apps``` to show actuator information on the backend application 
- Show the new frontend APIs that where auto-populated to the API portal
- This phase will also add an ingress rule to the gateway, now you can show:
  - External traffic can only routed via the micro-gateway
  - Frontend and backend microservices still cannot be accessed directly) 
  - Access the application on 
  ```
  https://dekt4pets.<SUB_DOMAIN>.<DOMAIN>
  ```
  - login and show SSO functionality 

### Changes in production
- now the backend team will leverage the 'brownfield' APIs to add background check functionality on potential adopters
- access the 'datacheck' API group and test adoption-history and background-check APIs
- explain that now our backend team can know exactly how to use a verified working version of both APIs (no tickets to off platform teams)
- In ```workloads/dekt4pets/backend/routes/dekt4pets-backend-routes.yaml``` add
```
    - predicates:
        - Path=/api/check-adopter
        - Method=GET
      ssoEnabled: true
      tokenRelay: true
      tags:
        - pets      
```
- In ```workloads/dekt4pets/backend/src/main/.../AnimalController.java``` add
```
	@GetMapping("/check-adopter")
	public String checkAdopter(Principal adopter) {
    
		String adoptionHistoryCheckURI = //TODO add adoption-history request URL;

   		RestTemplate restTemplate = new RestTemplate();
		
		try
		{
   			String result = restTemplate.getForObject(adoptionHistoryCheckURI, String.class);
		}
		catch (Exception e) {}

  		return "<h1>Congratulations,</h1>" + 
				"<h2>You are cleared to adopt your next best friend.</h2>" +
				"<p>token:"+adopter.getName()+"</p>";
	}

```
- ```./tanzu-apps.sh workload update backend "```
- show how build-service is invoking a new image build based on the git-commit-id
- run the new check-adopter api 
```
dekt4pets.<SUB_DOMAIN>.<DOMAIN>/api/check-adopter
```
- you should see the 'Congratulations...' message with the same token you received following login

## Cloud Native Runtime

### Installation
- run ```./demo-builder.sh init-aks cnr```
- This script installs the following products
  - App Accelerator
  - Cloud Native Runtime
### Service creation
- ```./tanzu-apps.sh workload create fortune```

### Service revision
- ```./tanzu-apps.sh workload update fortune```

## Cleanup

- ```./demo-builder.sh cleanup [ aks | tkg ]```

# Enjoy!
