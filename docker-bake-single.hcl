group "default" {
  targets = ["test-image"]
}

target "test-image" {
  context    = "."
  dockerfile = "Dockerfile"
  tags = ["docker.io/kcandidate/gha-test:singlearch-v1"]
  platforms = ["linux/amd64"]
  labels = {
    "org.opencontainers.image.title" = "gha-test single-arch"
  }
}
