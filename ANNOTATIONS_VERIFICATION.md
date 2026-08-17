# OCI Annotations Verification Guide

## Overview

The reusable Docker Bake workflow now automatically sets 4 standard OCI annotations on all images, derived from the GitHub Actions context. These annotations are applied at all manifest levels for multi-arch images, and at the image manifest level for single-arch images.

## Managed Annotations (Workflow Auto-Set)

The workflow **automatically computes and applies** these 4 OCI annotations to every image build:

1. **`org.opencontainers.image.created`** - Build timestamp in RFC 3339 UTC format (e.g., `2026-08-17T14:32:45Z`)
2. **`org.opencontainers.image.source`** - Repository URL (computed as `${{ github.server_url }}/${{ github.repository }}`)
3. **`org.opencontainers.image.version`** - Git reference name (e.g., `main`, `v1.0.0`, or `annotations`)
4. **`org.opencontainers.image.revision`** - Full git commit SHA (40-character hex)

These annotations **always override** any values defined in the calling repository's bake file.

## Custom Annotations (From Bake File)

The calling repository can define additional custom annotations in their bake file's `annotations` array. These are merged with the managed annotations and appear at all applicable levels.

### Example Bake File:
```hcl
target "my-image" {
  context = "."
  dockerfile = "Dockerfile"
  tags = ["myregistry/myimage:latest"]
  platforms = ["linux/amd64", "linux/arm64"]
  
  # Custom annotations - will be merged with managed ones
  annotations = [
    # These 4 will be OVERRIDDEN by workflow
    "org.opencontainers.image.created=2000-01-01T00:00:00Z",      # Overridden
    "org.opencontainers.image.source=https://wrong.url",          # Overridden
    "org.opencontainers.image.version=v0.0.0",                    # Overridden
    "org.opencontainers.image.revision=0000000000000000000000000000000000000000",  # Overridden
    
    # These custom ones will be preserved
    "custom.org.app=myapp",
    "custom.org.environment=production"
  ]
}
```

### Result:
Final image annotations will include:
- `org.opencontainers.image.created` = current build time (overridden)
- `org.opencontainers.image.source` = current repo URL (overridden)
- `org.opencontainers.image.version` = current git ref (overridden)
- `org.opencontainers.image.revision` = current git SHA (overridden)
- `custom.org.app` = `myapp` (preserved)
- `custom.org.environment` = `production` (preserved)

## Annotation Levels in OCI Image Manifests

### Multi-Architecture Images (3 Levels)

Multi-arch images created by `docker buildx imagetools create` have annotations at 3 levels:

1. **OCI Index (Manifest of Manifests)**
   - Top-level JSON object referenced by the tag
   - Contains all annotations
   - Type: `application/vnd.oci.image.index.v1+json`

2. **Descriptors**
   - Small JSON objects inside the index's `manifests` array
   - One descriptor per architecture
   - Each descriptor can have annotations
   - Includes `platform` information (arch, OS)

3. **Image Manifests**
   - Architecture-specific manifest JSON files
   - Each descriptor points to one manifest via digest
   - Contains annotations and references to config + layers
   - Type: `application/vnd.oci.image.manifest.v1+json`

### Single-Architecture Images (1 Level)

Single-arch images have annotations at only 1 level:

1. **Image Manifest**
   - The only manifest file
   - Contains all annotations
   - No index or descriptors (single platform)

## Test Scenarios in This Repository

The test workflow includes the following scenarios to verify annotations work correctly:

### Scenario 1: Multi-Arch with Managed Override
**Bake File**: `docker-bake.hcl` → `test-image` target
- **Platforms**: linux/amd64, linux/arm64 (multi-arch → 3 levels)
- **Annotations in file**:
  - Attempts to set all 4 managed annotations with wrong values
  - Includes 2 custom annotations
- **Expected Result**:
  - All 4 managed annotations show correct workflow-computed values at all 3 levels
  - 2 custom annotations preserved at all 3 levels
  - Total: 6 annotations (4 managed + 2 custom) at index, descriptors, and image manifest levels

