package io.storebackend.api.actuator;

import org.springframework.boot.actuate.endpoint.annotation.Endpoint;
import org.springframework.boot.actuate.endpoint.annotation.ReadOperation;
import org.springframework.stereotype.Component;

import java.util.LinkedHashMap;
import java.util.Map;

@Component
@Endpoint(id="custom")
public class CustomActuatorEndpoint {
    @ReadOperation
    public CustomData customEndpoint() {
        Map<String, Object> details = new LinkedHashMap<>();
        details.put("CustomEndpoint", "Everything looks good at the custom endpoint");
        CustomData data = new CustomData();
        data.setData(details);
        return data;
    }
}
