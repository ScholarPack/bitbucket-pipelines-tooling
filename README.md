# Build Pipeline Tooling
Tooling and scripts to assist building and running Bitbucket pipelines and GitHub Actions jobs.

## Commit Message Checker
This tool allows you to enforce commit message styles or rules. The initial use-case for this is to require a Jira project ticket number in the commit itself, which is incredibly useful when tracking down a problem, bugs, or other such issues. This tool checks every new commit on a branch, not just the latest one. 

### 📝 Prerequisites
- Git
- SHA-512 algorithm (probably called "perl-Digest-SHA")
- A modern Shell

### 💻 Usage

To use this tool, pass in a source, and destination branch, along with the expected checksum:

```bash
./tools/commit-message-checker.sh <source_branch_name> <destination_branch_name> <expected checksum>
```

* **<source_branch_name>** must be the branch your changes live on.
* **<destination_branch_name>** must be the branch your changes are going to.
* **<expected checksum>** the checksum for your version of the script - you can find this on the [releases](https://github.com/ScholarPack/build-pipeline-tooling/releases) page.

A completed command may look something like this:

```bash
./tools/commit-message-checker.sh develop main c7ccf437d6fbd342fcd9ca9088eba9b574f31f149312bb080f2cc8da0765224fd4595fac59e0a35a2f3cb0f5bd786c1b91ef74b25c4793b73b47cb026f234c61
```

If running locally you may need to alter the file permissions first:

```bash
chmod 744 tools/commit-message-checker.sh
```

### 🔢 Patterns

By default, the regex looks for Jira-style project ticket numbers with this regex `^(([A-Z]{2,}\d?-\d+)|hotfix)`. These example commit messages all pass:

- ABC-123 some commit
- AB-23 changed some code
- XYZ-2 deleted all the code

### 🧮 Checksum - SHA-512
To prevent hijacking of a pipeline and to mitigate risks around pulling and running a bash script in a build job, this script automatically computes its own SHA-512 checksum. You must provide the expected checksum when running the script. You can manually compute the checksum like so:

```bash
shasum -a 512 tools/commit-message-checker.sh
```

### 🧪 Bitbucket Pipelines config
Here's a sample Bitbucket pipeline build. This pipeline only runs on pull request, and uses the Bitbucket variables to pass in the source and destination branches. Based on RHEL 7, you may need to modify the install steps to match your base image.

---
**NOTE**

Make sure you swap out the commands below for the real version and checksum found on the [releases](https://github.com/ScholarPack/build-pipeline-tooling/releases) page. Pointing directly to the head of `main` will lead to checksum issues whenever the codebase changes!

---

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
          - curl -s https://raw.githubusercontent.com/ScholarPack/build-pipeline-tooling/main/tools/commit-message-checker.sh --output commit-message-checker.sh
          - chmod 744 commit-message-checker.sh
          - ./commit-message-checker.sh $BITBUCKET_BRANCH $BITBUCKET_PR_DESTINATION_BRANCH cc12ed2a74a20df4327aa65d6cc9f7c51553bdf42d74a95e331616632e2e6279de0231c0aad77511f20e4fb4c638841361122a40e34b7abfeb7db44d4189b070
```