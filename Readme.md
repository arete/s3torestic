# s3torestic 🛡️

**s3torestic** is a lightweight, secure, and **rootless** Dockerized utility designed to bridge the gap between a live S3 bucket and an encrypted, versioned backup repository. 

It uses **rclone** to synchronize data from a source S3 bucket to a local staging area and **restic** to create deduplicated, encrypted snapshots into a destination S3 repository.

## 🚀 Key Features

- **S3-to-S3 Workflow**: Seamlessly clone data from any S3 provider and store it as a restic snapshot in another.
- **Rootless Execution**: Runs as a non-privileged user (`resticuser`) for enhanced security and compatibility with hardened environments (like OpenShift or restricted Kubernetes).
- **Environment Driven**: Fully configurable via environment variables—no need to mount or bake configuration files into the image.
- **Client-Side Encryption**: Your data is encrypted locally before being sent to the destination.
- **Automatic Pruning**: Integrated retention policy support to keep your storage costs under control.

---

## 🛠️ Configuration

The container is configured entirely via Environment Variables.

### 1. Destination (Restic Repository)
| Variable | Description |
| :--- | :--- |
| `RESTIC_REPOSITORY` | The destination S3 URL (e.g., `s3:https://s3.amazonaws.com/my-backup-bucket`) |
| `RESTIC_PASSWORD` | Password used to encrypt the Restic repository |
| `AWS_ACCESS_KEY_ID` | Access Key for the **destination** bucket |
| `AWS_SECRET_ACCESS_KEY` | Secret Key for the **destination** bucket |

### 2. Source (Rclone Sync)
| Variable | Description |
| :--- | :--- |
| `SRC_S3_BUCKET` | Name of the source bucket to clone |
| `SRC_S3_ENDPOINT` | Endpoint of the source S3 (e.g., `https://s3.eu-central-1.amazonaws.com`) |
| `SRC_S3_ACCESS_KEY` | Access Key for the **source** bucket |
| `SRC_S3_SECRET_ACCESS_KEY` | Secret Key for the **source** bucket |
| `SRC_S3_REGION` | Region of the source bucket (default: `us-east-1`) |

### 3. Optional Settings
| Variable | Description | Default |
| :--- | :--- | :--- |
| `KEEP_LAST` | Number of snapshots to keep (runs `restic forget --prune`) | (Disabled) |
| `SOURCE_PATH` | Internal path for temporary data synchronization | `/data` |

---

## 📦 Getting Started

### Build the Image
```bash
docker build -t s3torestic .