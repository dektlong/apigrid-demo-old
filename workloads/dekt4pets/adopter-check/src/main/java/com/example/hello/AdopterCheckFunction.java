package com.example.hello;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;
import org.springframework.web.client.RestTemplate;

import java.util.function.Function;

@SpringBootApplication
public class AdopterCheckFunction {

    @Value("${TARGET:from-function}")
    String target;

    public static void main(String[] args) {
        SpringApplication.run(AdopterCheckFunction.class, args);
    }

    @Bean
    public Function<String, String> hello() {
        return (in) -> {
            
            RestTemplate restTemplate = new RestTemplate();

            String output = "\n\n*** Welcome to " + target + " ***";

            String adoptionHistoryAPI = "datacheck.tanzu.dekt.io/api/adoption-history?adopterID=" + in;

            String criminalRecordAPI = "datacheck.tanzu.dekt.io/api/criminal-record/" + in;

   		    output = output + "\n\n==> Running adoption history check using API: " + adoptionHistoryAPI + " ...";   
            try
		    {
   			    String adoptionHistoryResults = restTemplate.getForObject(adoptionHistoryAPI, String.class);
		    }
		    catch (Exception e) {/*check failure*/}

            output = output + "\n\n==> Running criminal record check using API: " + criminalRecordAPI + " ...";   
            try
		    {
                String criminalRecordResults = restTemplate.getForObject(criminalRecordAPI, String.class);
		    }
		    catch (Exception e) {/*check failure*/}
            

            output = output + "\n\n\nCongratulations!! Candidate " + in + " is clear to adopt their next best friend.\n";
            
            return output;
        };
    }
}
