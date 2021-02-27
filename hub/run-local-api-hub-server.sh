#!/bin/bash

export APIHUB_SOURCE_URLS="http://scg-openapi.{REPLACED_IN_RUNTIME}/openapi"

java -jar {RUNTIME_PATH_TO_API_HUB_JAR}
