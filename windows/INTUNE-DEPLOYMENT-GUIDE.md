# Deploy Chrome Helper through Microsoft Intune

## Files

- Package: [ChromeHelper.intunewin](https://github.com/prashilthegreat/chrome-helper/releases/latest/download/ChromeHelper.intunewin)
- Settings reference: [Intune-Deployment-Settings.txt](https://github.com/prashilthegreat/chrome-helper/releases/latest/download/Intune-Deployment-Settings.txt)

## 1. Create the application

1. Open [Microsoft Intune Admin Center](https://intune.microsoft.com/).
2. Go to **Apps → Windows**.
3. Select **Create** or **Add**.
4. Choose **Windows app (Win32)**.
5. Upload `ChromeHelper.intunewin`.

## 2. App information

- **Name:** `Chrome Helper`
- **Description:** `Always-on-top Chrome profile launcher for Microsoft 365 Admin.`
- **Publisher:** `Prashil Koirala`
- **App version:** `1.1.0`
- **Category:** `Productivity`
- **Information URL:** `https://github.com/prashilthegreat/chrome-helper`
- **Privacy URL:** `https://prashilkoirala.com.np/`

## 3. Program settings

**Install command:**

```text
ChromeHelperSetup.exe /VERYSILENT /SUPPRESSMSGBOXES /NORESTART /SP-
```

**Uninstall command:**

```text
"%ProgramFiles%\Chrome Helper\unins000.exe" /VERYSILENT /SUPPRESSMSGBOXES /NORESTART
```

- **Install behavior:** `System`
- **Device restart behavior:** `No specific action`
- **Allow available uninstall:** `Yes`, if displayed

Keep the standard return codes: `0`, `1707`, `3010`, `1641`, and `1618`.

## 4. Requirements

- **Operating system architecture:** `64-bit`
- **Minimum operating system:** `Windows 10 22H2`

No additional requirement rule is needed.

## 5. Detection rule

Choose **Manually configure detection rules**, then add:

- **Rule type:** `File`
- **Path:** `%ProgramFiles%\Chrome Helper`
- **File or folder:** `ChromeHelper.exe`
- **Detection method:** `String (version)`
- **Operator:** `Greater than or equal to`
- **Value:** `1.1.0.0`
- **Associated with a 32-bit app on 64-bit clients:** `No`

## 6. Dependencies and supersedence

- **Dependencies:** None
- **Supersedence:** None

## 7. Assignment

1. Start with a small pilot user or device group.
2. Add the group under **Required** for automatic installation.
3. Use **As soon as possible** for availability.
4. Create the app and wait for package processing to complete.

To offer it through Company Portal instead, assign the group under **Available for enrolled devices**.

## 8. Synchronize the test device

On Windows:

1. Open **Settings → Accounts → Access work or school**.
2. Select the connected work account.
3. Select **Info → Sync**.

Alternatively, use **Company Portal → Settings → Sync**.

The installed executable should be located at:

```text
C:\Program Files\Chrome Helper\ChromeHelper.exe
```

## 9. Monitor deployment

In Intune, open **Apps → Windows → Chrome Helper**, then check **Device install status** and **User install status**.

On the Windows device, troubleshooting logs are located at:

```text
C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\IntuneManagementExtension.log
```

## Security-policy note

The package is not currently Authenticode-signed. Intune can distribute and install the Win32 package, but Intune packaging does not override WDAC or App Control for Business policies that block unsigned executables. If such a policy applies, the administrator must add an allow policy or sign the installer and executable with a certificate trusted by managed devices.

Microsoft documentation: [Add and assign Win32 apps](https://learn.microsoft.com/en-us/intune/app-management/deployment/add-win32)

