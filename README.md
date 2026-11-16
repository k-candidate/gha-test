# gha-test
repo for testing gha

The `Test Docker Bake` workflow exercises the reusable build-and-scan workflow.
Use the `scan` test scope for clean, vulnerable, ignored, expected-failure, and
missing-ignore-file scenarios; `all` also runs the existing Bake fixtures.
