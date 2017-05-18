@echo off

:: Existing resources.
set LOCATION=westeurope
set RG_NAME=pelleo-tensorflow-rg
set PUBLIC_ACCESS=Container

:: Resources to be created.  Run
::
::     az storage account list -g %RG_NAME%
::
:: to view existing storage accounts.
set STORAGE_ACCOUNT_NAME=pelleotensorflow
set CONTAINER_NAME=data

:: Create storage account.  
az storage account create ^
   -n %STORAGE_ACCOUNT_NAME% ^
   -g %RG_NAME% ^
   --sku Standard_LRS ^
   --kind Storage ^
   -l %LOCATION%

:: Set Az CLI environment variable AZURE_STORAGE_CONNECTION_STRING.
::for /f "tokens=2" %%i in ('az storage account show-connection-string -g %RG_NAME% -n %STORAGE_ACCOUNT_NAME%') do set AZURE_STORAGE_CONNECTION_STRING=%%i
for /f "tokens=2" %%i in ('az storage account show-connection-string -g pelleo-tensorflow-rg -n pelleotensorflow') do set AZURE_STORAGE_CONNECTION_STRING=%%i

:: Create container using connection strings.
az storage container create ^
   -n %CONTAINER_NAME% ^
   --public-access %PUBLIC_ACCESS%

:: Display containers of boot diagnostics account.
az storage container list
