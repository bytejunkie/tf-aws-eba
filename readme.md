
# tf-aws-containers

This repo contains two modules

- eba
This module contains code to build an Elastic Beanstalk Application, including the environment needed to support it. 

##Re-using these templates

You will need to create an IAM user for terraform deployments. 
Then create the following secrets for your deployment pipeline. 
* AWS_ACCESS_KEY
* AWS_ACCESS_KEY_ID

I'm using Github actions to deploy, which you can tell from the notation in the workflow file, of ${{ secrets.aws_access_key }}

##Naming Convention

If you look in defaults.tf, this repo uses a pair of variables to setup a naming convention. 

- var.project
- var.environment

This is to help reuse the code and create a lifecycle for bigger product teams.

```HCL
locals {
    resource_prefix = format("%s-%s", var.project, var.environment)
}
```

local.resource_prefix is then referenced wherever the name is required to follow the convention.

in main.tf the template name adopts the prefix.

```HCL
  name                = format("%s-%s", local.resource_prefix, "ebe-template-01")
111

###contact
for help and suggestions, either create an issue on the github repo or contact matt@bytejunkie.dev

