#!/usr/bin/env bash
set -euo pipefail

# One-time setup for GitHub Actions -> Google Cloud Run deployment via WIF.
# Usage:
#   1) Review and edit variables below as needed.
#   2) Authenticate: gcloud auth login
#   3) Run: bash scripts/setup-gcp-github-actions.sh

PROJECT_ID="softllc-home-page"
PROJECT_NUMBER="400671380418"
REGION="us-central1"
AR_REPO="homepage"
POOL_ID="github"
PROVIDER_ID="homepage"
GITHUB_REPO="mcnerthney/homepage"
DEPLOYER_SA="github-actions-deployer"
DEPLOYER_SA_EMAIL="${DEPLOYER_SA}@${PROJECT_ID}.iam.gserviceaccount.com"

# Optional: override via environment variables when running the script.
PROJECT_ID="${PROJECT_ID_OVERRIDE:-$PROJECT_ID}"
PROJECT_NUMBER="${PROJECT_NUMBER_OVERRIDE:-$PROJECT_NUMBER}"
REGION="${REGION_OVERRIDE:-$REGION}"
AR_REPO="${AR_REPO_OVERRIDE:-$AR_REPO}"
POOL_ID="${POOL_ID_OVERRIDE:-$POOL_ID}"
PROVIDER_ID="${PROVIDER_ID_OVERRIDE:-$PROVIDER_ID}"
GITHUB_REPO="${GITHUB_REPO_OVERRIDE:-$GITHUB_REPO}"
DEPLOYER_SA="${DEPLOYER_SA_OVERRIDE:-$DEPLOYER_SA}"
DEPLOYER_SA_EMAIL="${DEPLOYER_SA}@${PROJECT_ID}.iam.gserviceaccount.com"

echo "Using project: ${PROJECT_ID} (${PROJECT_NUMBER})"

gcloud config set project "${PROJECT_ID}"

gcloud services enable \
  run.googleapis.com \
  artifactregistry.googleapis.com \
  iam.googleapis.com \
  iamcredentials.googleapis.com \
  sts.googleapis.com \
  cloudresourcemanager.googleapis.com \
  --project="${PROJECT_ID}"

if ! gcloud artifacts repositories describe "${AR_REPO}" --location="${REGION}" --project="${PROJECT_ID}" >/dev/null 2>&1; then
  gcloud artifacts repositories create "${AR_REPO}" \
    --repository-format=docker \
    --location="${REGION}" \
    --description="Homepage container images" \
    --project="${PROJECT_ID}"
else
  echo "Artifact Registry repo already exists: ${AR_REPO}"
fi

if ! gcloud iam service-accounts describe "${DEPLOYER_SA_EMAIL}" --project="${PROJECT_ID}" >/dev/null 2>&1; then
  gcloud iam service-accounts create "${DEPLOYER_SA}" \
    --display-name="GitHub Actions Cloud Run deployer" \
    --project="${PROJECT_ID}"
else
  echo "Service account already exists: ${DEPLOYER_SA_EMAIL}"
fi

if ! gcloud iam service-accounts describe "${DEPLOYER_SA_EMAIL}" --project="${PROJECT_ID}" >/dev/null 2>&1; then
  echo "ERROR: service account was not found after create attempt: ${DEPLOYER_SA_EMAIL}" >&2
  echo "Check IAM permissions and project ID, then rerun the script." >&2
  exit 1
fi

gcloud projects add-iam-policy-binding "${PROJECT_ID}" \
  --member="serviceAccount:${DEPLOYER_SA_EMAIL}" \
  --role="roles/run.admin" \
  --project="${PROJECT_ID}"

gcloud projects add-iam-policy-binding "${PROJECT_ID}" \
  --member="serviceAccount:${DEPLOYER_SA_EMAIL}" \
  --role="roles/artifactregistry.writer" \
  --project="${PROJECT_ID}"

gcloud projects add-iam-policy-binding "${PROJECT_ID}" \
  --member="serviceAccount:${DEPLOYER_SA_EMAIL}" \
  --role="roles/iam.serviceAccountUser" \
  --project="${PROJECT_ID}"

if ! gcloud iam workload-identity-pools describe "${POOL_ID}" --location=global --project="${PROJECT_ID}" >/dev/null 2>&1; then
  gcloud iam workload-identity-pools create "${POOL_ID}" \
    --location=global \
    --display-name="GitHub Actions" \
    --project="${PROJECT_ID}"
else
  echo "Workload Identity Pool already exists: ${POOL_ID}"
fi

if ! gcloud iam workload-identity-pools providers describe "${PROVIDER_ID}" \
  --location=global \
  --workload-identity-pool="${POOL_ID}" \
  --project="${PROJECT_ID}" >/dev/null 2>&1; then
  gcloud iam workload-identity-pools providers create-oidc "${PROVIDER_ID}" \
    --location=global \
    --workload-identity-pool="${POOL_ID}" \
    --display-name="GitHub provider for homepage" \
    --issuer-uri="https://token.actions.githubusercontent.com" \
    --attribute-mapping="google.subject=assertion.sub,attribute.actor=assertion.actor,attribute.repository=assertion.repository,attribute.repository_owner=assertion.repository_owner,attribute.aud=assertion.aud" \
    --attribute-condition="assertion.repository=='${GITHUB_REPO}'" \
    --project="${PROJECT_ID}"
else
  echo "Workload Identity Provider already exists: ${PROVIDER_ID}"
fi

gcloud iam service-accounts add-iam-policy-binding "${DEPLOYER_SA_EMAIL}" \
  --role="roles/iam.workloadIdentityUser" \
  --member="principalSet://iam.googleapis.com/projects/${PROJECT_NUMBER}/locations/global/workloadIdentityPools/${POOL_ID}/attribute.repository/${GITHUB_REPO}"

echo
printf 'Workflow value: GCP_WORKLOAD_IDENTITY_PROVIDER=%s\n' "projects/${PROJECT_NUMBER}/locations/global/workloadIdentityPools/${POOL_ID}/providers/${PROVIDER_ID}"
printf 'Workflow value: GCP_SERVICE_ACCOUNT_EMAIL=%s\n' "${DEPLOYER_SA_EMAIL}"
echo "Setup complete."
