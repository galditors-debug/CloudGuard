# 🛡️ CloudGuard — Cloud File Validation & Processing Platform
### Problem Statement: CF-PS-09 (Hackathon Solution)

> A production-minded, cloud-native file validation, processing, and quarantine platform with zero-trust isolation, cryptographic SHA-256 deduplication, RFC 4180 parsing, and real-time observability.

---

## 🌟 Key Highlights & Evaluation Criteria Alignment

| Evaluation Criteria | CloudGuard Implementation |
| :--- | :--- |
| **1. Problem Relevance** | Solves high-risk ingestion vulnerabilities: stops malformed rows, schema drift, uninspected files, and duplicate payloads from polluting downstream systems. |
| **2. Innovation & Creativity** | Zero-trust three-tier isolation (`incoming` ➔ `processed` ➔ `quarantine`), cryptographic SHA-256 deduplication, live error diagnostics with row/column indicators, and dynamic rule updating. |
| **3. Technical Implementation** | Built with Node.js Express, RFC 4180 `csv-parse`, streaming downloads, atomic JSON persistence surviving reboots, and structured audit logger with secret redaction. |
| **4. Effective Cloud Technologies** | Pluggable `StorageAdapter` pattern directly integrated with `@aws-sdk/client-s3` for AWS S3 / MinIO / Cloudflare R2, plus honest local development emulation mode. |
| **5. Feasibility & Scalability** | Decoupled ingest pipeline, stateless worker design, stream-based file downloads, and minimal resource footprint. |
| **6. Demo & Presentation Quality** | Enterprise SaaS UI (deep navy/charcoal palette, electric blue accents, Lucide icons), 1-click test data loader for all 8 test files, and live health probes. |

---

## 🏗️ Architecture & Processing Pipeline

```mermaid
flowchart TD
    Client[Web UI / REST API] -->|POST /api/files (multipart)| UploadHandler[Express Multer Upload Handler]
    UploadHandler -->|Stream & SHA-256| HashEngine[Crypto SHA-256 Checksum]
    HashEngine -->|Check Existing Hash| DedupCheck{Duplicate Exists?}
    
    DedupCheck -->|Yes & Reject Flag| RejectDup[Quarantine: DUPLICATE_FILE]
    DedupCheck -->|No| IncomingStore[Incoming Storage Tier]
    
    IncomingStore --> ValidationEngine[RFC 4180 CSV Validation Engine]
    
    ValidationEngine -->|Headers, UTF-8, Row Checks| RulesCheck{Schema & Data Valid?}
    
    RulesCheck -->|Invalid| QuarantineStore[Quarantine Storage Tier]
    QuarantineStore --> AuditLogQ[Record Quarantine Event & Specific Reason]
    AuditLogQ --> PersistQ[Update Metadata: REJECTED]
    
    RulesCheck -->|Valid| ProcessingWorker[Processing & Enrichment Worker]
    ProcessingWorker --> ProcessedStore[Processed Output Storage Tier]
    ProcessedStore --> AuditLogP[Record Accepted Audit Log]
    ProcessedStore --> PersistP[Update Metadata: ACCEPTED]
    
    PersistP --> Dashboard[CloudGuard Dashboard & Observability API]
    PersistQ --> Dashboard
```

---

## 📁 Project Structure

