# GitHub Actions Runner (Community)

## Summary

*Use your codespace compute to also run a self hosted actions runner. Includes common-debian tools, Terraform, Azure CLI, git-lfs, github-cli, powershell and related extensions and dependencies.*

| Metadata | Value |  
|----------|-------|
| *Contributors* | [Marcel Lupo](https://github.com/Pwd9000-ML) |
| *Categories* | Community, GitHub, Other |
| *Definition type* | Dockerfile |
| *Supported architecture(s)* | x86-64, arm64/aarch64 for `bullseye` based images |
| *Works in Codespaces* | Yes |
| *Container host OS support* | Linux, macOS, Windows |
| *Container OS* | Debian |
| *Languages, platforms* | Azure, HCL, PowerShell |

![image.png](https://raw.githubusercontent.com/Pwd9000-ML/blog-devto/main/posts/2022-GitHub-Codespaces-runner/assets/diag01.png)

## Using this definition

This definition will install common-debian tools, `.devcontainer/library-scripts/common-debian.sh` for more details.
It will also install additional tools based on `.devcontainer/devcontainer.json`:

```json
"features": {
   "terraform": "latest",
   "azure-cli": "latest",
   "git-lfs": "latest",
   "github-cli": "latest",
   "powershell": "latest"
}
```

There are a few options you can pick from including what version of GitHub Actions runner to use by updating `RUNNER_VERSION` in `.devcontainer/devcontainer.json`:

```json
// Amend GitHub runner version with 'RUNNER_VERSION'. https://github.com/actions/runner/releases.
"build": {
    "args": {
        "UPGRADE_PACKAGES": "true",
        "RUNNER_VERSION": "2.295.0"
    }
```

## What scripts are included

1. **[common-debian.sh](https://github.com/microsoft/vscode-dev-containers/blob/main/containers/github-actions-runner/.devcontainer/library-scripts/common-debian.sh)**: This script will install additional **debian** based tooling onto the **dev container**.

2. **[start.sh](https://github.com/microsoft/vscode-dev-containers/blob/main/containers/github-actions-runner/.devcontainer/library-scripts/start.sh)**:

```bash
#start.sh
#!/bin/bash

GH_OWNER=$GH_OWNER
GH_REPOSITORY=$GH_REPOSITORY
GH_TOKEN=$GH_TOKEN

HOSTNAME=$(hostname)
RUNNER_SUFFIX="runner"
RUNNER_NAME="${HOSTNAME}-${RUNNER_SUFFIX}"
USER_NAME_LABEL=$(git config --get user.name)
REPO_NAME_LABEL="$GH_REPOSITORY"

REG_TOKEN=$(curl -sX POST -H "Accept: application/vnd.github.v3+json" -H "Authorization: token ${GH_TOKEN}" https://api.github.com/repos/${GH_OWNER}/${GH_REPOSITORY}/actions/runners/registration-token | jq .token --raw-output)

/home/vscode/actions-runner/config.sh --unattended --url https://github.com/${GH_OWNER}/${GH_REPOSITORY} --token ${REG_TOKEN} --name ${RUNNER_NAME}  --labels ${USER_NAME_LABEL},${REPO_NAME_LABEL}
/home/vscode/actions-runner/run.sh
```

The second script will start up with the **Codespace/Dev container** and bootstraps the **GitHub runner** when the Codespace starts. Notice that we need to provide the script with some parameters:

```bash
GH_OWNER=$GH_OWNER
GH_REPOSITORY=$GH_REPOSITORY
GH_TOKEN=$GH_TOKEN
```

These parameters (environment variables) are used to configure and **register** the self hosted github runner against the correct repository.

We need to provide the GitHub account/org name via the `'GH_OWNER'` environment variable, repository name via `GH_REPOSITORY` and a PAT token with `GH_TOKEN`.

You can store sensitive information, such as tokens, that you want to access in your codespaces via environment variables. Let's configure these parameters as encrypted [secrets for codespaces](https://docs.github.com/en/codespaces/managing-your-codespaces/managing-encrypted-secrets-for-your-codespaces).

1. Navigate to the repository `'Settings'` page and select `'Secrets -> Codespaces'`, click on `'New repository secret'`. ![image.png](https://raw.githubusercontent.com/Pwd9000-ML/blog-devto/main/posts/2022-GitHub-Codespaces-runner/assets/sec01.png)

2. Create each **Codespace secret** with the values for your environment. ![image.png](https://raw.githubusercontent.com/Pwd9000-ML/blog-devto/main/posts/2022-GitHub-Codespaces-runner/assets/sec02.png)

**NOTE:** When the **self hosted runner** is started up and registered, it will also be labeled with the **'user name'** and **'repository name'**, from the following lines. (These labels can be amended if necessary):

```bash
USER_NAME_LABEL=$(git config --get user.name)
REPO_NAME_LABEL="$GH_REPOSITORY"
```

## Note on Personal Access Token (PAT)

See [creating a personal access token](https://docs.github.com/en/enterprise-server@3.4/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token) on how to create a GitHub PAT token. PAT tokens are only displayed once and are sensitive, so ensure they are kept safe.

The minimum permission scopes required on the PAT token to register a self hosted runner are: `"repo"`, `"read:org"`:

![image.png](https://raw.githubusercontent.com/Pwd9000-ML/blog-devto/main/posts/2022-GitHub-Codespaces-runner/assets/PAT.png)

**Tip:** I recommend only using short lived PAT tokens and generating new tokens whenever new agent runner registrations are required.  

**IMPORTANT:** Do note that making use of **runner labels** is very important when **triggring/running actions** against runners or runner groups provisioned on a **Codespace**. Hence each runner is labeled with the **user name** and **repo name**.

![image.png](https://raw.githubusercontent.com/Pwd9000-ML/blog-devto/main/posts/2022-GitHub-Codespaces-runner/assets/label01.png)

## Example

A self-hosted runner automatically receives certain labels when it is added to GitHub Actions. These are used to indicate its operating system and hardware platform:

- `self-hosted`: Default label applied to all self-hosted runners.
- `linux`, `windows`, or `macOS`: Applied depending on operating system.
- `x64`, `ARM`, or `ARM64`: Applied depending on hardware architecture.

You can use your workflow's YAML to send jobs to a combination of these labels. In this example, a self-hosted runner that matches all three labels will be eligible to run the job:

```yml
runs-on: [self-hosted, linux, ARM64]
```

- `self-hosted` - Run this job on a self-hosted runner.
- `linux` - Only use a Linux-based runner.
- `ARM64` - Only use a runner based on ARM64 hardware.

The default labels are fixed and cannot be changed or removed. Consider using custom labels if you need more control over job routing.

As you can see from this [example workflow](https://github.com/Pwd9000-ML/GitHub-Codespaces-Lab/blob/master/.github/workflows/testCodespaceRunner.yml) in my repository, I am routing my **GitHub Action** jobs, specifically to my own **self hosted runner** on my **Codespace** using my **user name** and **repo name** labels with `'runs-on'`:

```yml
name: Runner on Codespace test

on:
  workflow_dispatch:

jobs:
  testRunner:
    runs-on: [self-hosted, Pwd9000, GitHub-Codespaces-Lab]
    steps:
      - uses: actions/checkout@v3.0.2
      - name: Display Terraform Version
        run: terraform --version
      - name: Display Azure-CLI Version
        run: az --version
```

### Adding the definition to a project or codespace

1. If this is your first time using a development container, please see getting started information on [setting up](https://aka.ms/vscode-remote/containers/getting-started) Remote-Containers or [creating a codespace](https://aka.ms/ghcs-open-codespace) using GitHub Codespaces.

2. Start VS Code and open your project folder or connect to a codespace.

3. Press <kbd>F1</kbd> select and **Add Development Container Configuration Files...** command for **Remote-Containers** or **Codespaces**. 

   > **Note:** If needed, you can drag-and-drop the `.devcontainer` folder from this sub-folder in a locally cloned copy of this repository into the VS Code file explorer instead of using the command.

4. Select this definition. You may also need to select **Show All Definitions...** for it to appear.

5. Finally, press <kbd>F1</kbd> and run **Remote-Containers: Reopen Folder in Container** or **Codespaces: Rebuild Container** to start using the definition.

## License

Copyright (c) Microsoft Corporation. All rights reserved.

Licensed under the MIT License. See [LICENSE](https://github.com/Microsoft/vscode-dev-containers/blob/main/LICENSE).
