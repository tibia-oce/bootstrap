## Creating a PAT

![pat](./pat.png)

To create a Personal Access Token (PAT) on GitHub for reading and writing packages, follow these steps:

### Log in to GitHub
Go to [GitHub](https://github.com) and log in to your account.

### Access Settings
Click on your profile picture in the upper-right corner, then select **Settings** from the dropdown menu.

### Navigate to Developer Settings
In the left sidebar, scroll down and click on **Developer settings**.

### Personal Access Tokens
Click on **Personal access tokens** in the left sidebar, then select **Tokens (classic)** if you're using classic tokens, or **Fine-grained tokens** if you're using the newer fine-grained tokens.

### Generate New Token

- **For classic tokens:**
  Click on the **Generate new token** button.

### Configure Token Permissions

- **For classic tokens:**
  - Provide a **Note** to describe the token's purpose (e.g., "Package read/write").
  - Set an **Expiration** date for the token if desired.
  - Under **Select scopes**, check the following boxes:
    - `write:packages` (for writing packages)
    - `read:packages` (for reading packages)
    - Optionally, you may also need `delete:packages` if you want to delete packages.

### Generate Token
Click on the **Generate token** button at the bottom of the page.

### Save Your Token
Copy the generated token immediately and store it securely. You won’t be able to see the token again after you navigate away from the page.

### Use Your Token
You can now use this token for authentication when accessing GitHub Packages (in our case, the published server images).