```text
CloudGuard/
├── backend/
│   └── src/
│       ├── config/
│       │   └── index.js                   # Environment & validation configuration
│       ├── routes/
│       │   ├── files.js                   # Ingest, query, reprocess, streaming download
│       │   ├── metrics.js                 # Live operational metrics
│       │   ├── logs.js                    # Searchable audit trail & export
│       │   ├── cloud.js                   # Infrastructure health & cloud diagnostics
│       │   └── settings.js                # Dynamic rules & test seed triggers
│       ├── services/
│       │   ├── validationEngine.js        # RFC 4180 CSV parser & rule validator
│       │   ├── processingPipeline.js      # Explicit state machine orchestrator
│       │   ├── metadataStore.js           # Atomic JSON persistence layer
│       │   ├── auditLogger.js             # Structured compliance & security audit logger
│       │   └── storage/
│       │       ├── storageInterface.js    # Storage abstraction contract
│       │       ├── localStorageAdapter.js # Local filesystem dev emulation
│       │       ├── s3StorageAdapter.js    # AWS S3 SDK integration (@aws-sdk/client-s3)
│       │       └── storageFactory.js      # Runtime adapter resolver & health checker
│       └── server.js                      # Express application entry point & SPA server
├── public/                                # Enterprise SaaS Dashboard (Vanilla CSS & JS)
│   ├── index.html                         # Semantic HTML5 layout with Lucide icons
│   ├── css/
│   │   └── styles.css                     # Deep navy enterprise design system
│   └── js/
│       └── app.js                         # Dynamic state, charts, and API bindings
├── test_data/                             # 8 Required Problem Statement Test Files
│   ├── students1.csv                      # Valid: Standard schema (3 rows)
│   ├── students2.csv                      # Valid: Multi-record (5 rows)
│   ├── students3.csv                      # Valid: Quoted commas & escaped quotes
│   ├── invalid.txt                        # Invalid: Unsupported media type
│   ├── missing_columns.csv                # Invalid: Missing required 'department'
│   ├── empty.csv                          # Invalid: 0-byte empty file
│   ├── malformed.csv                      # Invalid: Inconsistent column count (row 2)
│   └── missing_values.csv                 # Invalid: Missing required student_id value
├── tests/
│   └── run_tests.js                       # Automated test suite (11 test assertions)
├── .env.example                           # Configuration environment template
└── package.json                           # NPM dependencies & scripts
```

---

## 🚀 Quick Start Guide

### 1. Prerequisites
- **Node.js**: v18.0.0 or later (Tested on Node.js `v24.18.1`)
- **NPM**: `npm.cmd` on Windows

### 2. Install Dependencies
```bash
npm install
```

### 3. Run Automated Tests
Execute the 11-test automated assertion suite verifying valid, invalid, duplicate, and edge-case files:
```bash
npm test
```
*Expected Output:* `Passed: 11 / 11, Failed: 0 / 11`.

