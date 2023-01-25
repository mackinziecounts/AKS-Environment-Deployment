#Pseudo Root and Management Group Function
function Deploy-BicepMngGrp {
    [CmdletBinding()]
    param (
       [Parameter(Mandatory, ValueFromPipeline)] 
       [string]$Location,
       
        [Parameter(Mandatory, ValueFromPipeline)]
        [string]$Name,

        [Parameter(Mandatory, ValueFromPipeline)]
        [string]$TemplateFile,

        [Parameter(Mandatory, ValueFromPipeline)]
        [string]$pseudoRootMGName
    )

    process {
        if (Get-AzManagementGroup -GroupId $pseudoRootMGName -ErrorAction SilentlyContinue) {
            Write-Host "The Management Group [$($pseudoRootMGName)] has already been created."
        } else {
            New-AzTenantDeployment -Location $Location -Name $Name `
            -TemplateFile $TemplateFile -pseudoRootMGName $pseudoRootMGName
        }
    }
}
#Set Variables for Management Group Deployment#
$tenantdeployparams = @{
    Location = 'WestUS'
    Name = 'pseudoRootMGDeploy'
    TemplateFile = ''
    pseudoRootMGName = ''
}
#Deploy Management Groups#
Deploy-BicepMngGrp @tenantdeployparams
#VALIDATED

#Billing Scope function
function Get-BillingScope {
    [CmdletBinding()]
    $azbillingacc = Get-AzBillingAccount
$billingprofilename = Get-AzBillingProfile -BillingAccountName $azbillingacc.Name
$billinginvoicename = Get-AzInvoiceSection -BillingAccountName $azbillingacc.Name `
-BillingProfileName $billingprofilename.Name
$azbillingp1 = "/providers/Microsoft.Billing/billingAccounts/"
$azprofilep1 = "/billingProfiles/"
$azinvoicep1 = "/invoiceSections/"
$azcompletebillingscope = $azbillingp1+$azbillingacc.Name+$azprofilep1+$billingprofilename.Name+$azinvoicep1+$billinginvoicename.Name
$azcompletebillingscope
}

#Subscription Function
function Deploy-BicepSub {
    [CmdletBinding()]
    param (
       [Parameter(Mandatory, ValueFromPipeline)] 
       [string]$Location,

        [Parameter(Mandatory, ValueFromPipeline)]
        [string]$Name,

        [Parameter(Mandatory, ValueFromPipeline)]
        [string]$subscriptionName,
       
        [Parameter(Mandatory, ValueFromPipeline)]
        [string]$billingScope,

        [Parameter(Mandatory, ValueFromPipeline)]
        [string]$TemplateFile,

        [Parameter(Mandatory, ValueFromPipeline)]
        [ValidateSet('Production','Dev/Test')]
        [string]$workloadParam,

        [Parameter()]
        [string]$ManagementGroupId
    )

    process {
        if (Get-AzSubscription -SubscriptionName $subscriptionName -ErrorAction SilentlyContinue) {
            Write-Host "The Subscription [$($subscriptionName)] has already been created." 
        } else {
            New-AzManagementGroupDeployment -Location $Location -Name $Name `
            -ManagementGroupId $ManagementGroupId -TemplateFile $TemplateFile `
             -billingScope $billingScope -SubscriptionName $subscriptionName -workloadParam $pseudoRootMGName
             $customSubId = Get-AzSubscription -SubscriptionName $childIdAndSub
             New-AzManagementGroupSubscription -GroupName $childId -SubscriptionId $customSubId.Id
        }
    }
}
#Set Variables for Subscription Deployment#
$azcompletebillingscope = Get-BillingScope
$getRootAndMngdeploy = Get-AzTenantDeployment -Name $tenantdeployparams.Name
$childId = $getRootAndMngdeploy.Outputs.foundationMGIdOut.Value | Select-Object -Index 0
$sub = "Sub"
$deploy = "Deploy"
$childIdAndDeploy = $childId+$deploy
$childIdAndSub = $childId+$sub
$subscriptionDeployParams = @{
    Location = 'WestUS'
    Name = $childIdAndDeploy
    ManagementGroupId = $childId
    TemplateFile = ''
    billingScope = $azcompletebillingscope
    subscriptionName = $childIdAndSub
    workloadParam = 'Production'
}
#Deploy Subscription
Deploy-BicepSub @subscriptionDeployParams

#Resource Group Deploy Function
function Deploy-BicepRG {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [String]$Location,

        [Parameter(Mandatory, ValueFromPipeline)]
        [String]$Name,

        [Parameter(Mandatory, ValueFromPipeline)]
        [String]$TemplateFile,

        [Parameter(Mandatory, ValueFromPipeline)]
        [String]$rgName,

        [Parameter(Mandatory, ValueFromPipeline)]
        [String]$rgLocation,

        [Parameter(ValueFromPipeline)]
        [String]$expectedRGName
    )
    begin {
        $expectedRGName = $rgName+$rgLocation
    }
    process {
        if (Get-AzResourceGroup -ResourceGroupName $expectedRGName -ErrorAction SilentlyContinue) {
            Write-Host "The ResourceGroup [$($expectedRGName)] has already been created."
        } else {
            New-AzDeployment -Location $Location -Name $Name `
            -TemplateFile $TemplateFile -rgName $rgName -rgLocation $rgLocation
        }
    }
}

#Set Variables for Resource Group
Set-AzContext -SubscriptionName $childIdAndSub
$resourceGroupDeploymentParams = @{
    Location = ''
    TemplateFile = ''
    rgLocation = ''
}
$resourceGroupNameParams = @{
    rgName = 'aks','storageaks','aksvault','aksacr'
}
#Deploy Resource Groups
$resourceGroupNameParams.rgName | ForEach-Object {
    $rgDeploymentName = $PSItem+$deploy
    Deploy-BicepRG @resourceGroupDeploymentParams -Name $rgDeploymentName -rgName $PSItem 
}

#Azure Container Registry Function
function Deploy-BicepACR {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string]$ResourceGroupName,
        
        [Parameter(Mandatory, ValueFromPipeline)]
        [string]$TemplateFile,

        [Parameter(Mandatory, ValueFromPipeline)]
        [string]$checkACRName
    )
    process { 
        if (Get-AzContainerRegistry -Name $checkACRName -ResourceGroupName $ResourceGroupName -ErrorAction SilentlyContinue) {
                Write-Host "The Container Registry [$($checkACRName)] has already been created."
            } else {
                New-AzResourceGroupDeployment -ResourceGroupName $ResourceGroupName -TemplateFile $TemplateFile -Mode Incremental
            }
    }
}

#Set Variables for Azure Container Registry 
$acrDeployParams = @{
    ResourceGroupName = $resourceGroupNameParams.rgName[3]+$resourceGroupDeploymentParams.Location
    TemplateFile = ''
    checkACRName = $resourceGroupNameParams.rgName[3]+$resourceGroupDeploymentParams.Location+'bmprojacr'
}

#Deploy Azure Container Registry
Deploy-BicepACR @acrDeployParams -ErrorAction Stop

#Storage Account Function
function Deploy-BicepStor {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [String]$ResourceGroupName,

        [Parameter(Mandatory, ValueFromPipeline)]
        [String]$TemplateFile,

        [Parameter(Mandatory, ValueFromPipeline)]
        [String]$StorAccName
    )
    process {
        if (Get-AzStorageAccount -Name $StorAccName.ToLower() -ResourceGroupName $ResourceGroupName -ErrorAction SilentlyContinue) {
                Write-Host "The Storage Account [$($StorAccName)] has already been created."    
            } else {
                New-AzResourceGroupDeployment -Name 'storagedeployment' -ResourceGroupName $ResourceGroupName -TemplateFile $TemplateFile `
                -StorAccName $StorAccName -Mode Incremental
            }
    }
}
#Set Variables for Storage Account
$storageAccountParams = @{
    ResourceGroupName = $resourceGroupNameParams.rgName[1]+$resourceGroupDeploymentParams.Location
    TemplateFile = ''
    StorAccName = $resourceGroupNameParams.rgName[1]+$resourceGroupDeploymentParams.Location+'bmproj'
}

#Deploy Storage Account
Deploy-BicepStor @storageAccountParams -ErrorAction Stop

#Set Up Necessary Variable
$keyVaultTenantId = (Get-AzContext).Tenant.Id
$keyVaultAdmin = Get-AzADUser -DisplayName ''
#Create New Service Principal
$sp = New-AzADServicePrincipal -DisplayName 'githubPrincipal' 

#Put Service Principal Secret Information into a Hashtable
$spHashTable = @{
    appId = $sp.AppId
    displayName = $sp.DisplayName
    password = $sp.PasswordCredentials.SecretText 
    tenant = $keyVaultTenantId
}

#Key Vault Function
function Deploy-BicepKeyVault {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [String]$ResourceGroupName,

        [Parameter(Mandatory, ValueFromPipeline)]
        [String]$TemplateFile,

        [Parameter(Mandatory, ValueFromPipeline)]
        [String]$KeyVaultName,

        [Parameter(Mandatory, ValueFromPipeline)]
        [String]$keyVaultTenantId,

        [Parameter(Mandatory, ValueFromPipeline)]
        [String]$keyVaultObjectId
    )
    process {
        if (Get-AzKeyVault -Name $KeyVaultName -ResourceGroupName $ResourceGroupName -ErrorAction SilentlyContinue) {
                Write-Host "The Key Vault [$($KeyVaultName)] has already been created."
            } else {
                New-AzResourceGroupDeployment -ResourceGroupName $ResourceGroupName -TemplateFile $TemplateFile `
                -KeyVaultName $KeyVaultName -keyVaultTenantId $keyVaultTenantId -keyVaultObjectId $keyVaultObjectId -Mode Incremental
            }
    }
}

#Set Variables for Key Vault
$keyVaultParams = @{
    ResourceGroupName = $resourceGroupNameParams.rgName[2]+$resourceGroupDeploymentParams.Location
    TemplateFile = ''
    KeyVaultName = ''
    keyVaultTenantId = $keyVaultTenantId
    keyVaultObjectId = $keyVaultAdmin.Id
}

#Deploy Key Vault
Deploy-BicepKeyVault @keyVaultParams

#Send Service Principal Secret Information to Key Vault
$tenantdeployparams.pseudoRootMGName
$MngGroupPrefix = '/providers/Microsoft.Management/managementGroups/'
$childMngGroup = 'Child1'
$completeMngGroupScope = $MngGroupPrefix+$childMngGroup+$tenantdeployparams.pseudoRootMGName
$spJSON = $spHashTable | ConvertTo-Json -Depth 4 | ConvertTo-SecureString -AsPlainText
Set-AzKeyVaultSecret -VaultName $keyVaultParams.KeyVaultName -Name $sp.DisplayName -SecretValue $spJSON
New-AzRoleAssignment -ApplicationId $sp.AppId -RoleDefinitionName 'Contributor' -Scope $completeMngGroupScope

#SSH Key Function
function Deploy-BicepSSH {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [String]$ResourceGroupName,

        [Parameter(Mandatory, ValueFromPipeline)]
        [String]$TemplateFile,

        [Parameter(Mandatory, ValueFromPipeline)]
        [String]$sshKeyName
    )
    process {
        if (Get-AzSshKey -Name $sshKeyName -ErrorAction SilentlyContinue) {
                Write-Host "The SSH Key [$($sshKeyName)] has already been created."
            } else {
                New-AzResourceGroupDeployment -ResourceGroupName $ResourceGroupName -TemplateFile $TemplateFile `
                -sshKeyName $sshKeyName -Mode Incremental
            }
    }
}

