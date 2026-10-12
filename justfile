# Build the AARC guidelines as PDF. Run `just` for the list.
#
# Each guideline is a directory under guidelines/. Output goes to generated/,
# mirroring the source tree, so guidelines/aarc-g100/aarc-g100.qmd is written to
# generated/guidelines/aarc-g100/aarc-g100.pdf.
#
# The toolchain and the AARC extension come from aarc-publishing, through
# devenv. Run the recipes inside `devenv shell`, or as `devenv shell -- just ci`.

set shell := ["bash", "-euo", "pipefail", "-c"]

# List the recipes
default:
    @just --list --unsorted

# Render every guideline
build: _prepare
    quarto render

# Render one guideline. Give its directory name, as in `just doc aarc-g100`
doc name: _prepare
    quarto render guidelines/{{ name }}/{{ name }}.qmd

# Render every guideline and fail on any warning or unresolved reference (for CI)
ci: _prepare
    #!/usr/bin/env bash
    set -uo pipefail
    # A reproducible build: the PDF carries the time of the last commit.
    # A repository with no commit yet has no time to give, and the PDF takes
    # the time of the build.
    if epoch=$(git log -1 --format=%ct 2>/dev/null) && [ -n "$epoch" ]; then
        export SOURCE_DATE_EPOCH=$epoch
    fi
    output=$(quarto render 2>&1)
    status=$?
    echo "$output"
    if [ $status -ne 0 ]; then
        echo "ci: quarto render failed" >&2
        exit $status
    fi
    if grep -qiE 'unable to resolve|WARN|ERROR|\?@' <<< "$output"; then
        echo "ci: unresolved references or warnings above" >&2
        exit 1
    fi
    aarc-check 'guidelines/*/*.qmd'

# Start a guideline from the starter in aarc-publishing, as in `just new aarc-g101`
new name:
    #!/usr/bin/env bash
    set -euo pipefail
    target=guidelines/{{ name }}
    if [ -e "$target" ]; then echo "new: $target exists" >&2; exit 1; fi
    cp -r "$AARC_STARTER" "$target"
    chmod -R u+w "$target"
    mv "$target/aarc-gxxx-example.qmd" "$target/{{ name }}.qmd"
    echo "new: created $target/{{ name }}.qmd"

# Format the guideline sources. The settings are in .prettierrc.yaml
fmt:
    prettier --write 'guidelines/**/*.qmd' '*.md'

# Remove the build output, the installed extension and the Quarto cache
clean:
    rm -rf .quarto generated _extensions

# Install the extension of the pinned aarc-publishing, so the build always uses
# the version devenv.lock names. Quarto copies the typst packages it bundles
# into .quarto/ read-only under Nix, and the next render cannot overwrite them,
# so the copies are made writable first.
_prepare:
    @aarc-install
    @if [ -d .quarto ]; then chmod -R u+w .quarto; fi
