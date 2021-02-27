#!/bin/bash

export APIHUB_SOURCE_URLS="http://scg-openapi.{REPLACED_IN_RUNTIME}/openapi"

java -jar api-hub-server-0.0.1-SNAPSHOT.jar #for now you will need to obtain the jar locally and modify this script
