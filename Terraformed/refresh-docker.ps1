#pull postgres
write-output "***********"
docker pull postgres:9.6.3
write-output "***********"
docker pull postgres:11.4

#tag the images
write-output "***********"
docker tag postgres:9.6.3 gcdocscloudtst.azurecr.io/otcs/postgres:9.6.3
write-output "***********"
docker tag postgres:11.4 gcdocscloudtst.azurecr.io/otcs/postgres:11.4

#import the OTCS images
$otcsImageExists = docker image inspect gcdocscloudtst.azurecr.io/otcs/otcs:16.2.10 2>&1

if ($otcsImageExists.length -eq 2) {
    #does not exit, create it
    docker import ..\otcs_16_2_10.tar.gz gcdocscloudtst.azurecr.io/otcs/otcs:16.2.10
}

#login to registry
az acr login --name gcdocscloudtst

#push postgress and OTCS images
docker push gcdocscloudtst.azurecr.io/otcs/postgres:9.6.3
docker push gcdocscloudtst.azurecr.io/otcs/postgres:11.4
docker push gcdocscloudtst.azurecr.io/otcs/otcs:16.2.10