variable "VERSION" {
  default = "1.0.0"
}

group "scan-clean" {
  targets = ["scan-clean"]
}

group "scan-vuln-image-fail-disabled" {
  targets = ["scan-vuln-image-fail-disabled"]
}

group "scan-vuln-image-with-ignore" {
  targets = ["scan-vuln-image-with-ignore"]
}

group "scan-vuln-image-fail-enabled" {
  targets = ["scan-vuln-image-fail-enabled"]
}

group "scan-nonexistent-ignorefile" {
  targets = ["scan-nonexistent-ignorefile"]
}

target "scan-clean" {
  context    = "."
  dockerfile = "Dockerfile.scan-clean"
  tags       = ["docker.io/kcandidate/gha-test-scan-clean:${VERSION}"]
  platforms  = ["linux/amd64", "linux/arm64"]
}

target "scan-vuln-image-fail-disabled" {
  context    = "."
  dockerfile = "Dockerfile.scan-vuln"
  tags       = ["docker.io/kcandidate/gha-test-scan-vuln-disabled:${VERSION}"]
  platforms  = ["linux/amd64", "linux/arm64"]
}

target "scan-vuln-image-with-ignore" {
  context    = "."
  dockerfile = "Dockerfile.scan-vuln"
  tags       = ["docker.io/kcandidate/gha-test-scan-vuln-ignored:${VERSION}"]
  platforms  = ["linux/amd64", "linux/arm64"]
}

target "scan-vuln-image-fail-enabled" {
  context    = "."
  dockerfile = "Dockerfile.scan-vuln"
  tags       = ["docker.io/kcandidate/gha-test-scan-vuln-fail:${VERSION}"]
  platforms  = ["linux/amd64", "linux/arm64"]
}

target "scan-nonexistent-ignorefile" {
  context    = "."
  dockerfile = "Dockerfile.scan-vuln"
  tags       = ["docker.io/kcandidate/gha-test-scan-missing-ignore:${VERSION}"]
  platforms  = ["linux/amd64", "linux/arm64"]
}
