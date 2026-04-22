# Contributing to Copilot How To

Thank you for your interest in contributing to this project. This guide covers how to contribute effectively — whether you are fixing a typo, adding a worked example, or writing a new module.

## About This Project

Copilot How To is a tutorial repository teaching GitHub Copilot features through working examples, architecture diagrams, and real-world workflows. We provide:

- **Working examples** you can copy and run immediately
- **Mermaid diagrams** explaining how features work under the hood
- **Production-ready templates** for custom instructions, workflows, and extensions
- **Real-world scenarios** rather than toy examples
- **Progressive learning paths** from beginner to advanced

Every file in this repository is either documentation a learner will read or a runnable example they will copy. Quality over quantity.

## Types of Contributions

### 1. New Examples or Templates

Add examples for existing Copilot features (slash commands, extensions, GitHub Actions workflows, etc.):

- Copy-paste ready code with inline comments
- Clear explanation of what the example demonstrates
- The real-world use case it addresses
- Any prerequisites or limitations

### 2. Documentation Improvements

- Clarify confusing sections
- Fix typos and grammar
- Add missing information about a feature
- Improve or add Mermaid diagrams
- Update content when GitHub releases new Copilot features

### 3. New Module Guides

Create guides for GitHub Copilot features not yet covered:

- Step-by-step tutorials
- Architecture diagrams showing how the feature works
- Common patterns and anti-patterns
- Real-world workflows

### 4. Bug Reports

Report issues you find:

- Describe what you expected to happen
- Describe what actually happened
- Include steps to reproduce
- Add your IDE name and version, and OS

### 5. Feedback and Suggestions

Help improve the guide:

- Point out gaps in coverage
- Suggest better explanations
- Recommend new sections or reorganization

## Getting Started

### 1. Fork and Clone

```bash
git clone https://github.com/luongnv89/copilot-howto.git
cd copilot-howto
```

### 2. Create a Branch

Use a descriptive branch name:

```bash
git checkout -b add/feature-name
git checkout -b fix/issue-description
git checkout -b docs/improvement-area
```

### 3. Set Up Your Environment

Pre-commit hooks run the same checks as CI. All checks must pass before a PR will be accepted.

**Required dependencies:**

```bash
# Python tooling (uv is the package manager for this project)
pip install uv
uv venv
source .venv/bin/activate
uv pip install -r scripts/requirements-dev.txt

# Markdown linter (Node.js)
npm install -g markdownlint-cli

# Mermaid diagram validator (Node.js)
npm install -g @mermaid-js/mermaid-cli

# Install pre-commit and activate hooks
uv pip install pre-commit
pre-commit install
```

**Verify your setup:**

```bash
pre-commit run --all-files
```

The hooks that run on every commit are:

