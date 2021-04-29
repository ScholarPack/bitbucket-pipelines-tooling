# Build Pipeline Tooling

Tooling and scripts to assist building and running Bitbucket pipelines and
GitHub Actions jobs.

## Commit Message Checker

This tool allows you to enforce commit message styles or rules. The initial
use-case for this is to require a Jira project ticket number in the commit
itself, which is incredibly useful when tracking down a problem, bugs, or
other such issues. This tool checks every new commit on a branch, not just
the latest one.

### 📝 Prerequisites

- Git
- A Shell

### 💻 Usage

To use this tool, pass in a source and destination branch:

```bash
./tools/commit-message-checker.sh <source_branch_name> <destination_branch_name>
```

* `<source_branch_name>` must be the branch your changes live on.
* `<destination_branch_name>` must be the branch your changes are going to.

A completed command may look something like this:

```bash
./tools/commit-message-checker.sh develop main
```

If running locally you may need to alter the file permissions first:

```bash
chmod +x tools/commit-message-checker.sh
```

### 🔢 Patterns

By default, the regex looks for Jira-style project ticket numbers with this
regex `^([A-Z]{2,}\d?-\d+|Merge|Revert|[Hh]otfix)`. These example commit
messages all pass:

- ABC-123 some commit
- AB-23 changed some code
- XYZ-2 deleted all the code
- Hotfix: fixed a problem
- Merge pull request #3 from ScholarPack/hotfix-update-commit-checker-regex
- Revert "Some commit (pull request #156)"

### 🧪 Bitbucket Pipelines config

Here's a sample Bitbucket pipeline build. This pipeline only runs on pull
request, and uses the Bitbucket variables to pass in the source and
destination branches. Based on RHEL 7, you may need to modify the install
steps to match your base image.

```dockerfile
image: richxsl/rhel7

clone:
  depth: full

pipelines:
  pull-requests:
    '**':
    - step:
        name: Commit message check
        script:
          - microdnf install git
          - microdnf install perl-Digest-SHA
          - git checkout $BITBUCKET_PR_DESTINATION_BRANCH
          - curl -s https://raw.githubusercontent.com/ScholarPack/build-pipeline-tooling/<latest-commit-hash>/tools/commit-message-checker.sh --output commit-message-checker.sh
          - chmod 744 commit-message-checker.sh
          - ./commit-message-checker.sh $BITBUCKET_BRANCH $BITBUCKET_PR_DESTINATION_BRANCH
```
