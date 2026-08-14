group "default" {
  targets = ["test-image"]
}

# Kept separate from the default group so existing builds do not require a
# build-time secret.
group "secret-test" {
  targets = ["test-image-with-secret"]
}

variable "BUILD_SECRETS_DIR" {
  default = ""
}

target "test-image" {
  # Use the local Dockerfile in this repo
  context    = "."
  dockerfile = "Dockerfile"

  # Image name/tag
  tags = [
    "docker.io/kcandidate/gha-test:v10",
    "docker.io/kcandidate/gha-test:latest"
  ]

  # Single platform for now
  platforms = [
    "linux/amd64",
    "linux/arm64"
  ]

  # Example labels just to exercise metadata
  labels = {
    "org.opencontainers.image.title"       = "gha-test docker-bake image"
    "org.opencontainers.image.description" = "Simple test image for reusable docker-bake workflow"
  }

  # Example build arg to show the plumbing works (optional)
  args = {
    "EXAMPLE_ARG" = "example-value"
  }
}

target "test-image-with-secret" {
  context    = "."
  dockerfile = "Dockerfile.secret"

  tags = ["docker.io/kcandidate/gha-test:build-secret-test"]
  platforms = ["linux/amd64"]

  # The reusable workflow writes the JSON bundle's values to this temporary
  # directory. BuildKit exposes them only to RUN instructions that explicitly
  # mount the corresponding secrets.
  secret = [
    {
      id  = "test_build_secret_1"
      src = "${BUILD_SECRETS_DIR}/test_build_secret_1"
    },
    {
      id  = "test_build_secret_2"
      src = "${BUILD_SECRETS_DIR}/test_build_secret_2"
    }
  ]
}
