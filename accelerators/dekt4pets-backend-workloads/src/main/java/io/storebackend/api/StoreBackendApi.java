package io.storebackend.api;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.EnableAspectJAutoProxy;

@SpringBootApplication
//@EnableAspectJAutoProxy(proxyTargetClass=true)
public class StoreBackendApi {

    public static void main(String[] args) {
        SpringApplication.run(StoreBackendApi.class, args);
    }
}
