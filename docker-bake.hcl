group "default" {
  targets = ["test-image"]
}

target "test-image" {
  # Use the local Dockerfile in this repo
  context    = "."
  dockerfile = "Dockerfile"

  # Image name/tag
  tags = [
    "docker.io/kcandidate/gha-test:v69",
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
