# Contribution Guide

Thank you for your interest in contributing to this project! 🎉

## 📋 How to Contribute

### Report a Bug 🐛

If you find a bug:

1. Check if it hasn't already been reported in Issues
2. Create a new Issue with:
   - Clear description of the problem
   - Steps to reproduce
   - Expected vs actual behavior
   - Packer version used
   - Relevant logs

### Propose an Improvement 💡

To propose a new feature:

1. Open an Issue describing the feature
2. Explain the use case and benefits
3. Wait for feedback before starting development

### Submit Changes 🔧

1. **Fork** the project
2. **Create a branch** for your feature
   \`\`\`bash
   git checkout -b feature/my-awesome-feature
   \`\`\`
3. **Make your changes** following project standards
4. **Test** your changes
   \`\`\`bash
   make validate
   make build  # If possible
   \`\`\`
5. **Commit** with clear messages
   \`\`\`bash
   git commit -m "feat: add feature X"
   \`\`\`
6. **Push** to your fork
   \`\`\`bash
   git push origin feature/my-awesome-feature
   \`\`\`
7. **Create a Pull Request**

## 📝 Code Standards

### Bash Scripts

- Always use \`#!/bin/bash\` as first line
- Use \`set -euo pipefail\` for robustness
- Comment important sections
- Indentation: 2 spaces
- UPPERCASE variables for constants
- Information messages with \`echo "==> Message"\`

**Example**:
\`\`\`bash
#!/bin/bash
# Script description

set -euo pipefail

CONST_VALUE="value"

echo "==> Starting operation..."
# Code here
echo "==> Operation completed"
\`\`\`

### HCL Files (Packer)

- Indentation: 2 spaces
- Use \`packer fmt\` before committing
- Comment important sections
- Sensitive variables marked with \`sensitive = true\`
- Descriptions for all variables

**Example**:
\`\`\`hcl
variable "my_variable" {
  type        = string
  description = "Clear variable description"
  default     = "value"
}
\`\`\`

### Documentation

- README.md in Markdown
- Clear sections with emojis for readability
- Code examples with syntax highlighting
- Keep CHANGELOG.md up to date

## 🧪 Tests

Before submitting:

1. **Syntax validation**
   \`\`\`bash
   make fmt
   make validate
   \`\`\`

2. **Test scripts** (if possible)
   \`\`\`bash
   # Test individually
   bash -n scripts/my-script.sh
   \`\`\`

3. **Complete build** (if infrastructure available)
   \`\`\`bash
   make build
   \`\`\`

## 📋 Commit Convention

Use [Conventional Commits](https://www.conventionalcommits.org/) format:

- \`feat:\` New feature
- \`fix:\` Bug fix
- \`docs:\` Documentation only
- \`style:\` Formatting, missing semicolons, etc.
- \`refactor:\` Code refactoring
- \`test:\` Adding tests
- \`chore:\` Maintenance (dependency updates, etc.)

**Examples**:
\`\`\`
feat: add support for Ubuntu 24.04
fix: correct SSH timeout
docs: update README with examples
refactor: modularize provisioning scripts
\`\`\`

## 🔍 Pull Request Checklist

- [ ] Code formatted (\`make fmt\`)
- [ ] Configuration validated (\`make validate\`)
- [ ] Scripts tested individually
- [ ] Documentation updated (README, CHANGELOG)
- [ ] Commits follow convention
- [ ] No secrets or credentials in code
- [ ] \`.gitignore\` updated if new sensitive files
- [ ] Scripts have executable permissions

## 🎯 Contribution Areas

Here are areas where your help is especially appreciated:

### High Priority
- Automated tests (CI/CD)
- Support for other distributions (Ubuntu, Rocky, etc.)
- Additional documentation
- Bug fixes

### Medium Priority
- Performance optimizations
- Additional provisioning scripts
- Multi-architecture support (arm64)
- Ansible post-provisioning integration

### Ideas Welcome
- Alternative templates (minimal, desktop, etc.)
- Support for other hypervisors
- Monitoring/observability tools
- Advanced automation

## 📞 Communication

- **Issues**: For bugs, questions, and discussions
- **Pull Requests**: To submit code
- **Discussions**: For general questions and help

## 🤝 Code of Conduct

### Our Commitments

By participating in this project, we commit to:

- Being welcoming and respectful
- Accepting constructive criticism
- Focusing on what's best for the community
- Showing empathy toward others

### Unacceptable Behavior

- Inappropriate language or images
- Insulting or degrading comments
- Public or private harassment
- Publishing private information without permission

## 📜 License

By contributing, you agree that your contributions will be licensed under the MIT License, the same as this project.

## 🙏 Acknowledgments

Thanks to all contributors who help improve this project!

---

**Questions?** Don't hesitate to open an Issue!
