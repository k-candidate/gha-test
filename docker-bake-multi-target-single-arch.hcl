group "somegroup" {
  targets = ["test-image-1", "test-image-2", "test-image-3"]
}

target "test-image-1" {
  context    = "."
  dockerfile = "Dockerfile"
  tags = ["docker.io/kcandidate/gha-test:multi-target-single-arch-v10"]
  platforms = ["linux/amd64"]
  labels = {
    "org.opencontainers.image.title" = "gha-test multi-target single-arch target 1"
  }
  # Single-arch with custom annotations
  annotations = [
    "custom.test.target=test-image-1",
    "custom.test.arch=amd64"
  ]
}

target "test-image-2" {
  context    = "."
  dockerfile = "Dockerfile"
  tags = ["docker.io/kcandidate/test-image-2:multi-target-single-arch-v10"]
  platforms = ["linux/arm64"]
  labels = {
    "org.opencontainers.image.title" = "gha-test multi-target single-arch target 2"
  }
  # Single-arch with custom annotations
  annotations = [
    "custom.test.target=test-image-2",
    "custom.test.arch=arm64"
  ]
}

target "test-image-3" {
  context    = "."
  dockerfile = "Dockerfile"
  tags = ["docker.io/kcandidate/test-image-3:multi-target-single-arch-v10"]
  platforms = ["linux/amd64"]
  labels = {
    "org.opencontainers.image.title" = "gha-test multi-target single-arch target 3"
  }
  # Single-arch with custom annotations and managed override attempt
  annotations = [
    "org.opencontainers.image.created=2000-01-01T00:00:00Z",
    "org.opencontainers.image.source=https://wrong.example.com",
    "org.opencontainers.image.version=v0.0.0",
    "org.opencontainers.image.revision=ffffffffffffffffffffffffffffffffffffffff",
    "custom.test.target=test-image-3",
    "custom.test.arch=amd64"
  ]
}