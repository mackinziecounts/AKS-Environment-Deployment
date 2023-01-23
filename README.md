# AKS-Environment-Deployment

*this Repo is in progress!*

This Repo will demonstrate and contain the necessary resources to deploy a a complete Azure Kubernetes Service environment, using PowerShell and Bicep, containing the following Azure resources:
1. Parent Management Group
2. Child Managemnet Group
3. Subscription
4. Azure AD User
5. Azure Service Principal
6. Azure AD Role Assignment 
7. SSH Key
8. Storage Account
9. Key Vault
10. Container Registry
11. Kubernetes Service

The methodology of the PowerShell deployment script is as follows: 
1. Define a custom PS Function that will do the work of deploying the resource
2. Define the necessary parameters and variables for the previous function
3. Call upon the function, to deploy the resource, and supply necessary variables

The defined methodoly does make the deployment script a little longer than needed, however, it makes it easier to understand what is being done.  
