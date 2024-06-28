# An Un managed TopoLVM provision

## Run the tofu (Windows)

* In a powershell session, Execute:

```PowerShell
# ---
#  
$Env:TF_LOG = "debug"

# ---
# The below env. var. maybe useful to either 
# the tofu code or the tofu provider
# ---
$Env:SOME_ENV_VARIABLE = "itsvalue"

tofu init
tofu validate
tofu fmt

tofu plan -out="my.first.powershell.plan.tfplan"
tofu apply -auto-approve "my.first.powershell.plan.tfplan"

```

* Destroy it all:

```PowerShell

tofu plan -destroy -out="my.first.destroy.powershell.plan.tfplan"
tofu apply "my.first.destroy.powershell.plan.tfplan"
```

* destroy n respawn all one-liner:

```bash
tofu plan -destroy -out="my.first.destroy.powershell.plan.tfplan"; tofu apply "my.first.destroy.powershell.plan.tfplan"; tofu plan -out="my.first.powershell.plan.tfplan"; tofu apply -auto-approve "my.first.powershell.plan.tfplan"

```

* To re-run only the docker installation part:

```bash
# Just destroy the kubernetes provisioning null_resource
tofu destroy -target null_resource.provision_docker_registry

tofu destroy -target null_resource.provision_k8s_cluster


# and then tofu plan and apply again
tofu plan -out="my.first.powershell.plan.tfplan"
tofu apply -auto-approve "my.first.powershell.plan.tfplan"

```



## ANNEX: Install OpenTofu

* <https://opentofu.org/docs/intro/install/>

### On windows

* In a powershell session:

```bash
# Download the installer script:
Invoke-WebRequest -outfile "install-opentofu.ps1" -uri "https://get.opentofu.org/install-opentofu.ps1"

# Please inspect the downloaded script at this point.

# Run the installer:
& .\install-opentofu.ps1 -installMethod standalone

# Remove the installer:
Remove-Item install-opentofu.ps1
```

<!--
## Run the teraform (Windows)

* In a powershell session, Execute:

```PowerShell
# ---
#  
$Env:TF_LOG = "debug"
$Env:OCI_GO_SDK_DEBUG = "debug"
# export GOOGLE_APPLICATION_CREDENTIALS={{path}}

# ---
# The below env. var. maybe useful to either the terraform code or 
# ---
$Env:SOME_ENV_VARIABLE = "itsvalue"

terraform init
terraform validate
terraform fmt

terraform plan -out="my.first.powershell.plan.tfplan"
terraform apply -auto-approve "my.first.powershell.plan.tfplan"

```

* Destroy it all:

```PowerShell

terraform plan -destroy -out="my.first.destroy.powershell.plan.tfplan"
terraform apply "my.first.destroy.powershell.plan.tfplan"
```

* destroy n respawn all one-liner:

```bash
terraform plan -destroy -out="my.first.destroy.powershell.plan.tfplan"; terraform apply "my.first.destroy.powershell.plan.tfplan"; terraform plan -out="my.first.powershell.plan.tfplan"; terraform apply -auto-approve "my.first.powershell.plan.tfplan"

```

* To re-run only the docker installation part:

```bash
# Just destroy the kubernetes provisioning null_resource
terraform destroy -target null_resource.provision_docker_registry

terraform destroy -target null_resource.provision_k8s_cluster


# and then terraform plan and apply again
terraform plan -out="my.first.powershell.plan.tfplan"
terraform apply -auto-approve "my.first.powershell.plan.tfplan"

```

-->
