package com.example.hello;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;

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
            String intro = "Welcome to " + target + "\n\n" + "Starting background checks for adoption candidate with id:" + id + "\n\n";
            
            String adoptionHistory = "1. Running adoption history check...\nAPI: " + "datacheck.tanzu.dekt.io/api/adoption-history?adopterID=" + in + "\nResult: Adoption history is good\n\n"; 

            String backgroundCheck = "2. Searching for criminal record...\nAPI: " + "http://datacheck.tanzu.dekt.io/api/criminal-record/" + in + "\nResult: Criminal record is clean\n\n"; 
            
            String summary = "Congratulations!. Candidate " + id + " is clear to adopt their next best friend.\n"
            
            return intro+adoptionHistory+backgroundCheck+summary;
        };
    }
}
