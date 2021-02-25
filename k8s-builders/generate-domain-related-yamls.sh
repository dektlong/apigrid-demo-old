#!/usr/bin/env bash

source secrets/config-values.env

cat > gateway/dekt4pets-gateway.yaml <<EOF
apiVersion: "tanzu.vmware.com/v1"
kind: SpringCloudGateway
metadata:
  name: dekt4pets-gateway
spec:
  api:
    serverUrl: https://dekt4pets.$DEMO_SUBDOMAIN.$DEMO_DOMAIN
    title: Dekt4Pets
    description: APIs for building the dekt4pets online store. 
    version: 0.1.0
  count: 2
  sso:
    secret: dekt4pets-sso
EOF

cat > hub/brownfield-apis/datacheck-gateway.yaml <<EOF
apiVersion: "tanzu.vmware.com/v1"
kind: SpringCloudGateway
metadata:
  name: datacheck-gateway
spec:
  count: 1
  api:
    serverUrl: https://datacheck.$DEMO_SUBDOMAIN.$DEMO_DOMAIN
    title: Background Check Services
    description: APIs to help with background checks on pet adopters
    version: 0.5.0
EOF

cat > hub/brownfield-apis/donations-gateway.yaml <<EOF
apiVersion: "tanzu.vmware.com/v1"
kind: SpringCloudGateway
metadata:
  name: donations-gateway
spec:
  count: 1
  api:
    serverUrl: https://donations.$DEMO_SUBDOMAIN.$DEMO_DOMAIN
    title: Donation Processing 
    description: APIs to help with processing donations 
    version: 0.5.0
EOF

cat > hub/brownfield-apis/suppliers-gateway.yaml <<EOF
apiVersion: "tanzu.vmware.com/v1"
kind: SpringCloudGateway
metadata:
  name: suppliers-gateway
spec:
  count: 1
  api:
    serverUrl: https://suppliers.$DEMO_SUBDOMAIN.$DEMO_DOMAIN
    title: Suppliers Payments
    description: APIs to help with issuing payments to suppliers
    version: 0.5.0
EOF

cat > sbo/fortune-ingress.yaml <<EOF
apiVersion: networking.k8s.io/v1beta1
kind: Ingress
metadata:
  name: fortune-ingress
  annotations:
    kubernetes.io/ingress.class: nginx
spec:
  rules:
    - host: fortune.$DEMO_SUBDOMAIN.$DEMO_DOMAIN
      http:
        paths:
          - path: "/"
            backend:
              serviceName: fortune-service
              servicePort: 8080
EOF

cat > sbo/sbo-ingress.yaml <<EOF
apiVersion: networking.k8s.io/v1beta1
kind: Ingress
metadata:
  name: sbo-ingress
  annotations:
    kubernetes.io/ingress.class: nginx
spec:
  rules:
    - host: sbo.$DEMO_SUBDOMAIN.$DEMO_DOMAIN
      http:
        paths:
          - path: "/"
            backend:
              serviceName: spring-boot-observer-server
              servicePort: 5112
EOF

cat > tss/tss-ingress.yaml <<EOF 
apiVersion: networking.k8s.io/v1beta1
kind: Ingress
metadata:
  name: tss-ingress
  annotations:
    kubernetes.io/ingress.class: nginx
spec:
  rules:
    - host: tss.$DEMO_SUBDOMAIN.$DEMO_DOMAIN
      http:
        paths:
          - path: "/"
            backend:
              serviceName: tss-server
              servicePort: 8080
EOF