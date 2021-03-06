#!/usr/bin/env bash
# -v /etc/localtime:/etc/localtime:ro  容器时间共享宿主时间
# -v /etc/timezone:/etc/timezone:ro    容器时区共享宿主时区

. /etc/profile
directory=`pwd`
mvn clean package -Dmaven.test.skip=true

docker ps -a | grep 'zipkin'|awk '{print $1}'|xargs -r docker rm -f
docker run --name zipkin -d -p 9411:9411 openzipkin/zipkin

cd $directory/eureka-server
mvn docker:build
docker ps -a | grep 'server-container1'|awk '{print $1}'|xargs -r docker rm -f
docker ps -a | grep 'server-container2'|awk '{print $1}'|xargs -r docker rm -f
docker run --name server-container1 -v /root/dockerlog:/tmp -v /etc/localtime:/etc/localtime:ro -v /etc/timezone:/etc/timezone:ro -d -p 8761:8761 -e "SPRING_PROFILES_ACTIVE=server1" -h docker-host --add-host=docker-host:`docker network inspect  --format='{{range .IPAM.Config}}{{.Gateway}}{{end}}' bridge` springboot/eureka-server
docker run --name server-container2 -v /root/dockerlog:/tmp -v /etc/localtime:/etc/localtime:ro -v /etc/timezone:/etc/timezone:ro -d -p 8762:8762 -e "SPRING_PROFILES_ACTIVE=server2" -h docker-host --add-host=docker-host:`docker network inspect  --format='{{range .IPAM.Config}}{{.Gateway}}{{end}}' bridge` springboot/eureka-server

cd $directory/zuul
mvn docker:build
docker ps -a | grep 'zuul-container1'|awk '{print $1}'|xargs -r docker rm -f
docker ps -a | grep 'zuul-container2'|awk '{print $1}'|xargs -r docker rm -f
docker run --name zuul-container1 -v /root/dockerlog:/tmp -v /etc/localtime:/etc/localtime:ro -v /etc/timezone:/etc/timezone:ro -d -p 8070:8070 -e "SPRING_PROFILES_ACTIVE=aliyun-zuul1" -h docker-host --add-host=docker-host:`docker network inspect  --format='{{range .IPAM.Config}}{{.Gateway}}{{end}}' bridge` springboot/zuul
docker run --name zuul-container2 -v /root/dockerlog:/tmp -v /etc/localtime:/etc/localtime:ro -v /etc/timezone:/etc/timezone:ro -d -p 8071:8071 -e "SPRING_PROFILES_ACTIVE=aliyun-zuul2" -h docker-host --add-host=docker-host:`docker network inspect  --format='{{range .IPAM.Config}}{{.Gateway}}{{end}}' bridge` springboot/zuul

cd $directory/product-service
mvn docker:build
docker ps -a | grep 'service-container1'|awk '{print $1}'|xargs -r docker rm -f
docker ps -a | grep 'service-container2'|awk '{print $1}'|xargs -r docker rm -f
docker run --name service-container1 -v /root/dockerlog:/tmp -v /etc/localtime:/etc/localtime:ro -v /etc/timezone:/etc/timezone:ro -d -p 8090:8090 -e "SPRING_PROFILES_ACTIVE=aliyun-service1" -h docker-host --add-host=docker-host:`docker network inspect  --format='{{range .IPAM.Config}}{{.Gateway}}{{end}}' bridge` springboot/product-service
docker run --name service-container2 -v /root/dockerlog:/tmp -v /etc/localtime:/etc/localtime:ro -v /etc/timezone:/etc/timezone:ro -d -p 8091:8091 -e "SPRING_PROFILES_ACTIVE=aliyun-service2" -h docker-host --add-host=docker-host:`docker network inspect  --format='{{range .IPAM.Config}}{{.Gateway}}{{end}}' bridge` springboot/product-service

cd $directory/product-client
mvn docker:build
docker ps -a | grep 'client-container1'|awk '{print $1}'|xargs -r docker rm -f
docker ps -a | grep 'client-container2'|awk '{print $1}'|xargs -r docker rm -f
docker run --name client-container1 -v /root/dockerlog:/tmp -v /etc/localtime:/etc/localtime:ro -v /etc/timezone:/etc/timezone:ro -d -p 8081:8081 -e "SPRING_PROFILES_ACTIVE=aliyun-client1" -h docker-host --add-host=docker-host:`docker network inspect  --format='{{range .IPAM.Config}}{{.Gateway}}{{end}}' bridge` springboot/product-client
docker run --name client-container2 -v /root/dockerlog:/tmp -v /etc/localtime:/etc/localtime:ro -v /etc/timezone:/etc/timezone:ro -d -p 8082:8082 -e "SPRING_PROFILES_ACTIVE=aliyun-client2" -h docker-host --add-host=docker-host:`docker network inspect  --format='{{range .IPAM.Config}}{{.Gateway}}{{end}}' bridge` springboot/product-client

docker images | grep none | awk '{print $3}' | xargs -rt docker rmi -f