### Scenario 2: Multi-Target Mixed-Arch
**Bake File**: `testdir/testsubdir/docker-bake-multi-target-mixed-arch.hcl`
- **test-image-1**: Multi-arch (linux/amd64, linux/arm64)
  - Managed override attempt + custom annotations
  - Result: 6 annotations at all 3 levels
- **test-image-2**: Single-arch (linux/amd64)
  - Custom annotations only (no managed override attempt)
  - Result: 2 custom annotations at image manifest level only
- **test-image-3**: Single-arch (linux/arm64)
  - Custom annotations only
  - Result: 2 custom annotations at image manifest level only

### Scenario 3: Multi-Target Single-Arch
**Bake File**: `docker-bake-multi-target-single-arch.hcl` (group: `somegroup`)
- **test-image-1**: Single-arch linux/amd64 with custom annotations
- **test-image-2**: Single-arch linux/arm64 with custom annotations
- **test-image-3**: Single-arch linux/amd64 with managed override attempt
- **Expected**: All single-arch, annotations at image manifest level only

### Scenario 4: Single-Target Single-Arch
**Bake File**: `docker-bake-single-target-single-arch.hcl`
- **test-image**: Single-arch linux/amd64
- **Annotations**: 4 managed override attempts + 2 custom
- **Expected**: 6 annotations (all managed correctly overridden, custom preserved) at image manifest level only

## Verification Procedures

### 1. Inspect Multi-Arch Image (All 3 Levels)

For a multi-arch image built from the workflow, verify annotations at all three levels.

#### Level 1: OCI Index (Top Level)
```bash
docker buildx imagetools inspect docker.io/kcandidate/gha-test:v10 --raw | jq '.annotations'
```

Expected output:
```json
{
  "org.opencontainers.image.created": "2026-08-17T...",
  "org.opencontainers.image.source": "https://github.com/k-candidate/gha-test",
  "org.opencontainers.image.version": "annotations",
  "org.opencontainers.image.revision": "abc123def456...",
  "custom.org.description": "Multi-arch test image with annotation override",
  "custom.org.scenario": "managed-annotation-override"
}
```

#### Level 2: Descriptors (Per-Architecture)
```bash
docker buildx imagetools inspect docker.io/kcandidate/gha-test:v10 --raw | \
  jq '.manifests[] | {platform: .platform, annotations: .annotations}'
```

Expected output (for each platform):
```json
{
  "platform": {
    "architecture": "amd64",
    "os": "linux"
  },
  "annotations": {
    "org.opencontainers.image.created": "2026-08-17T...",
    "org.opencontainers.image.source": "https://github.com/k-candidate/gha-test",
    "org.opencontainers.image.version": "annotations",
    "org.opencontainers.image.revision": "abc123def456...",
    "custom.org.description": "Multi-arch test image with annotation override",
    "custom.org.scenario": "managed-annotation-override"
  }
}
```

#### Level 3: Image Manifests (Platform-Specific)

Using `regctl` or `crane`:
```bash
regctl manifest get docker.io/kcandidate/gha-test:v10 \
  --platform=linux/amd64 --format raw-body | jq '.annotations'
```

Expected output: Same 6 annotations as index and descriptors.

### 2. Inspect Single-Arch Image (Image Manifest Level Only)

For a single-arch image:
```bash
docker buildx imagetools inspect docker.io/kcandidate/gha-test:singlearch-v10 --raw | jq '.annotations'
```

Expected output (image manifest annotations only):
```json
{
  "org.opencontainers.image.created": "2026-08-17T...",
  "org.opencontainers.image.source": "https://github.com/k-candidate/gha-test",
  "org.opencontainers.image.version": "annotations",
  "org.opencontainers.image.revision": "abc123def456...",
  "custom.app.environment": "test",
  "custom.app.scenario": "single-arch-managed-override"
}
```

## Expected Annotation Presence Table

