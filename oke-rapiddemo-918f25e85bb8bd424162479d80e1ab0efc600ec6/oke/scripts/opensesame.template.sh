#!/bin/bash

ssh -L 9000:localhost:9000 -L 3000:localhost:3000 -L 5601:localhost:5601 -L 16686:localhost:16686 -L 8088:localhost:8088 -L 4040:localhost:4040 opc@${nat_ip}