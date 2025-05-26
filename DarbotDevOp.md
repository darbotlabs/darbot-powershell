# Authenticating to Azure DevOps Private NuGet Feeds for Darbot PowerShell

This guide provides clear instructions for authenticating to private Azure DevOps NuGet feeds 
for the Darbot PowerShell project, both via the Azure DevOps UI and the command line.

---

## 1. Prerequisites

- An Azure account (Microsoft or Work/School account)
- PowerShell 7+, .NET SDK, and (optionally) `nuget.exe` installed
- Visual Studio Code (recommended)

---

## 2. Accessing Azure DevOps (For First-Time Users)

### If you're in the Azure Portal

1. Azure Portal (portal.azure.com) and Azure DevOps (dev.azure.com) are separate services, though they use the same login.
2. Open a new browser tab and go directly to [dev.azure.com](https://dev.azure.com/).
3. Sign in with the same Microsoft account you use for Azure Portal.

### First-time Azure DevOps Access

1. If this is your first time using Azure DevOps, you may need to:
   - Create a new organization (if you don't belong to one)
   - OR request access to an existing organization from your administrator

### Accessing Your Organization and Project

1. Once in Azure DevOps (dev.azure.com), navigate to the vdfguard organization.
   - Direct URL: https://dev.azure.com/vdfguard/
2. Within the organization, select the "Darbot PowerShell" project.
   - Direct URL: https://dev.azure.com/vdfguard/Darbot%20PowerShell
3. You can connect your local git repository to this project using:

```bash
git remote add origin https://vdfguard@dev.azure.com/vdfguard/Darbot%20PowerShell/_git/Darbot%20PowerShell
git push -u origin --all
```

---

## 3. Find Your Feed URL

1. In the Azure DevOps project, look at the left sidebar.
2. Click **Artifacts**.
3. Select your feed (e.g., `DarbotPowerShellFeed`).
4. Click **Connect to feed** (top right).
5. Copy the NuGet v3 feed URL. For the vdfguard organization, it will look like:
   `https://pkgs.dev.azure.com/vdfguard/Darbot%20PowerShell/_packaging/<FEED_NAME>/nuget/v3/index.json`

---

## 4. Create a Personal Access Token (PAT)

1. In Azure DevOps, click your user icon (top right) > **Personal access tokens**.
2. Click **New Token**.
3. Set a name (e.g., "Darbot PowerShell NuGet"), select "vdfguard" organization, and set the scope to **Packaging (Read)** (or **Read & Write** if you need to publish).
4. Set an expiration (shorter is safer).
5. Click **Create** and **copy** the token. **You will not be able to see it again!**

---

## 5. Authenticate via Command Line

### Using `dotnet` (Recommended for .NET Core/SDK projects)

```powershell
dotnet nuget add source <FEED_URL> --name DarbotPowerShellFeed --username vdfguard --password <YOUR_PAT> --store-password-in-clear-text
```

Example (replace <FEED_NAME> with your actual feed name):

```powershell
dotnet nuget add source https://pkgs.dev.azure.com/vdfguard/Darbot%20PowerShell/_packaging/<FEED_NAME>/nuget/v3/index.json --name DarbotPowerShellFeed --username vdfguard --password <YOUR_PAT> --store-password-in-clear-text
```

### Using `nuget.exe` (Classic projects)

```powershell
nuget sources Add -Name DarbotPowerShellFeed -Source https://pkgs.dev.azure.com/vdfguard/Darbot%20PowerShell/_packaging/<FEED_NAME>/nuget/v3/index.json -UserName vdfguard -Password <YOUR_PAT> -StorePasswordInClearText
```

---

## 6. Authenticate via Visual Studio (UI)

1. Open Visual Studio.
2. Go to **Tools > Options > NuGet Package Manager > Package Sources**.
3. Click the **+** button to add a new source.
4. Name it (e.g., `DarbotPowerShellFeed`), paste the feed URL from section 3, and click **Update**.
5. When prompted for credentials, use "vdfguard" as username and your PAT as password.
6. Click **OK** to save.

---

## 7. Security Best Practices

- **Never** commit your PAT or `nuget.config` with credentials to source control.
- Use the [Azure Artifacts Credential Provider](https://github.com/microsoft/artifacts-credprovider) for improved security and automation.
- Regularly rotate your PATs and remove unused ones.

---

## 8. Troubleshooting

- If you get 401 Unauthorized, double-check your PAT scope and expiration.
- Make sure your feed URL is correct and you have access to the feed.
- If your PAT stops working, try signing into Azure DevOps again and/or create a new PAT.
- For more, see the official docs:
  - [Authenticate to private NuGet feeds](https://learn.microsoft.com/en-us/vcpkg/consume/third-party-authentication.nuget)
  - [Azure DevOps Artifacts NuGet](https://learn.microsoft.com/en-us/azure/devops/artifacts/nuget/dotnet-exe?view=azure-devops)
  - [Using PATs in Azure DevOps](https://learn.microsoft.com/en-us/azure/devops/organizations/accounts/use-personal-access-tokens-to-authenticate?view=azure-devops)

---

## 9. Automating with Azure Artifacts Credential Provider

- Download and install the [Azure Artifacts Credential Provider](https://github.com/microsoft/artifacts-credprovider#setup).
- Once installed, `dotnet restore` and `nuget restore` will prompt for Azure DevOps login and cache credentials securely.

---

## 10. Example: End-to-End Setup

1. Create PAT in Azure DevOps (see above).
2. Add the feed using `dotnet nuget add source` or `nuget sources Add`.
3. Run `dotnet restore` or `nuget restore` in your project directory.
4. Packages from the private feed should now restore without errors.

---

Happy building! For more help, see the Azure DevOps documentation or your internal DevOps support team.
