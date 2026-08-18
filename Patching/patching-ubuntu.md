## What this script does

- **1. Checks if the user is root**
- **2. Logs everything to /var/log/patching_*.log**
- **3. Checks disk space**
- **4. Checks failed services**
- **5. Saves the current kernel version**
- **6. Runs apt update**
- **7. Lists available updates**
- **8. Applies security updates using unattended-upgrade**
- **9. Checks if a reboot is required**
- **10. Creates a complete audit log**

### Production process around the script

**Before running it:**

- Get change approval.
- Remove the server from the Load Balancer (if applicable).
- Create an EBS/VM snapshot.
- Run the script.
- Reboot only if /var/run/reboot-required exists.

**Verify services:**

```bash
systemctl status nginx
systemctl status docker
```

**Verify the application:**

- curl localhost
- Add the server back to the Load Balancer.
- Monitor the server.

Note : "For Ubuntu production patching, used **apt update** to refresh repositories, **unattended-upgrade** to apply security patches only, check if a reboot is required using /var/run/reboot-required, validate services and applications after patching, and maintain logs for auditing and troubleshooting.


### flow

                    ┌──────────────────────┐
                    │       START          │
                    └──────────┬───────────┘
                               │
                               ▼
                    ┌──────────────────────┐
                    │ Check root access    │
                    └──────────┬───────────┘
                               │
                         Is root?
                        /       \
                      NO         YES
                      │           │
                      ▼           ▼
                   EXIT      Collect host info
                                  │
                                  ▼
                           Collect OS info
                                  │
                                  ▼
                           Check disk space
                                  │
                                  ▼
                         Check failed services
                                  │
                                  ▼
                         Record current kernel
                                  │
                                  ▼
                    ┌──────────────────────┐
                    │      apt update      │
                    └──────────┬───────────┘
                               │
                       Did apt update work?
                         /             \
                       NO               YES
                       │                 │
                       ▼                 ▼
                 Log error + EXIT   Show available
                                   package updates
                                         │
                                         ▼
                              Is unattended-upgrades
                                   installed?
                                /             \
                              NO               YES
                              │                 │
                              ▼                 │
                       Install package          │
                              │                 │
                       Installation OK?         │
                         /       \              │
                       NO         YES            │
                       │           │             │
                       ▼           └──────┬──────┘
                  Log error + EXIT        │
                                          ▼
                              Run unattended-upgrade
                                          │
                                  Patching successful?
                                    /          \
                                  NO            YES
                                  │              │
                                  ▼              ▼
                           Log error + EXIT   Check kernel
                                                  │
                                                  ▼
                                      Check reboot-required
                                           /          \
                                         YES           NO
                                          │             │
                                          ▼             ▼
                                   Log "Reboot        Log "No
                                    required"        reboot"
                                          │             │
                                          └──────┬──────┘
                                                 │
                                                 ▼
                                      PATCHING COMPLETED
                                                 │
                                                 ▼
                                           END / LOG
