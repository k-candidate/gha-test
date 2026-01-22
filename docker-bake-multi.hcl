group "default" {
  targets = ["test-image"]
}

target "test-image" {
  context    = "."
  dockerfile = "Dockerfile"
  tags = ["docker.io/kcandidate/gha-test:latest"]
  platforms = ["linux/amd64", "linux/arm64"]
  labels = {
    "org.opencontainers.image.title" = "gha-test multi-arch"
  }
}
