#!/usr/bin/env bash

kp builder create dekt4pets-builder -n dekt4pets-ns \
   --tag goharbor.io/dekt4pets/dekt4pets-builder \
   --order build-order.yaml \
   --stack base \
   --store default
