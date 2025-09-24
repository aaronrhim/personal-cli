#!/usr/bin/env bash
set -euo pipefail

IMAGE_NAME=${IMAGE_NAME:-personal-cli:latest}
CONTAINER_NAME=${CONTAINER_NAME:-personal-cli}
WORK_DIR=""
NO_RUN=0

usage() {
  cat <<EOF
Usage: $0 [--work_dir <path>] [--image <name>] [--name <container>] [--no-run]

Options:
  --work_dir <path>   Host path to mount as /workspace. Defaults to ./workspace in repo.
  --image <name>      Docker image name:tag. Defaults to personal-cli:latest
  --name <container>  Container name. Defaults to personal-cli
  --no-run            Build image only; do not create/run container
  -h, --help          Show this help
EOF
}

# Parse args
while [[ ${1:-} ]]; do
  case "$1" in
    --work_dir)
      [[ ${2:-} ]] || { echo "--work_dir requires a value" >&2; exit 1; }
      WORK_DIR="$2"; shift 2 ;;
    --image)
      [[ ${2:-} ]] || { echo "--image requires a value" >&2; exit 1; }
      IMAGE_NAME="$2"; shift 2 ;;
    --name)
      [[ ${2:-} ]] || { echo "--name requires a value" >&2; exit 1; }
      CONTAINER_NAME="$2"; shift 2 ;;
    --no-run)
      NO_RUN=1; shift ;;
    -h|--help)
      usage; exit 0 ;;
    *)
      echo "Unknown argument: $1" >&2; usage; exit 1 ;;
  esac
done

# Set default work dir if not provided
if [[ -z "$WORK_DIR" ]]; then
  WORK_DIR="$(pwd)/workspace"
fi
mkdir -p "$WORK_DIR"

# Ensure prerequisites
command -v docker >/dev/null 2>&1 || { echo "docker not found in PATH" >&2; exit 1; }
command -v npm >/dev/null 2>&1 || { echo "npm not found in PATH" >&2; exit 1; }

echo "Packing npm tarball (dist/personal.tgz)..."
npm pack >/dev/null

echo "Building image: $IMAGE_NAME"
docker build -t "$IMAGE_NAME" .

if [[ "$NO_RUN" -eq 1 ]]; then
  echo "Image built: $IMAGE_NAME (skipping run)"
  exit 0
fi

# Prompt for OpenAI API key if not present in env
OPENAI_API_KEY_VALUE=${OPENAI_API_KEY:-}
if [[ -z "$OPENAI_API_KEY_VALUE" ]]; then
  read -r -s -p "Enter your OpenAI API key: " OPENAI_API_KEY_VALUE
  echo
fi
if [[ -z "$OPENAI_API_KEY_VALUE" ]]; then
  echo "An OpenAI API key is required to run the container." >&2
  exit 1
fi

echo "Creating container: $CONTAINER_NAME"
set -x
docker run -it \
  --name "$CONTAINER_NAME" \
  -e OPENAI_API_KEY="$OPENAI_API_KEY_VALUE" \
  -v "$WORK_DIR":/workspace \
  -w /workspace \
  "$IMAGE_NAME" zsh
set +x

echo "Container exited. To re-enter: docker start -ai $CONTAINER_NAME"
