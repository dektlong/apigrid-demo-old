package com.dekt4pets;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;

import java.util.function.Function;

@SpringBootApplication
public class CheckAdopterFunction {

    @Value("${TARGET:from-function}")
    String target;

    public static void main(String[] args) {
        SpringApplication.run(SpringNativeFunctionKnativeApplication.class, args);
    }

    @Bean
    public Function<String, String> hello() {
        return (in) -> {
            return "dekt: " + in + ", Source: " + target;
        };
    }
}