| Hook | What it checks |
|---|---|
| `markdown-lint` | Markdown formatting and structure |
| `cross-references` | Relative links, anchors, code fences |
| `mermaid-syntax` | All ` ```mermaid ` blocks parse correctly |
| `link-check` | External URLs are reachable |
| `build-epub` | EPUB generates without errors (on `.md` changes) |

## Directory Structure

```
├── 03-slash-commands/          # /explain, /fix, /tests, /doc, /new, /simplify
├── 05-custom-instructions/     # .github/copilot-instructions.md patterns
├── 14-extensions/              # Skillset and agent extension scaffolds
├── 04-chat-variables/          # @workspace, #file, #codebase, @terminal
├── 12-github-actions/          # GitHub Actions + Copilot workflows
├── 13-copilot-workspace/       # Copilot Workspace guide and examples
├── 06-cli/                     # gh copilot CLI reference
├── 01-inline-suggestions/      # Ghost text, NES, keyboard shortcuts
├── 02-ide-integration/         # VS Code, JetBrains, Neovim, Xcode setup
├── 15-enterprise/              # Policies, content exclusion, audit logs
├── scripts/                    # Build and utility scripts
└── README.md                   # Main guide
```

## How to Contribute Examples

### Adding a Slash Command Example

1. Create a `.md` file in `03-slash-commands/`.
2. Include:
   - What the command does and when to use it
   - Which context variables improve the result
   - A worked example with a realistic scenario
   - A before/after code block where applicable
3. Update `03-slash-commands/README.md` with a link to the new file.

### Adding a Custom Instructions Example

1. Add the example to `05-custom-instructions/`.
2. Include:
   - The instruction text itself (copy-paste ready)
   - An explanation of why each instruction is phrased the way it is
   - The effect it has on Copilot Chat responses
3. Update `05-custom-instructions/README.md`.

### Adding an Extension Scaffold

1. Create a directory under `14-extensions/` with a descriptive name.
2. Include:
   - `README.md` — setup steps and what the extension does
   - Source files with inline comments explaining each section
   - Any configuration files (YAML skill definitions, etc.)
3. Update `14-extensions/README.md`.

### Adding a GitHub Actions Workflow

1. Create a `.yml` file in `12-github-actions/`.
2. The workflow must:
   - Include an explicit `permissions:` block
   - Pin all action versions to specific tags or SHA hashes
   - Include a `concurrency:` block
   - Start with a comment explaining what it demonstrates
3. Update `12-github-actions/README.md`.

### Adding a Chat Variable Pattern

1. Create a `.md` file in `04-chat-variables/`.
2. Include:
   - The variable syntax
   - What gets injected and when
   - Token cost considerations
   - Example prompts showing the variable in context
3. Update `04-chat-variables/README.md`.

## Writing Guidelines

### Markdown Style

- Use H1 (`#`) only for the document title.
- Use H2 (`##`) for major sections within a document.
- Keep paragraphs to 3–5 sentences. Break longer explanations into bullet lists or numbered steps.
- Include a Table of Contents for any file with more than three H2 sections.
- Specify the language for all code blocks (` ```bash `, ` ```js `, ` ```yaml `).
- Add blank lines between sections for readability in raw view.

### Code Examples

- Make examples copy-paste ready. Test them before submitting.
- Start every example file (`.js`, `.yml`, `.sh`) with a comment explaining what it demonstrates and what it requires.
- Comment non-obvious logic inline.
- Show real-world scenarios. "A Node.js Express API that validates authentication tokens" is better than "a function that adds two numbers."
- Include both a minimal and a complete version where the feature has optional configuration.

### Documentation

- Start with the outcome, then explain the mechanism. Tell the reader what they will be able to do, then explain how it works.
- Write in second person: "you configure the extension" not "the user configures the extension."
- Use active voice: "Copilot sends the prompt" not "the prompt is sent by Copilot."
- Include prerequisites before instructions.
- Link to the official GitHub Copilot documentation at `https://docs.github.com/en/copilot` when you reference a specific feature.

### Mermaid Diagrams

- Always include a `title` directive in every diagram.
- Prefer `flowchart LR` for architecture and pipeline diagrams.
- Prefer `sequenceDiagram` for request/response flows.
- Keep node labels under 40 characters. Use surrounding prose for detail.
- Validate diagrams with `mmdc` before submitting (`npx @mermaid-js/mermaid-cli`).

### GitHub Actions YAML

- Always include an explicit `permissions:` block. Never rely on defaults.
- Pin action versions to specific tags (`actions/checkout@v4`) for official actions, SHA hashes for third-party actions.
- Include a `concurrency:` block to cancel in-progress runs.
- Add a `name:` field at the top of every workflow.

## Commit Guidelines

Follow conventional commit format:

```
type(scope): description

[optional body]
```

Types:

- `feat`: New example, template, or guide
- `fix`: Bug fix or correction to an existing example
- `docs`: Documentation improvements
- `refactor`: Reorganizing content without changing substance
- `style`: Formatting changes only
- `chore`: Build tooling, scripts, dependencies

Examples:

```
feat(extensions): Add agent extension scaffold with SSE streaming
docs(custom-instructions): Add section on token budget optimization
fix(actions): Pin workflow action versions to specific tags
feat(cli): Add gh copilot suggest scripting patterns
```

## Before Submitting

### Checklist

- [ ] All code examples are tested and working
- [ ] All Mermaid diagrams parse without errors (`pre-commit run mermaid-syntax`)
- [ ] Markdown passes the linter (`pre-commit run markdown-lint`)
- [ ] External links are live (`pre-commit run link-check`)
- [ ] Module README updated to reference the new file
- [ ] Root `INDEX.md` updated if a new file was added
- [ ] No API keys, tokens, or credentials in any file
- [ ] Commit message follows conventional commit format

### Local Testing

```bash
# Run all pre-commit checks (same checks as CI)
pre-commit run --all-files

# Run a single check
pre-commit run markdown-lint
pre-commit run mermaid-syntax

# Review your changes
git diff
```

## Pull Request Process

1. **Create a PR with a clear description**:
   - What does this add or fix?
   - Why is it needed?
   - Which module(s) does it affect?
   - Related issues (if any), using `Closes #123` to auto-close.

2. **Include relevant details**:
   - New example? Include the use case and what makes it useful.
   - Documentation improvement? Explain what was confusing and how the new version is clearer.
   - Bug fix? Show the before/after.

3. **Be patient with reviews**:
   - Maintainers may ask for changes to align with project conventions.
   - Iterate based on feedback.
   - Final decision rests with maintainers.

## Code Review Process

Reviewers will check:

- **Accuracy**: Does the example work as documented?
- **Quality**: Is it production-ready and copy-paste safe?
- **Consistency**: Does it follow project patterns (naming, structure, style)?
- **Clarity**: Will a motivated newcomer understand it?
- **Security**: Are there any credentials, unsafe patterns, or misleading security advice?

## Reporting Issues

### Bug Reports

Include:

- GitHub Copilot version and IDE name/version
- Operating system
- Steps to reproduce
- Expected behavior
- Actual behavior
- Screenshot or terminal output if applicable

### Feature Requests

Include:

- The GitHub Copilot feature or use case you want covered
- Why it would be useful to learners
- Any existing resources you found that could inform the guide

### Documentation Issues

Include:

- The file path of the confusing or incorrect content
- What is wrong or missing
- Your suggested improvement (even a rough draft is helpful)

## Project Policies

### Sensitive Information

- Never commit API keys, tokens, credentials, or real account identifiers.
- Use placeholder values in all examples: `YOUR_ORG`, `YOUR_TOKEN`, `your-extension-name`.
- If an example requires an `.env` file, include an `.env.example` with placeholder values and document all required variables.

### Code Quality

- Keep examples focused. One example per file is better than one file with ten examples.
- Avoid over-engineering. A clear 20-line example beats a clever 5-line one.
- Include comments for any logic that is not immediately obvious.

### Intellectual Property

- All contributions are licensed under the MIT License.
- Do not include content copied from other sources without attribution and permission.
- Provide attribution in a comment when adapting a published pattern or technique.

## Getting Help

- **Questions about contributing**: Open a GitHub Issue.
- **Questions about Copilot features**: Check the [official Copilot documentation](https://docs.github.com/en/copilot) first.
- **Development questions**: Review similar examples in the relevant module directory.
- **Code review help**: Tag maintainers in your PR.

## Recognition

Contributors are recognized in:

- The GitHub contributors page for this repository
- Commit history

## Security

When contributing examples and documentation:

- Never hardcode secrets, API keys, or tokens — use environment variables and document them.
- Warn about security implications where relevant. For example, if an example grants broad permissions, explain the risk and suggest least-privilege alternatives.
- Use secure defaults in all examples. If you show a GitHub Actions workflow, include a minimal `permissions:` block.
- For security issues in this repository, see [SECURITY.md](.github/SECURITY_REPORTING.md) for our vulnerability reporting process.

## Code of Conduct

We are committed to a welcoming and inclusive community. Please read [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md) for our full standards.

In brief:

- Be respectful and constructive in all interactions.
- Welcome feedback gracefully — reviewing is a gift.
- Help others learn and grow.
- Avoid harassment or discrimination of any kind.
- Report issues to maintainers.

All contributors are expected to uphold this code.

## License

By contributing to this project, you agree that your contributions will be licensed under the MIT License. See [LICENSE](LICENSE) for details.

## Questions?

- Check the [README](README.md) for a project overview.
- Review [LEARNING-ROADMAP.md](LEARNING-ROADMAP.md) for the suggested reading order.
- Browse [INDEX.md](INDEX.md) for a complete file listing.
- Open a GitHub Issue for anything not covered here.
