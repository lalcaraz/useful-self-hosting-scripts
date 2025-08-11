#!/bin/bash
mkdir portainer; docker run -d -p 9443:9443 --name portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v ./portainer:/data portainer/portainer-ce:lts
