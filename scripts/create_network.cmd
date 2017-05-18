@echo off
:: Existing resources.
set LOCATION=westeurope
set RG_NAME=pelleo-tensorflow-rg

:: Resources to be created.
set VNET_NAME=tf-vnet
set ADDRESS_PREFIX=10.0.0.0/16
set SUBNET_NAME=tensorflow
set SUBNET_PREFIX=10.0.0.0/24
set NSG_NAME=tf-nsg
set SSH_RULE_NAME=ssh-rule 
set JUPYTER_RULE_NAME=jupyter-rule 

:: Create virtual network with one subnet.
az network vnet create ¨^
   -n %VNET_NAME% ^
   -g %RG_NAME% ^
   --address-prefixes %ADDRESS_PREFIX% ^
   -l %LOCATION% ^
   --subnet-name %SUBNET_NAME% ^
   --subnet-prefix %SUBNET_PREFIX%

:: Create network security group.
az network nsg create ^
   -g %RG_NAME% ^
   -n %NSG_NAME% ^
   -l %LOCATION% 

:: Allow SSH connections over the Internet. 
az network nsg rule create ^
   --resource-group %RG_NAME% ^
   --nsg-name %NSG_NAME% ^
   --name %SSH_RULE_NAME% ^
   --access Allow ^
   --protocol Tcp ^
   --direction Inbound ^
   --priority 110 ^
   --source-address-prefix Internet ^
   --source-port-range "*" ^
   --destination-address-prefix "*" ^
   --destination-port-range 22
   
:: Allow connections to Jupyter server on port 8000. 
az network nsg rule create ^
   --resource-group %RG_NAME% ^
   --nsg-name %NSG_NAME% ^
   --name %JUPYTER_RULE_NAME% ^
   --access Allow ^
   --protocol Tcp ^
   --direction Inbound ^
   --priority 120 ^
   --source-address-prefix Internet ^
   --source-port-range "*" ^
   --destination-address-prefix "*" ^
   --destination-port-range 8000

:: Bind the network security group to the tensorflow subnet.
az network vnet subnet update ^
   -g %RG_NAME% ^
   -n %SUBNET_NAME% ^
   --network-security-group %NSG_NAME% ^
   --vnet-name %VNET_NAME%
