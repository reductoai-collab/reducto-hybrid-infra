# Box — Hybrid VPC Setup Guide

Box does not have a Terraform provider, so setup is performed through the Box Developer Console and Admin Console.

## Prerequisites

- Box Enterprise account with admin access
- Access to the [Box Developer Console](https://app.box.com/developers/console)

## Setup Steps

### 1. Create a Custom Application

1. Go to the [Box Developer Console](https://app.box.com/developers/console)
2. Click **Create New App** → **Custom App**
3. Select **Server Authentication (Client Credentials Grant)** as the authentication method
4. Name the app (e.g., "Reducto Integration")
5. Click **Create App**

### 2. Configure Permissions

In the app's **Configuration** tab:

1. Under **Application Scopes**, enable:
   - **Read all files and folders stored in Box**
   - **Write all files and folders stored in Box**
2. Under **App Access Level**, select **App + Enterprise Access**
3. Click **Save Changes**

### 3. Authorize in Admin Console

1. Go to [Box Admin Console](https://app.box.com/master) → **Apps** → **Custom Apps**
2. Click **Add App**
3. Enter the **Client ID** from the app's Configuration tab
4. Click **Authorize**

> **Note:** This requires Box Enterprise Admin privileges.

### 4. Create a Dedicated Folder

1. Create a new folder in Box (e.g., "Reducto Processing")
2. Note the **Folder ID** from the URL: `https://app.box.com/folder/<FOLDER_ID>`
3. The service account (created with the app) automatically has access

> For better isolation, use a dedicated folder rather than the root (`0`).

### 5. Share Credentials with Reducto

From the app's **Configuration** tab, securely provide:

| Value | Where to Find |
|-------|---------------|
| **Client ID** | Configuration → OAuth 2.0 Credentials |
| **Client Secret** | Configuration → OAuth 2.0 Credentials |
| **Enterprise ID** | General Settings → Enterprise ID |
| **Folder ID** | URL of the target folder |

## Validation

Test that the app can access the folder using the Box CLI:

```bash
# Install Box CLI
npm install -g @box/cli

# Configure with your app credentials
box configure:environments:add

# List folder contents
box folders:items <FOLDER_ID>

# Upload a test file
box files:upload test.pdf --parent-id <FOLDER_ID>
```

## Security Notes

- **Client Credentials Grant (CCG)** is the recommended auth method for server-to-server integrations
- The app's service account acts independently — no user credentials are stored
- Access can be scoped to specific folders using Box collaborations
- Client Secret can be rotated in the Developer Console without downtime
- Box provides detailed audit logs of all file operations

## Limitations

- No Terraform provider — infrastructure-as-code automation requires wrapping the Box API
- Box API rate limits are more aggressive than cloud object stores (Reducto handles this automatically)
- No native per-object TTL — use Box retention policies for automatic cleanup
