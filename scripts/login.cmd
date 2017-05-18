:: AZURE CLI 2.0 LOGIN

:: The following method describes a simple method for logging in interactively
:: form the Windows command prompt via Azure CLI 2.0.  For installation instructions, 
:: please refer to https://docs.microsoft.com/en-us/cli/azure/install-azure-cli.

:: *  From your *client* machine, log on to the Azure web portal https://portal.azure.com
:: *  Open a command prompt with admin privileges and type and navigate to your
::    working directort of choice.
az login

:: You will be presented with a random code looking something like C5TCZGW28.
:: Open a new tab in your web browser and navigate to https://aka.ms/devicelogin.  Enter the 
:: code and follow the instructions. 

:: Verify that you are running the proper version of the Azure CLI (it should 
:: say something like azure-cli (2.0.6)):
az --version

:: Next, list your account(s)  
az account list

:: If needed, change to the appropriate default by running a command similar to
az account set -s <Name or ID of subscription>
