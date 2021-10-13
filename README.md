# legendary-goggles
Work-in-progress GitHub App to enable logging pushes to a repository

## :construction:

"Work-in-progress" means this is still being created. See [issue #1](https://github.com/solvaholic/legendary-goggles/issues/1) for progress.

**_Why?_**  
To practice using [Azure] to create a [GitHub App].

**_What?_**  
Implement webhook receiver, database, and user interface in Azure. Maintain their configuratons as code in this repository. Automatically re-deploy the app when its configuration changes.

**_How?_**  
Continue reading below for step-by-step notes and instructions.

Here are the references I used, in case they can help you learn more about the tools and processes involved:

- [_Monitor GitHub events by using a webhook with Azure Functions_](https://docs.microsoft.com/learn/modules/monitor-github-events-with-a-function-triggered-by-a-webhook/)
- [_Use Key Vault references for App Service and Azure Functions_](https://docs.microsoft.com/azure/app-service/app-service-key-vault-references)
- [_Access environment variables in code_](https://docs.microsoft.com/azure/azure-functions/functions-reference-node?tabs=v2#access-environment-variables-in-code)
- [_Deploy Azure Functions with Terraform_](https://www.maxivanov.io/deploy-azure-functions-with-terraform/)
- [_Publish Azure Functions code with Terraform_](https://www.maxivanov.io/publish-azure-functions-code-with-terraform/)
- [_Continuous delivery by using GitHub Action_](https://docs.microsoft.com/en-us/azure/azure-functions/functions-how-to-github-actions?tabs=dotnet)

## Set up an Azure resource group
Let Terraform build all these out for you:

> _Resource group, storage account, app insights, service plan, function app, and key vault._

TODO: Add remote state for Terraform, and automate setup on GitHub

### 1\. Login to Azure CLI

```bash
az login
az account list     # Note the SUBSCRIPTION_ID you'd like to use
az account set --subscription="SUBSCRIPTION_ID"
```

### 2\. Initialize and apply Terraform config

```bash
terraform init
terraform apply
```

## Webhook receiver
TODO: Automate secret rotation on GitHub (with rollback!)

### 3\. Create the webhook secret
- Create secret in Azure
- Set secret in Azure
- Set secret in GitHub

### 4\. Deploy the function code
- (Get credentials and) Push the function
- Test webhook delivery gets HTTP 200

- Create deployment package
- Publish package to function app

## GitHub App
Manually create an App, following [_Creating a GitHub App_].

TODO: Manage the GitHub App config as code

### 5\. Create the app on GitHub.com
- Create the app
- Install and test the app

## Log payload to database
TODO: How to secure the PII in webhook payloads?
TODO: Teach Az function to log payloads

## User interface
TODO: Decide how to implement interactive site, then do it

[Azure]: https://azure.microsoft.com
[GitHub App]: https://docs.github.com/developers/apps/getting-started-with-apps/about-apps
[_Creating a GitHub App_]: https://docs.github.com/developers/apps/building-github-apps/creating-a-github-app