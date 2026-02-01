group "default" {
  targets = ["test-image-1", "test-image-2", "test-image-3"]
}

target "test-image-1" {
  # Use the local Dockerfile in this repo
  context    = "."
  dockerfile = "Dockerfile"

  # Image name/tag
  tags = [
    "docker.io/kcandidate/gha-test:subdir-v9",
    "docker.io/kcandidate/gha-test:latest-subdir-v9"
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

target "test-image-2" {
  context = "testdir/testsubdir"
  dockerfile = "Dockerfile2"
  tags = [
    "docker.io/kcandidate/test-image-2:v9"
  ]
  platforms = [
    "linux/amd64"
  ]
}

target "test-image-3" {
  context = "testdir/testsubdir"
  dockerfile = "Dockerfile3"
  tags = [
    "docker.io/kcandidate/test-image-3:v9"
  ]
  platforms = [
    "linux/arm64"
  ]
}