| Test Scenario | Image | Platforms | Index Annotations | Descriptor Annotations | Image Manifest Annotations |
|---|---|---|---|---|---|
| 1 | test-image | amd64, arm64 | ✓ All 6 | ✓ All 6 | ✓ All 6 |
| 2a | test-image-1 | amd64, arm64 | ✓ All 6 | ✓ All 6 | ✓ All 6 |
| 2b | test-image-2 | amd64 | ✗ N/A | ✗ N/A | ✓ All 6 |
| 2c | test-image-3 | arm64 | ✗ N/A | ✗ N/A | ✓ All 2 custom |
| 3a | test-image-1 (somegroup) | amd64 | ✗ N/A | ✗ N/A | ✓ All 6 |
| 3b | test-image-2 (somegroup) | arm64 | ✗ N/A | ✗ N/A | ✓ All 6 |
| 3c | test-image-3 (somegroup) | amd64 | ✗ N/A | ✗ N/A | ✓ All 6 |
| 4 | test-image (singlearch) | amd64 | ✗ N/A | ✗ N/A | ✓ All 6 |

**Legend**:
- ✓ = annotations present
- ✗ = level does not exist (single-arch has no index/descriptors)
- All 6 = 4 managed + 2 custom
- All 2 custom = only custom annotations (no managed override in this scenario)

## Managed Annotation Override Verification Checklist

For scenarios with managed annotation override attempts (Scenarios 1, 2a, 3c, 4), verify:

- [ ] `org.opencontainers.image.created` shows **current build date** (not `2000-01-01` or `2000-01-01T00:00:00Z`)
- [ ] `org.opencontainers.image.source` shows **correct repository URL** (not `https://example.com/*` or `https://wrong.*` or `https://old.*`)
- [ ] `org.opencontainers.image.version` shows **correct git ref** (not `v0.0.0`)
- [ ] `org.opencontainers.image.revision` shows **correct git SHA** (not all zeros or all `a`s or all `f`s)

## Custom Annotation Preservation Checklist

For all scenarios, verify custom annotations are present:

- [ ] Custom annotations from bake file appear at all applicable levels
- [ ] Custom annotation keys and values are exactly as defined in bake file
- [ ] Custom annotations do not have any truncation or modification

## Troubleshooting

### Annotations Not Appearing

1. **Check workflow logs** - Look for "OCI Annotations (workflow-managed)" output in the prepare step
2. **Verify image was pushed** - Annotations only appear in registry images, not local Docker
3. **Inspect with `--raw` flag** - Required to see full manifest with annotations: `docker buildx imagetools inspect image:tag --raw`
4. **Confirm multi-arch image** - For single-arch, there's only 1 level

### Managed Annotations Not Overriding

1. **Check GitHub context** - Verify `github.sha` and `github.ref_name` are correct in workflow logs
2. **Verify bake file syntax** - Annotations must be in array format with `key=value` strings
3. **Check merge step** - For multi-arch, verify `docker buildx imagetools create` command includes `--annotation` flags

### Missing Custom Annotations

1. **Verify annotation syntax** in bake file - must be array of strings: `annotations = ["key=value", ...]`
2. **Check for typos** in annotation keys/values
3. **Confirm target is included** in the build group/targets

## Implementation Details

### Build Phase (docker buildx bake)
1. Workflow computes 4 managed annotations from GitHub context
2. Converts to `--set *.annotations=key=value` format
3. Passes to `docker/bake-action` via the `set` parameter
4. Buildx merges with annotations in bake file (workflow values take precedence)
5. Result: Annotations in each platform-specific image manifest

### Merge Phase (docker buildx imagetools)
1. For multi-arch images only (detected by multiple platforms)
2. Workflow converts annotations to `--annotation key=value` flags
3. Passes to `docker buildx imagetools create` command
4. Imagetools applies annotations to:
   - OCI Index (manifest of manifests) top level
   - Descriptors (per-platform entries in index)
   - Image manifests inherit from build phase

### Single-Arch Images
- No merge phase needed (only one platform)
- Annotations applied only at build time to image manifest

## See Also

- [OCI Image Spec - Annotations](https://github.com/opencontainers/image-spec/blob/main/annotations.md)
- [Docker Buildx Annotations Documentation](https://docs.docker.com/build/metadata/annotations/)
- [OCI Image Index Spec](https://github.com/opencontainers/image-spec/blob/main/image-index.md)
