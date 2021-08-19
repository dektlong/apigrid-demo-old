package com.example.hello;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;

import java.util.function.Function;

@SpringBootApplication
public class AdopterCheckFunction {

    @Value("${API_CALL:from-function}")
    String api-call;

    @Value("${TARGET:from-function}")
    String target;

    public static void main(String[] args) {
        SpringApplication.run(AdopterCheckFunction.class, args);
    }

    @Bean
    public Function<String, String> hello() {
        return (in) -> {
            return "\nRunning adoption history check..\n\nAPI: " + api-call + in + "\nResult: Adoption history is clean" + "\n\nSource: " + target;
        };
    }
}
