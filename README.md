# AARC guidelines

This repository contains the sources of the AARC guidelines. The toolchain makes
a PDF of each guideline in the AARC design.

| Path                          | Contents                                                       |
| ----------------------------- | -------------------------------------------------------------- |
| `guidelines/<code>/`          | One guideline: the `.qmd` file, its `figures/` and its sources |
| `_quarto.yml`                 | The Quarto project, which selects the format `aarc-typst`      |
| `justfile`                    | The commands that make and examine the PDFs                    |
| `devenv.yaml`                 | The input that gets the toolchain from aarc-publishing         |
| `devenv.lock`                 | The commit of aarc-publishing that the toolchain uses          |
| `.prettierrc.yaml`            | The instructions for prettier, for `just fmt` and for editors  |
| `.github/workflows/build.yml` | The GitHub workflow that makes and examines the PDFs           |
| `generated/`                  | The PDFs. Git does not keep these files                        |

The design, the toolchain and the checks are in the
[aarc-publishing](https://github.com/AARC-Community/aarc-publishing) repository.
`devenv.yaml` gets them from GitHub, and `devenv.lock` records the commit that
this repository uses.

## Make the PDFs

Start the shell of the toolchain with `devenv shell`. To do one command without
the shell, use `devenv shell -- just build`.

    just build          # all guidelines
    just doc aarc-g100  # one guideline
    just ci             # all guidelines, with the checks of the workflow
    just new aarc-g101  # a new guideline, copied from the starter
    just fmt            # the sources, formatted with prettier

The PDF of `guidelines/aarc-g100/aarc-g100.qmd` goes into
`generated/guidelines/aarc-g100/aarc-g100.pdf`.

Before `just` makes a PDF, it installs the AARC extension into
`_extensions/aarc/`. The extension comes from the commit of aarc-publishing that
`devenv.lock` records. Git does not keep `_extensions/`.

## Use a new version of aarc-publishing

To use the last commit of aarc-publishing, do these steps:

1. Do the command `devenv update aarc-publishing`.
2. Make the PDFs with `just ci`, and examine them.
3. Commit `devenv.lock`.

In a pull request, the workflow makes the PDFs with the new version. The
reviewers can then compare these PDFs with the PDFs of `main`.

## The workflow on GitHub

The workflow `.github/workflows/build.yml` makes and examines the PDFs on
GitHub. The workflow starts if one of these conditions occurs:

- You push a commit to `main`.
- You open a pull request, or you push a commit to the branch of a pull request.
- You select **Run workflow** in the **Actions** tab.

A push to a different branch does not start the workflow. To get the PDFs of a
branch, open a pull request.

The workflow does the command `devenv shell -- just ci`. This command makes all
the PDFs, and it stops with an error if one of these conditions occurs:

- Quarto or typst stops with an error, or gives a warning.
- Quarto cannot find the item that a cross-reference or a citation identifies.
- A guideline does not have a field of the cover, or has an incorrect ORCID iD.
- A source contains a grid table, or a `:::` fence without an empty line before
  and after it. Prettier changes these into paragraphs.
- A font is not in the PDF.

The workflow keeps the PDFs as the artifact `guidelines` of the workflow run.
GitHub erases an artifact after 90 days. Each PDF has the time of the last
commit, thus the same sources give the same PDF.

Before the workflow makes the PDFs, it makes sure that `devenv.lock` records
aarc-publishing from GitHub. If `devenv.lock` records a local path, the workflow
stops with an error.

## Use a local copy of aarc-publishing

To change aarc-publishing and a guideline together, use a local copy of
aarc-publishing. Put the copy in the same folder as this repository, and put
these lines in `devenv.local.yaml`:

    inputs:
      aarc-publishing:
        url: path:../aarc-publishing
        flake: false

Git does not keep `devenv.local.yaml`. When this file is available, devenv uses
the local copy, and records its path in `devenv.lock`. The workflow does not
accept that path. Thus, before you commit `devenv.lock`, do these steps:

1. Change the name of `devenv.local.yaml` to `devenv.local.yaml.off`.
2. Do the command `devenv update aarc-publishing`.

The devenv tool keeps a copy of the files that it reads from a local path. After
a change to aarc-publishing, start the shell one time with
`devenv --refresh-eval-cache shell`.

## Write a guideline

The instructions for a guideline are in the README of aarc-publishing.
