group "default" {
  targets = ["test-image"]
}

target "test-image" {
  context    = "."
  dockerfile = "Dockerfile"
  tags = ["docker.io/kcandidate/gha-test:singlearch-v10"]
  platforms = ["linux/amd64"]
  labels = {
    "org.opencontainers.image.title" = "gha-test single-arch"
  }
  args = {
    "EXAMPLE_ARG" = "example-value"
  }
  
  # Single-arch with managed annotation override attempt and custom annotations
  annotations = [
    "org.opencontainers.image.created=2000-01-01T00:00:00Z",
    "org.opencontainers.image.source=https://old.example.com",
    "org.opencontainers.image.version=v0.0.0",
    "org.opencontainers.image.revision=aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "custom.app.environment=test",
    "custom.app.scenario=single-arch-managed-override"
  ]
}
