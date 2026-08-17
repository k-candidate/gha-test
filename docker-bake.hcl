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

  # Multi-platform
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

  # Custom annotations - workflow will override the 4 managed ones
  annotations = [
    "org.opencontainers.image.created=2000-01-01T00:00:00Z",
    "org.opencontainers.image.source=https://example.com/old",
    "org.opencontainers.image.version=v0.0.0",
    "org.opencontainers.image.revision=0000000000000000000000000000000000000000",
    "custom.org.description=Multi-arch test image with annotation override",
    "custom.org.scenario=managed-annotation-override"
  ]
}

target "test-image-with-secret" {
  context    = "."
  dockerfile = "Dockerfile.secret"

  tags = ["docker.io/kcandidate/gha-test:build-secret-test"]
  platforms = ["linux/amd64"]

  # These secret names must match the GitHub Actions secret names and the
  # Dockerfile secret mount IDs.
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

  # Single-arch target with custom annotations
  annotations = [
    "custom.test.purpose=secret-handling",
    "custom.test.stage=build"
  ]
}
