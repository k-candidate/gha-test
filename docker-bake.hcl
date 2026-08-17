group "default" {
  targets = ["test-image", "test-image-with-secret"]
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

  # The reusable workflow turns bundle keys into BUILD_SECRET_<KEY>
  # environment variables. BuildKit exposes them only to RUN instructions
  # that explicitly mount the corresponding secrets.
  secret = [
    {
      id  = "TEST_BUILD_SECRET1"
      env = "TEST_BUILD_SECRET1"
    },
    {
      id  = "TEST_BUILD_SECRET2"
      env = "TEST_BUILD_SECRET2"
    }
  ]
}
