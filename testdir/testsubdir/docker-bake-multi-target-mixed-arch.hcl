group "default" {
  targets = ["test-image-1", "test-image-2", "test-image-3"]
}

variable "VERSION" {
  default = "unknown"
}

target "test-image-1" {
  # Use the local Dockerfile in this repo
  context    = "."
  dockerfile = "Dockerfile"

  # Image name/tag
  tags = [
    "docker.io/kcandidate/gha-test:subdir-${VERSION}",
    "docker.io/kcandidate/gha-test:latest-subdir-v10"
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

  # Multi-arch with managed annotation override attempt
  annotations = [
    "org.opencontainers.image.created=2000-01-01T00:00:00Z",
    "org.opencontainers.image.source=https://example.com/ignored",
    "org.opencontainers.image.version=v0.0.0-ignored",
    "org.opencontainers.image.revision=0000000000000000000000000000000000000000",
    "custom.multi.target=test-image-1",
    "custom.multi.purpose=multi-arch-testing"
  ]
}

target "test-image-2" {
  context = "testdir/testsubdir"
  dockerfile = "Dockerfile2"
  tags = [
    "docker.io/kcandidate/test-image-2:v10"
  ]
  platforms = [
    "linux/amd64"
  ]
  
  labels = {
    "org.opencontainers.image.title" = "test-image-2 single-arch"
  }
  
  # Single-arch with custom annotations only
  annotations = [
    "custom.image-2.purpose=single-platform",
    "custom.image-2.build=dockerfile2"
  ]
}

target "test-image-3" {
  context = "testdir/testsubdir"
  dockerfile = "Dockerfile3"
  tags = [
    "docker.io/kcandidate/test-image-3:v10"
  ]
  platforms = [
    "linux/arm64"
  ]
  
  labels = {
    "org.opencontainers.image.title" = "test-image-3 single-arch"
  }
  
  # Single-arch with custom annotations only
  annotations = [
    "custom.image-3.purpose=single-platform-arm",
    "custom.image-3.build=dockerfile3"
  ]
}