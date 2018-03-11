#!/bin/bash

docker run -it --env-file .env --net=host  zotoio/gtm-worker /bin/bash