#SSH Key Params
$bicepSshParams = @{
    ResourceGroupName = $resourceGroupNameParams.rgName[0]
    TemplateFile = ''
    sshKeyName = ''
}

#SSH Key Deploy
Deploy-BicepSSH @bicepSshParams

#Kubernetes Service Function
function Deploy-BicepAKS {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [String]$ResourceGroupName,

        [Parameter(Mandatory, ValueFromPipeline)]
        [String]$TemplateFile,

        [Parameter(Mandatory, ValueFromPipeline)]
        [String]$clusterName,

        [Parameter(Mandatory, ValueFromPipeline)]
        [String]$linuxAdminUsername,

        [Parameter(Mandatory, ValueFromPipeline)]
        [String]$sshRSAPublickey
    )
    process {
        if (Get-AzAksCluster -Name $clusterName -ErrorAction SilentlyContinue) {
                Write-Host "The AKS Cluster [$($clusterName)] has already been created."
            } else {
                New-AzResourceGroupDeployment -ResourceGroupName $ResourceGroupName -TemplateFile $TemplateFile `
                -linuxAdminUsername $linuxAdminUsername -sshRSAPublickey $sshRSAPublickey -Mode Incremental
            }
    }
}

#Set Variables for AKS
$aksParams = @{
    ResourceGroupName = $resourceGroupNameParams.rgName[0]
    TemplateFile = ''
    clusterName= ''
    linuxAdminUsername = ''
    sshRSAPublickey = ''
}


#Deploy AKS
Deploy-BicepAKS @aksParams


#Azure AD User Function - Dev
function Deploy-azAdUser {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [String]$pwFileLocation,

        [Parameter(Mandatory, ValueFromPipeline)]
        [String]$userDisplayName,

        [Parameter(Mandatory, ValueFromPipeline)]
        [String]$userPrincipalName
    )
    process {
        if (Get-AzADUser -DisplayName $userDisplayName -ErrorAction SilentlyContinue) {
                Write-Host "The AZ AD User [$($userDisplayName)] has already been created."
            } else {
                $userSecPW = Get-Content $pwFileLocation | ConvertTo-SecureString -String $PSItem -AsPlainText
New-AzADUser -DisplayName $userDisplayName -UserPrincipalName $userPrincipalName -Password $userSecPW -ForceChangePasswordNextLogin
            }
    }
}

#Azure AD User Params
$azAdUserParams = @{
    pwFileLocation = ''
    userDisplayName = ''
    userPrincipalName = ''
}

#Deploy Azure AD User
Deploy-azAdUser @azAdUserParams

#AZ AD User Role Assignment Function
function Deploy-azAdUserRoleAssignment {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [String]$TemplateFile,

        [Parameter(Mandatory, ValueFromPipeline)]
        [String]$userRole,

        [Parameter(Mandatory, ValueFromPipeline)]
        [String]$userPrincipalName,

        [Parameter(Mandatory, ValueFromPipeline)]
        [String]$Location,

        [Parameter(Mandatory, ValueFromPipeline)]
        [String]$Name,

        [Parameter(Mandatory, ValueFromPipeline)]
        [String]$principalId
    )
    process {
        if ((Get-AzRoleAssignment -SignInName $userPrincipalName `
        | Where-Object -Property 'RoleDefinitionName' -eq $userRole) -ErrorAction SilentlyContinue) {
                Write-Host "The AZ AD User Role Assignment [$($userRole)] has already been assigned to [$($userPrincipalName)]."
            } else {
                New-AzTenantDeployment -Location $Location -Name $Name `
            -TemplateFile $TemplateFile -userRole $userRole -userPrincipalName $userPrincipalName -principalId $principalId
            }
    }
}


$userPrincipal = Get-AzADUser -DisplayName $azAdUserParams.userDisplayName
#AZ AD User Role Assignment Params
$azAdUserRoleAssignmentParams = @{
    TemplateFile = ''
    userRole = 'Contributor'
    userPrincipalName = ''
    Location = ''
    Name = ''
    principalId = $userPrincipal.Id
}

#Deploy AZ AD User Role Assignment
Deploy-azAdUserRoleAssignment @azAdUserRoleAssignmentParams
