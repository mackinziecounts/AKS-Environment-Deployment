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

A successful deployment of these resources requires several things:
1. Template deployments must be enabled in your AZ AD Tenant.
2. You must have proper permissions to deploy the resources.
3. You must have the correct Azure PowerShell modules installed
4. You must have Bicep installed. 

Required Setup:
1. Download the PowerShell script and Bicep files to your local system
2. Edit the PS script with your own custom resource names
3. Edit the PS script with the file location of each Bicep file. 'TemplateURI' parameter may be used instead of Template file,
  however this will require additional editorial work to deploy. 
