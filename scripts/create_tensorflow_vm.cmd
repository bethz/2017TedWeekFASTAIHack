@echo off
:: Existing resources.

:: Make sure to use a DNS compatible version of
:: the location, e.g., westus - not West US.
set LOCATION=westeurope
set RG_NAME=pelleo-tensorflow-rg

:: Network resources to be created.
set DNS_NAME=pelleo-tf
set PIP_NAME=tf-pip
set NIC_NAME=tf-nic
set VNET_NAME=tf-vnet
set ADDRESS_PREFIX=10.0.0.0/16
set SUBNET_NAME=tensorflow
set SUBNET_PREFIX=10.0.0.0/24
set NSG_NAME=tf-nsg
set SSH_RULE_NAME=ssh-rule 
set JUPYTER_RULE_NAME=jupyter-rule 

:: VM resources to be created
set VM_NAME=tf-vm
set VM_SIZE=Standard_NV6
set AUTHENTICATION_TYPE=password
set ADMIN_USER_NAME=azadmin
set ADMIN_PWD=Contoso!1000
set OS_DISK_NAME=tf-osdisk
set STORAGE_SKU=Standard_LRS

:: Specify publisher of GPU image.
set VM_IMAGE_PUBLISHER=microsoft-ads

:: List available GPU image offers. Run command
::
::     az vm image list-offers -l %LOCATION% -p %VM_IMAGE_PUBLISHER%
::
:: to get a list of offers.
set VM_IMAGE_OFFER=linux-data-science-vm-ubuntu

:: List available GPU image SKUs.  Run command
::
::     az vm image list-skus -l %LOCATION% -p %VM_IMAGE_PUBLISHER% --offer %VM_IMAGE_OFFER%
::
:: to get a list of SKUs.
set VM_IMAGE_SKU=linuxdsvmubuntu

:: Create resource group
az group create ^
   -n %RG_NAME% ^
   -l %LOCATION%

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


:: VM creation begin 
   
:: Create public IP address.  Run command
::
::     az network public-ip list -g %RG_NAME%
::
:: to view existing IP addresses.
az network public-ip create ^
   -g %RG_NAME% ^
   -n %PIP_NAME% ^
   --dns-name %DNS_NAME% ^
   -l %LOCATION% ^
   --allocation-method Dynamic

:: Create network interface.  Run command
::
::     az network nic list -g %RG_NAME%
::
:: to view existing NICs
az network nic create ^
   -g %RG_NAME% ^
   -n %NIC_NAME% ^
   --subnet %SUBNET_NAME% ^
   --vnet-name %VNET_NAME% ^
   --network-security-group %NSG_NAME% ^
   --public-ip-address %PIP_NAME% ^
   -l %LOCATION%

:: Create VM.
az vm create ^
   -g %RG_NAME% ^
   -l %LOCATION% ^
   -n %VM_NAME% ^
   --nics %NIC_NAME% ^
   --os-disk-name %OS_DISK_NAME% ^
   --image %VM_IMAGE_PUBLISHER%:%VM_IMAGE_OFFER%:%VM_IMAGE_SKU%:latest ^
   --authentication-type %AUTHENTICATION_TYPE% ^
   --admin-username %ADMIN_USER_NAME% ^
   --admin-password %ADMIN_PWD% ^
   --size %VM_SIZE% ^
   --storage-sku %STORAGE_SKU%^   
   
:: Show status of recently created VM.
azure vm list -g %RG_NAME%

:: Log on to recently created VM.
putty -pw %ADMIN_PWD% %ADMIN_USER_NAME%@%DNS_NAME%.%LOCATION%.cloudapp.azure.com

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: COPY BASH FILES
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:: Copy bash files to $HOME on new VM.
pscp -pw %ADMIN_PWD% .\tf_config.sh %ADMIN_USER_NAME%@%DNS_NAME%.%LOCATION%.cloudapp.azure.com:/home/%ADMIN_USER_NAME%

:: Make shell scripts executable.
plink -pw %ADMIN_PWD% %ADMIN_USER_NAME%@%DNS_NAME%.%LOCATION%.cloudapp.azure.com chmod 755 *.sh

:: Launch configuration scripts. The -ssh -t switches are required 
:: to enable a psuedo terminal as sudo requires tty access.
plink -pw %ADMIN_PWD% -ssh -t %ADMIN_USER_NAME%@%DNS_NAME%.%LOCATION%.cloudapp.azure.com ./tf_config.sh %ADMIN_PWD%
