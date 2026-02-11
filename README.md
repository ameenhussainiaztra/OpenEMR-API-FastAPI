# OpenEMR API FastAPI Interface

A FastAPI application that provides a modern Python interface to interact with OpenEMR's REST API and FHIR API endpoints.

## Features

- 🚀 **FastAPI Framework** - Modern, fast Python web framework
- 📚 **Auto-generated Documentation** - Interactive Swagger UI and ReDoc
- 🔐 **OAuth 2.0 Support** - Secure authentication with OpenEMR
- 🏥 **FHIR R4 API** - Full FHIR Release 4 implementation
- 📋 **Standard OpenEMR API** - Native OpenEMR REST endpoints
- 🔄 **Token Management** - Automatic token handling
- ✅ **Type Safety** - Pydantic models for request/response validation

## Installation

1. **Clone or download this repository**

2. **Install dependencies:**
```bash
pip install -r requirements.txt
```

3. **Configure environment variables:**

Create a `.env` file or set environment variables:

```bash
# OpenEMR Server Configuration
OPENEMR_BASE_URL=https://localhost:9300
OPENEMR_CLIENT_ID=your_client_id
OPENEMR_CLIENT_SECRET=your_client_secret
OPENEMR_REDIRECT_URI=http://localhost:8000/oauth/callback
```

## Quick Start

1. **Start the FastAPI server:**
```bash
python main.py
```

Or using uvicorn directly:
```bash
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

2. **Access the API documentation:**
   - Swagger UI: http://localhost:8000/docs
   - ReDoc: http://localhost:8000/redoc

3. **Register OAuth Client (if not already done):**
```bash
curl -X POST http://localhost:8000/oauth/register \
  -H "Content-Type: application/json" \
  -d '{
    "client_name": "My FastAPI App",
    "redirect_uris": ["http://localhost:8000/oauth/callback"],
    "scope": "openid api:fhir patient/Patient.rs user/Patient.rs"
  }'
```

4. **Get Authorization:**
   - Visit: http://localhost:8000/oauth/authorize
   - Or use the Swagger UI to test endpoints

## API Endpoints

### Authentication

- `GET /oauth/authorize` - OAuth 2.0 authorization endpoint
- `GET /oauth/callback` - OAuth callback handler
- `POST /oauth/token` - Exchange code for token or refresh token
- `POST /oauth/register` - Register new OAuth client

### FHIR API

- `GET /fhir/metadata` - Get FHIR capability statement
- `GET /fhir/Patient` - Search patients
- `GET /fhir/Patient/{id}` - Get patient by ID
- `POST /fhir/Patient` - Create patient
- `GET /fhir/Observation` - Search observations
- `GET /fhir/Encounter` - Search encounters
- `GET /fhir/MedicationRequest` - Search medication requests
- `GET /fhir/Condition` - Search conditions
- `GET /fhir/Procedure` - Search procedures
- `GET /fhir/Appointment` - Search appointments
- `GET /fhir/DocumentReference/$docref` - Generate clinical document

### Standard OpenEMR API

- `GET /api/patient` - List patients
- `POST /api/patient` - Create patient
- `GET /api/patient/{pid}` - Get patient by ID
- `GET /api/patient/{pid}/encounter` - Get patient encounters
- `GET /api/encounter` - List encounters
- `GET /api/appointment` - List appointments

## Usage Examples

### Using Python requests

```python
import requests

# Get access token
token_response = requests.post(
    "http://localhost:8000/oauth/token",
    json={
        "grant_type": "authorization_code",
        "code": "your_authorization_code",
        "redirect_uri": "http://localhost:8000/oauth/callback"
    }
)
token = token_response.json()["access_token"]

# Search patients
patients = requests.get(
    "http://localhost:8000/fhir/Patient",
    headers={"Authorization": f"Bearer {token}"},
    params={"name": "John"}
)
print(patients.json())
```

### Using the Swagger UI

1. Open http://localhost:8000/docs
2. Click "Authorize" button
3. Enter your Bearer token
4. Try out any endpoint interactively

### Using cURL

```bash
# Get token
TOKEN=$(curl -X POST http://localhost:8000/oauth/token \
  -H "Content-Type: application/json" \
  -d '{
    "grant_type": "authorization_code",
    "code": "your_code",
    "redirect_uri": "http://localhost:8000/oauth/callback"
  }' | jq -r '.access_token')

# Search patients
curl -X GET "http://localhost:8000/fhir/Patient?name=John" \
  -H "Authorization: Bearer $TOKEN"
