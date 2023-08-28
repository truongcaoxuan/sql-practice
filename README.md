# SQL PRACTICE - MS SQL SERVER

## Intro

This repository is designed to provide a collection of SQL practice exercises and resources specifically tailored for Microsoft SQL Server. If you want to enhance your SQL skills and gain hands-on experience with SQL queries, database design, and data manipulation in the context of Microsoft SQL Server, this repository is the perfect place to start.

Key Features:

- SQL practice exercises covering various topics including querying, data manipulation, stored procedures, functions, views, and more.
- Sample datasets to work with, allowing you to apply SQL concepts to real-world scenarios.
- Step-by-step instructions and solutions for each practice exercise to guide you through the learning process.
- Helpful tips, best practices, and explanations for SQL concepts and techniques specific to Microsoft SQL Server.

Whether you are a beginner looking to learn SQL or a more experienced SQL developer seeking to sharpen your skills on Microsoft SQL Server, this repository will help you practice and improve your SQL proficiency in a SQL Server environment.

Note: This repository assumes basic SQL knowledge. If you are new to SQL, you may want to start with introductory SQL resources before diving into the exercises provided here.

Feel free to contribute your own SQL practice exercises, improvements, or suggestions to make this repository a valuable resource for the SQL community using Microsoft SQL Server.

Get ready to level up your SQL skills with hands-on practice in a Microsoft SQL Server environment!

## Install-SqlServer.ps1

This script installs MS SQL Server on Windows OS silently from ISO image that can be available locally or downloaded from the Internet.
Transcript of entire operation is recorded in the log file.

The script lists parameters provided to the native setup but hides sensitive data. See the provided links for SQL Server silent install details.

The installer is tested with SQL Servers 2016-2019 and PowerShell 3-7.

### Prerequisites

1. Windows OS
2. Administrative rights
3. MS SQL Server ISO image [optional]

### Usage

The fastest way to install core SQL Server is to run in administrative shell:

```ps1
./Install-SqlServer.ps1 -EnableProtocols
```

This will download and install **SQL Server Development Edition** and enable all protocols. Provide your own ISO image of any edition using `ISOPath`.

This assumes number of default parameters and installs by default only `SQLEngine` feature. Run `Get-Help ./Install-SqlServer.ps1 -Full` for parameter details.

To **test installation**, after running this script execute:

```ps1
# Set-Alias sqlcmd "$Env:ProgramFiles\Microsoft SQL Server\Client SDK\ODBC\170\Tools\Binn\SQLCMD.EXE"
"SELECT @@version" | sqlcmd
```

### Notes

- Behind the proxy use `HTTP_PROXY` environment variable
- SQL Server Management Studio isn't distributed along with SQL Server any more. Install via chocolatey: [`cinst sql-server-management-studio`](https://chocolatey.org/packages/sql-server-management-studio)
- On PowerShell 5 progress bar significantly slows down the download. Use `$progressPreference = 'silentlyContinue'` to disable it prior to calling this function.
- SQL Server Development Edition has all features of Enterprise Edition and you can license it as Enterprise edition if needed.

#### How to find SQL Server direct download

1. Download evaluation installer from official site
    - Example for v2022: <https://www.microsoft.com/en-us/evalcenter/download-sql-server-2022>
    - This downloads file: `SQL2022-SSEI-Eval.exe`
1. Unpack evalutation installer exe using 7zip
    - This unpacks its resources and other stuff as text files
1. Search for `.iso` in files
    - For example using [dngrep](https://dngrep.github.io)

See ticket [#3](https://github.com/majkinetor/Install-SqlServer/issues/3#issuecomment-1536174746) for details.

#### Direct download list

1. [2022 Development Edition](https://download.microsoft.com/download/3/8/d/38de7036-2433-4207-8eae-06e247e17b25/SQLServer2022-x64-ENU-Dev.iso)
2. [2019 Development Edition](https://download.microsoft.com/download/7/c/1/7c14e92e-bdcb-4f89-b7cf-93543e7112d1/SQLServer2019-x64-ENU-Dev.iso)

### Troubleshooting

#### Installing on remote machine using PowerShell remote session

The following errors may occur:

    There was an error generating the XML document
        ... Access denied
        ... The computer must be trusted for delegation and the current user account must be configured to allow delegation

**The solution**: Use WinRM session parameter `-Authentication CredSSP`.

To be able to use it, the following settings needs to be done on both local and remote machine:

1. On local machine using `gpedit.msc`, go to *Computer Configuration -> Administrative Templates -> System -> Credentials Delegation*.<br>
Add `wsman/*.<domain>` (set your own domain) in the following settings
    1. *Allow delegating fresh credentials with NTLM-only server authentication*
    2. *Allow delegating fresh credentials*
1. The remote machine must be set to behave as CredSSP server with `Enable-WSManCredSSP -Role server`

### Links

- [Install SQL Server from the Command Prompt](https://docs.microsoft.com/en-us/sql/database-engine/install-windows/install-sql-server-2016-from-the-command-prompt)
  - [Features](https://docs.microsoft.com/en-us/sql/database-engine/install-windows/install-sql-server-2016-from-the-command-prompt#Feature)
  - [Accounts](https://docs.microsoft.com/en-us/sql/database-engine/install-windows/install-sql-server-2016-from-the-command-prompt#Accounts)
- [Download SQL Server Management Studio](https://docs.microsoft.com/en-us/sql/ssms/download-sql-server-management-studio-ssms)
- [Editions and features](https://docs.microsoft.com/en-us/sql/sql-server/editions-and-components-of-sql-server-2017)