### 4. Start the Application
```bash
npm start
```
The server will boot on `http://localhost:5000`:
- **Web UI Dashboard**: [http://localhost:5000](http://localhost:5000)
- **API Health Check**: [http://localhost:5000/api/health](http://localhost:5000/api/health)
- **Cloud Status**: [http://localhost:5000/api/cloud/status](http://localhost:5000/api/cloud/status)

---

## 🧪 Demonstrated Test Files (CF-PS-09)

CloudGuard includes all required test files in `test_data/` and provides **1-Click Quick Buttons** in the **Upload & Validate** UI:

| File | Status | Category | Validation Rule Verified |
| :--- | :--- | :--- | :--- |
| `students1.csv` | **ACCEPTED** | `VALID` | Standard schema headers (`student_id,name,department`) and valid rows. |
| `students2.csv` | **ACCEPTED** | `VALID` | Multi-record dataset with diverse departments. |
| `students3.csv` | **ACCEPTED** | `VALID` | RFC 4180 complex values with commas and escaped quotes inside fields. |
| `invalid.txt` | **REJECTED** | `UNSUPPORTED_MEDIA_TYPE` | Rejects non-CSV extensions and MIME types. |
| `missing_columns.csv` | **REJECTED** | `SCHEMA_VIOLATION` | Rejects missing required `department` header. |
| `empty.csv` | **REJECTED** | `EMPTY_FILE` | Rejects 0-byte empty payloads. |
| `malformed.csv` | **REJECTED** | `MALFORMED_DATA` | Rejects rows with inconsistent column counts (row 2 has 4 cols instead of 3). |
| `missing_values.csv` | **REJECTED** | `MISSING_REQUIRED_VALUE` | Rejects empty required `student_id` cell in row 2. |
| `students1_copy.csv` | **REJECTED** | `DUPLICATE_FILE` | Cryptographic SHA-256 collision / duplicate ingest detection. |

---

## ☁️ Cloud Integration & Production Deployment

CloudGuard comes with a built-in AWS S3 Storage Adapter (`s3StorageAdapter.js`) using the official `@aws-sdk/client-s3`.

### Connecting Real AWS S3 Buckets:
1. Create three private S3 buckets in your AWS Console or Terraform:
   - `cloudguard-incoming`
   - `cloudguard-processed`
   - `cloudguard-quarantine`
2. Create an IAM User or Task Role with least-privilege permissions:
   ```json
   {
     "Version": "2012-10-17",
     "Statement": [
       {
         "Effect": "Allow",
         "Action": [
           "s3:PutObject",
           "s3:GetObject",
           "s3:HeadBucket"
         ],
         "Resource": [
           "arn:aws:s3:::cloudguard-incoming/*",
           "arn:aws:s3:::cloudguard-processed/*",
           "arn:aws:s3:::cloudguard-quarantine/*"
         ]
       }
     ]
   }
   ```
3. Set your credentials in `.env`:
   ```env
   STORAGE_PROVIDER=s3
   AWS_REGION=us-east-1
   AWS_ACCESS_KEY_ID=your_access_key
   AWS_SECRET_ACCESS_KEY=your_secret_key
   S3_BUCKET_INCOMING=cloudguard-incoming
   S3_BUCKET_PROCESSED=cloudguard-processed
   S3_BUCKET_QUARANTINE=cloudguard-quarantine
   ```
4. Restart the server or switch provider dynamically in the **Cloud Infrastructure** dashboard tab.

---

## 📡 REST API Reference

| Endpoint | Method | Description |
| :--- | :--- | :--- |
| `GET /api/health` | GET | Real-time health check, uptime, and active storage engine status. |
| `POST /api/files` | POST | Multipart upload (`file`). Calculates SHA-256, validates, processes, and stores. |
| `GET /api/files` | GET | List files with filters (`status`, `search`, `limit`, `offset`, `sortBy`). |
| `GET /api/files/:id` | GET | Get detailed record, validation breakdown, and storage pointers. |
| `GET /api/files/:id/download?type=processed` | GET | Authorized streaming download of processed JSON output. |
| `GET /api/files/:id/download?type=quarantine`| GET | Authorized streaming download of raw quarantined file. |
| `POST /api/files/:id/reprocess` | POST | Re-evaluates a quarantined file against current validation rules. |
| `GET /api/metrics` | GET | Live telemetry: accepted, quarantined, success rate, latency, rejection breakdown. |
| `GET /api/logs` | GET | Searchable and filterable security audit logs. |
| `GET /api/logs/export` | GET | Download complete audit trail as JSON. |
| `GET /api/cloud/status` | GET | Honest infrastructure and cloud connectivity diagnostics. |
| `POST /api/cloud/test` | POST | Trigger live health probe against configured storage provider. |
| `POST /api/settings/seed-samples` | POST | Seed the 8 test files through the ingest pipeline. |
| `POST /api/settings/reset` | POST | Clean reset of database and audit logs for hackathon demo. |

---

## 🎬 Hackathon Demonstration Script (3-Minute Walkthrough)

1. **Overview Dashboard**:
   - Open `http://localhost:5000`.
   - Point out the KPI cards (Total Ingested, Valid Processed, Quarantined, Validation Rate).
   - Click **"Seed 8 Files"** to load the required test files. Observe live metrics updating.
2. **Upload & Validate**:
   - Navigate to **Upload & Validate**.
   - Click `students1.csv` from the 1-Click Test Loader. Show the green **File Accepted** card with 8/8 security checks passed and SHA-256 fingerprint.
   - Click `missing_columns.csv`. Show the red **Validation Failed — Quarantined** card, highlighting the specific rejection reason: `Missing required column(s): department`.
3. **File Processing**:
   - Navigate to **File Processing**.
   - Show the table of accepted files. Click **"View JSON"** to display enriched student records and department summaries.
   - Click **"Download"** to demonstrate authorized streaming file output.
4. **Quarantine & Reprocessing**:
   - Navigate to **Quarantine**.
   - Show rejected files with isolated storage paths. Click **"Diagnostics"** to view line numbers and exact failure causes.
   - Click **"Reprocess"** to illustrate the recovery pipeline.
5. **Activity Logs & Cloud Infrastructure**:
   - Navigate to **Activity Logs** to review the immutable audit trail (notice that passwords/file contents are never leaked).
   - Navigate to **Cloud Infrastructure** to highlight honest connectivity status, AWS S3 deployment checklist, and click **"Run Live Health Probe"**.

---

## 🔒 Security Best Practices Implemented

- **Backend-Only Validation**: Never trusts client-side checks alone.
- **RFC 4180 Parsing**: Uses `csv-parse` to prevent CSV injection or malformed row parsing errors.
- **Filename Sanitization**: Normalizes filenames and strips path traversal sequences (`../`).
- **Private By Default**: Uploaded files and storage locations are kept private and accessed only through authorized streaming endpoints.
- **Zero-Secret Logging**: Audit logger redacts sensitive credentials and prevents logging file bodies.
- **Cryptographic Deduplication**: Computes SHA-256 checksums to reject duplicate files before unnecessary processing.
