# Customizing MINIX 3 - OS Project

## Project Overview
As part of the **CSC 502: Principles of OS & Distributed Systems** course, we have customized the **MINIX 3** operating system by implementing the following modifications:

- **Custom Startup and Shutdown Banner**: Displaying personalized messages during system startup and shutdown.
- **New System Command**: Adding a custom system command that can be executed in the terminal.
- **New System Call and User Library**: Introducing a new system call and a corresponding user library to facilitate kernel-level operations.

### Project Team
- **Prabesh Bashyal**
- **Pratik Adhikari**
- **Saroj Poudel**
- **Spandan Bhandari**

---

## Introduction to MINIX 3
**MINIX 3** is an open-source, microkernel-based operating system designed for flexibility, security, and reliability. It runs on **x86** and **ARM** architectures and is compatible with **NetBSD**, allowing it to support numerous NetBSD packages. The OS follows a **microkernel architecture**, where only essential services operate in kernel mode, and all other components function as isolated user-mode processes.


---

## Installation Guide
To install **MINIX 3** on a local machine using **VirtualBox**, **VMware**, or **Eclipse**, follow these steps:

### Step 1: Prerequisites
1. Download the latest **MINIX 3** image from the [official website](http://www.minix3.org/).
2. Install **[VirtualBox](https://www.virtualbox.org/wiki/Downloads)**.
3. Install **[VMware Workstation](https://www.vmware.com/products/workstation.html)** (if using VMware instead of VirtualBox).
4. Install **[Eclipse IDE](https://www.eclipse.org/downloads/)** if you wish to develop using Eclipse.

### Step 2: Setting Up VirtualBox
1. Open **VirtualBox** and navigate to **Preferences → General**.
2. Set the **Default Machine Folder** to your preferred directory.
3. Click **New** to create a virtual machine:
   - **Name:** `Minix3.2.1`
   - **Type:** `Other`
   - **Version:** `Other/Unknown`
4. Allocate **256 MB** of memory.
5. Configure Virtual Hard Disk:
   - Create a **VHD** and select **VDI** format.
   - Choose **Dynamically allocated** storage.
   - Set disk size to **1.2GB**.
6. Click **Create** to finalize the VM setup.

### Step 3: Setting Up VMware (Alternative to VirtualBox)
1. Open **VMware Workstation**.
2. Click on **Create a New Virtual Machine**.
3. Select **Custom (Advanced)** and click **Next**.
4. Choose **I will install the operating system later**.
5. Select **Other** as the guest operating system.
6. Allocate at least **256 MB** of RAM.
7. Create a **New Virtual Disk**, set it to **1.2GB**, and choose **Store as a single file**.
8. Click **Finish**, then edit VM settings to add the **MINIX 3 ISO** as the boot disk.
9. Start the VM and proceed with MINIX 3 installation.

### Step 4: Setting Up Eclipse for MINIX Development
1. Install **Eclipse CDT** (C Development Tools).
2. Install the **Remote System Explorer (RSE)** plugin for Eclipse.
3. In Eclipse, navigate to **File → New → Project → C/C++ Remote Application**.
4. Set up a **Remote Connection** to your MINIX VM using SSH (explained in the next section).
5. Open the **Terminal** in Eclipse and connect to MINIX 3 via SSH.
6. Develop and deploy directly to the MINIX 3 system from Eclipse.

---

## Enabling Remote Access
Since the **MINIX console** lacks scroll bars, SSH and SFTP can be used for remote file editing.

### Step 1: Installing OpenSSH
1. Start the **Minix3.2.1 VM** and log in as `root`.
2. Set a root password using:
   ```sh
   passwd
## Step 1: Updating `pkgin` and Installing OpenSSH

### Update the `pkgin` Package Manager
```sh
pkgin update || export PKG_REPOS=http://homepages.cs.ncl.ac.uk/nick.cook/csc2025/minix/3.2.1/packages && pkgin update
```

### Install OpenSSH
```sh
pkgin install openssh
```

### Restart the System
```sh
shutdown -r now
```

## Step 2: Configuring Port Forwarding in VirtualBox & VMware

### VirtualBox
1. Navigate to **Settings → Network → Adapter 1 → Advanced → Port Forwarding**.
2. Add a new rule with the following attributes:
   - **Name**: ssh-access  
   - **Host Port**: 2222  
   - **Guest IP**: 10.0.2.15  
   - **Guest Port**: 22  
   - **Host IP**: 127.0.0.1  
   - **Protocol**: TCP  
3. Find the guest IP by running:
   ```sh
   ifconfig
   ```
4. Connect to the VM from your host system:
   ```sh
   ssh -p 2222 root@127.0.0.1
   ```

### VMware
1. Open **VMware Workstation** and select your **MINIX 3 VM**.
2. Navigate to **Edit → Virtual Network Editor**.
3. Configure **NAT Settings** and forward **port 2222 to 22**.
4. Use the same SSH connection command as above:
   ```sh
   ssh -p 2222 root@127.0.0.1
   ```

## Step 3: Developing MINIX 3 in Eclipse
1. In **Eclipse**, open the **Remote System Explorer**.
2. Add a **New Connection** using **SSH**.
3. Browse the MINIX file system remotely and edit files using Eclipse.
4. Compile and test modifications directly from the **Eclipse terminal**.

## References
- [VirtualBox Downloads](https://www.virtualbox.org/wiki/Downloads)
- [VMware Workstation](https://www.vmware.com/products/workstation-pro.html)
- [Eclipse IDE](https://www.eclipse.org/downloads/)
- [MINIX 3 Official Website](https://www.minix3.org/)

## Disclaimer
This is a **course project** and is not an official modification of MINIX 3. It was developed purely for **educational purposes**.