```

## Configuration

### OpenEMR Setup

Before using this API, ensure OpenEMR is configured:

1. **Enable APIs in OpenEMR:**
   - Go to: Administration → Config → Connectors
   - Enable "OpenEMR Standard REST API"
   - Enable "OpenEMR Standard FHIR REST API"

2. **Set Site Address:**
   - Administration → Config → Connectors → Site Address
   - Required for OAuth2 and FHIR

3. **Register OAuth Client:**
   - Use the `/oauth/register` endpoint
   - Or register directly with OpenEMR

### Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `OPENEMR_BASE_URL` | OpenEMR server base URL | `https://localhost:9300` |
| `OPENEMR_CLIENT_ID` | OAuth client ID | (required) |
| `OPENEMR_CLIENT_SECRET` | OAuth client secret | (required) |
| `OPENEMR_REDIRECT_URI` | OAuth redirect URI | `http://localhost:8000/oauth/callback` |

## Development

### Running in Development Mode

```bash
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

The `--reload` flag enables auto-reload on code changes.

### Project Structure

```
.
├── main.py              # FastAPI application
├── lambda_handler.py    # AWS Lambda handler (Mangum adapter)
├── requirements.txt     # Python dependencies
├── terraform/           # AWS Lambda deployment (Terraform)
│   ├── main.tf          # Lambda, API Gateway, IAM
│   ├── variables.tf     # Input variables
│   ├── outputs.tf       # API URL outputs
│   └── terraform.tfvars.example
├── scripts/
│   ├── build_lambda.ps1 # Windows build script
│   └── build_lambda.sh # Linux/macOS build script
├── README.md            # This file
└── .env                 # Environment variables (create this)
```

## Security Notes

⚠️ **Important Security Considerations:**

1. **HTTPS in Production:** Always use HTTPS in production environments
2. **Token Storage:** Current implementation uses in-memory storage. Use secure database storage in production
3. **CORS:** Configure CORS appropriately for your use case
4. **SSL Verification:** The code disables SSL verification (`verify=False`) for development. Enable it in production
5. **Environment Variables:** Never commit `.env` files or expose secrets

## Troubleshooting

### Connection Errors

- Verify `OPENEMR_BASE_URL` is correct
- Check if OpenEMR server is running
- Ensure APIs are enabled in OpenEMR configuration

### Authentication Errors

- Verify client ID and secret are correct
- Check OAuth client is registered in OpenEMR
- Ensure redirect URI matches registration

### SSL Certificate Errors

For development with self-signed certificates, the code disables SSL verification. For production:
- Use proper SSL certificates
- Set `verify=True` in httpx client

## API Documentation

Once the server is running, visit:
- **Swagger UI:** http://localhost:8000/docs
- **ReDoc:** http://localhost:8000/redoc

Both provide interactive documentation where you can test endpoints directly.

## AWS Lambda Deployment (Terraform)

Deploy this application to AWS Lambda using Terraform with API Gateway.

### Prerequisites

- Python 3.11+
- AWS CLI configured with credentials
- Terraform >= 1.0
- OpenEMR server URL and OAuth credentials

### Deploy Steps

1. **Build the Lambda deployment package:**

   **Recommended (Docker - ensures Linux compatibility for Lambda):**
   ```bash
   docker build -f scripts/Dockerfile.lambda-build --output terraform .
   # Creates terraform/lambda.zip (requires Docker BuildKit: DOCKER_BUILDKIT=1)
   ```

   **Windows (PowerShell):**
   ```powershell
   .\scripts\build_lambda.ps1
   ```

   **Linux/macOS:**
   ```bash
   chmod +x scripts/build_lambda.sh
   ./scripts/build_lambda.sh
   ```

   > **Note:** Lambda runs on Amazon Linux. If you build on Windows, packages with native binaries (pydantic, pyyaml) may fail. Use Docker build for production.

2. **Configure Terraform variables:**
   ```bash
   cd terraform
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars with your OpenEMR configuration
   ```

3. **Deploy:**
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

4. **Configure OpenEMR OAuth:**
   - Terraform outputs the `oauth_redirect_uri` after deployment
   - Add this URL to your OpenEMR OAuth client's allowed redirect URIs
   - Administration → Config → Connectors → your OAuth client

### Post-Deployment

- **API URL:** Shown in `terraform output api_url`
- **Swagger Docs:** `{api_url}docs`
- **ReDoc:** `{api_url}redoc`

### Terraform Variables

| Variable | Description | Required |
|----------|-------------|----------|
| `openemr_base_url` | OpenEMR server URL (e.g. https://openemr.example.com) | Yes |
| `openemr_client_id` | OAuth client ID | Yes |
| `openemr_client_secret` | OAuth client secret | Yes |
| `aws_region` | AWS region | No (default: us-east-1) |
| `lambda_memory_size` | Lambda memory in MB | No (default: 512) |
| `lambda_timeout` | Lambda timeout in seconds | No (default: 30) |

## License

This project is provided as-is for integration with OpenEMR. OpenEMR itself is licensed under GPL v3.

## Support

For OpenEMR API documentation:
- [OpenEMR API Documentation](https://github.com/openemr/openemr/blob/master/API_README.md)
- [OpenEMR Community Forum](https://community.open-emr.org/)

## Contributing

Feel free to submit issues, fork the repository, and create pull requests for any improvements.
