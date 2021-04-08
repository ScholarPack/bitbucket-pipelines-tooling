# Build Pipeline Tooling
Tooling and scripts to assist building and running Bitbucket pipelines and GitHub Actions jobs.

## Commit Message Checker
This tool allows you to enforce commit message styles or rules. The initial use-case for this is to require a Jira project ticket number in the commit itself, which is incredibly useful when tracking down a problem, bugs, or other such issues. This tool checks every new commit on a branch, not just the latest one. 

### Prerequisites
- Git
- SHA-512 algorithm (probably called "perl-Digest-SHA")
- A modern Shell

### Usage

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

### Patterns

By default, the regex looks for Jira-style project ticket numbers with this regex `^(([A-Z]{2,}\d?-\d+)|hotfix)`. These example commit messages all pass:

- ABC-123 some commit
- AB-23 changed some code
- XYZ-2 deleted all the code

### Checksum - SHA-512
To prevent hijacking of a pipeline and to mitigate risks around pulling and running a bash script in a build job, this script automatically computes its own SHA-512 checksum. You must provide the expected checksum when running the script. You can manually compute the checksum like so:

```bash
shasum -a 512 tools/commit-message-checker.sh
```