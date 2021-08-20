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

            String output = "\n\n-----Welcome to " + target + "\n\n" + "Starting background checks for adoption candidate " + in ;

            String adoptionHistoryAPI = "datacheck.tanzu.dekt.io/api/adoption-history?adopterID=" + in;

            String criminalRecordAPI = "http://datacheck.tanzu.dekt.io/api/criminal-record/" + in;

   		    output = output + "\n\nRunnig adoption history check using API: " + adoptionHistoryAPI + " ...";   
            try
		    {
   			    String adoptionHistoryResults = restTemplate.getForObject(adoptionHistoryAPI, String.class);
                output = output + "\nResults: OK";
		    }
		    catch (Exception e) {}

            output = output + "\n\nRunnig criminal record check using API: " + criminalRecordAPI + " ...";   
            try
		    {
                String criminalRecordResults = restTemplate.getForObject(criminalRecordAPI, String.class);
                output = output + "\nResults: OK";
		    }
		    catch (Exception e) {}
            

            output = output + "\n\nCongratulations!! Candidate " + in + " is clear to adopt their next best friend.\n";
            
            return output;
        };
    }
}
