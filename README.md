# legendary-goggles
Work-in-progress GitHub App to enable logging pushes to a repository

## :construction:

"Work-in-progress" means this is still being created. See [issue #1](https://github.com/solvaholic/legendary-goggles/issues/1) for progress.

## Why?
To practice using [Azure] to create a [GitHub App].

## What?
Implement webhook receiver, database, and user interface in Azure. Maintain their configuratons as code in this repository. Automatically re-deploy the app when its configuration changes.

## How?
### Webhook receiver
Manually create an Azure Function App, Key Vault, and Secret following these guides:

- [_Monitor GitHub events by using a webhook with Azure Functions_](https://docs.microsoft.com/learn/modules/monitor-github-events-with-a-function-triggered-by-a-webhook/)
- [_Use Key Vault references for App Service and Azure Functions_](https://docs.microsoft.com/azure/app-service/app-service-key-vault-references)
- [_Access environment variables in code_](https://docs.microsoft.com/azure/azure-functions/functions-reference-node?tabs=v2#access-environment-variables-in-code)

### GitHub App
Manually create an App, following [_Creating a GitHub App_](https://docs.github.com/developers/apps/building-github-apps/creating-a-github-app).

### Log payload to database
:shrug:


### User interface
:shrug:


[Azure]: https://azure.microsoft.com
[GitHub App]: https://docs.github.com/developers/apps/getting-started-with-apps/about-apps
