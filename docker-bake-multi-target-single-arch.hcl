group "somegroup" {
  targets = ["test-image-1", "test-image-2", "test-image-3"]
}

target "test-image-1" {
  context    = "."
  dockerfile = "Dockerfile"
  tags = ["docker.io/kcandidate/gha-test:multi-target-single-arch-v10"]
  platforms = ["linux/amd64"]
  labels = {
    "org.opencontainers.image.title" = "gha-test multi-arch"
  }
}

target "test-image-2" {
  context    = "."
  dockerfile = "Dockerfile"
  tags = ["docker.io/kcandidate/test-image-2:multi-target-single-arch-v10"]
  platforms = ["linux/arm64"]
  labels = {
    "org.opencontainers.image.title" = "gha-test multi-arch"
  }
}

target "test-image-3" {
  context    = "."
  dockerfile = "Dockerfile"
  tags = ["docker.io/kcandidate/test-image-3:multi-target-single-arch-v10"]
  platforms = ["linux/amd64"]
  labels = {
    "org.opencontainers.image.title" = "gha-test multi-arch"
  }
}