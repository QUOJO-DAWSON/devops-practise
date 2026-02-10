# Contributing to DevOps Practice Repository

First off, thank you for considering contributing to this project! 🎉

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [How Can I Contribute?](#how-can-i-contribute)
- [Development Setup](#development-setup)
- [Coding Standards](#coding-standards)
- [Commit Guidelines](#commit-guidelines)
- [Pull Request Process](#pull-request-process)
- [Testing Guidelines](#testing-guidelines)

## Code of Conduct

This project adheres to a code of conduct. By participating, you are expected to uphold this code. Please be respectful, inclusive, and professional in all interactions.

### Our Standards

- Use welcoming and inclusive language
- Be respectful of differing viewpoints and experiences
- Gracefully accept constructive criticism
- Focus on what is best for the community
- Show empathy towards other community members

## How Can I Contribute?

### Reporting Bugs

Before creating bug reports, please check existing issues. When creating a bug report, include:

- **Clear title and description**
- **Steps to reproduce** the problem
- **Expected behavior**
- **Actual behavior**
- **Screenshots** (if applicable)
- **Environment details** (OS, versions, etc.)

**Bug Report Template:**
```markdown
**Description:**
A clear description of the bug.

**To Reproduce:**
1. Go to '...'
2. Run command '...'
3. See error

**Expected behavior:**
What you expected to happen.

**Environment:**
- OS: [e.g., Ubuntu 22.04]
- Tool versions: [e.g., Docker 20.10, Kubernetes 1.27]
```

### Suggesting Enhancements

Enhancement suggestions are welcome! Please provide:

- **Clear use case**: Why is this enhancement needed?
- **Detailed description**: How should it work?
- **Examples**: Show similar implementations if possible
- **Impact**: Who benefits from this enhancement?

### Contributing Code

1. **Fork the repository**
2. **Create a feature branch** from `develop`
   ```bash
   git checkout -b feature/your-feature-name
   ```
3. **Make your changes**
4. **Test thoroughly**
5. **Commit with clear messages**
6. **Push to your fork**
7. **Submit a Pull Request**

## Development Setup

### Prerequisites

Install required tools:

```bash
# Check prerequisites
./scripts/setup/check-prerequisites.sh

# Install missing tools
./scripts/setup/install-tools.sh
```

### Local Development Environment

```bash
# Clone your fork
git clone https://github.com/YOUR_USERNAME/devops-practise.git
cd devops-practise

# Add upstream remote
git remote add upstream https://github.com/QUOJO-DAWSON/devops-practise.git

# Set up pre-commit hooks
./scripts/setup/install-hooks.sh

# Set up local environment
cp .env.example .env
./scripts/setup/setup-local-env.sh
```

## Coding Standards

### Shell Scripts

- **Use shellcheck** for linting
- **Include shebang**: `#!/bin/bash`
- **Use set flags**: `set -euo pipefail`
- **Add error handling**
- **Document functions**
- **Use meaningful variable names**

**Example:**
```bash
#!/bin/bash
set -euo pipefail

# Description: Deploy application to Kubernetes
# Usage: ./deploy.sh <environment> <app-name>

readonly ENVIRONMENT="${1:?Error: Environment required}"
readonly APP_NAME="${2:?Error: App name required}"

function deploy_app() {
    local env="$1"
    local app="$2"
    
    echo "Deploying ${app} to ${env}..."
    kubectl apply -f "k8s/${env}/${app}.yaml"
}

deploy_app "${ENVIRONMENT}" "${APP_NAME}"
```

### Python Scripts

- Follow **PEP 8** style guide
- Use **type hints**
- Add **docstrings**
- Include **error handling**
- Write **unit tests**

### YAML/JSON

- **Consistent indentation** (2 spaces for YAML)
- **Validate syntax** before committing
- **Use comments** to explain complex configurations
- **Organize logically**

### Terraform

- Use **consistent naming conventions**
- **Organize by modules**
- **Add variable descriptions**
- **Include outputs**
- **Document complex logic**
- **Use terraform fmt**

### Kubernetes Manifests

- Use **kustomize** for environment variations
- **Set resource limits**
- **Add labels and annotations**
- **Include health checks**
- **Document custom resources**

## Commit Guidelines

### Commit Message Format

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Types

- **feat**: New feature
- **fix**: Bug fix
- **docs**: Documentation changes
- **style**: Code style changes (formatting)
- **refactor**: Code refactoring
- **test**: Adding or updating tests
- **chore**: Maintenance tasks
- **perf**: Performance improvements
- **ci**: CI/CD changes

### Examples

```
feat(deployment): add blue-green deployment strategy

Implement blue-green deployment for zero-downtime releases.
Includes automated rollback on health check failure.

Closes #123
```

```
fix(monitoring): correct Prometheus alert threshold

Update CPU alert threshold from 70% to 85% to reduce false positives.
Adjust alert duration to 5 minutes.

Resolves #456
```

### Commit Best Practices

- Write clear, concise commit messages
- Use present tense ("Add feature" not "Added feature")
- Keep subject line under 50 characters
- Separate subject from body with blank line
- Reference issues and pull requests
- Break large changes into smaller commits

## Pull Request Process

### Before Submitting

- [ ] Update documentation if needed
- [ ] Add tests for new features
- [ ] Ensure all tests pass
- [ ] Run linters and formatters
- [ ] Update CHANGELOG.md
- [ ] Rebase on latest `develop` branch

### PR Template

```markdown
## Description
Brief description of changes.

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Testing
Describe testing performed.

## Checklist
- [ ] Code follows style guidelines
- [ ] Self-review completed
- [ ] Comments added for complex code
- [ ] Documentation updated
- [ ] No new warnings generated
- [ ] Tests added/updated
- [ ] All tests passing

## Screenshots (if applicable)

## Related Issues
Closes #XXX
```

### Review Process

1. **Automated checks** must pass (CI/CD, linting)
2. **At least one approval** from maintainers required
3. **All comments addressed** before merge
4. **Squash and merge** for clean history

### After Merge

- Delete your feature branch
- Update your local repository
- Celebrate! 🎉

## Testing Guidelines

### Unit Tests

- Write tests for all new functions
- Aim for >80% code coverage
- Use descriptive test names
- Test edge cases and error handling

### Integration Tests

- Test component interactions
- Use realistic test data
- Clean up resources after tests
- Document test dependencies

### Script Testing

```bash
# Test shell scripts with shellcheck
shellcheck scripts/**/*.sh

# Run unit tests
./tests/run-unit-tests.sh

# Run integration tests
./tests/run-integration-tests.sh
```

### Infrastructure Testing

```bash
# Validate Terraform
terraform validate
terraform fmt -check

# Test Terraform with terratest
cd tests/terraform
go test -v

# Validate Kubernetes manifests
kubectl apply --dry-run=client -f k8s/

# Lint Helm charts
helm lint helm/app-chart/
```

## Documentation

### Code Documentation

- Add comments for complex logic
- Document all functions with purpose and parameters
- Include usage examples
- Keep README updated

### Architecture Documentation

- Update architecture diagrams when making structural changes
- Document design decisions
- Explain trade-offs
- Add ADRs (Architecture Decision Records) for significant decisions

## Style Guide

### Shell Scripts

```bash
#!/bin/bash
# Strict mode
set -euo pipefail

# Constants in UPPERCASE
readonly MAX_RETRIES=3

# Functions in lowercase with underscores
function check_prerequisites() {
    # Function body
}

# Error handling
trap 'echo "Error on line $LINENO"' ERR
```

### Python

```python
"""Module docstring describing purpose."""

from typing import List, Dict


def process_data(input_data: List[str]) -> Dict[str, int]:
    """
    Process input data and return statistics.
    
    Args:
        input_data: List of strings to process
        
    Returns:
        Dictionary with processing statistics
        
    Raises:
        ValueError: If input_data is empty
    """
    if not input_data:
        raise ValueError("Input data cannot be empty")
    
    # Implementation
    return {}
```

## Getting Help

- **Questions?** Open a [Discussion](https://github.com/QUOJO-DAWSON/devops-practise/discussions)
- **Found a bug?** Create an [Issue](https://github.com/QUOJO-DAWSON/devops-practise/issues)
- **Need clarification?** Comment on the relevant PR or issue

## Recognition

Contributors will be recognized in:
- README.md acknowledgments
- CHANGELOG.md for significant contributions
- Annual contributor highlights

## License

By contributing, you agree that your contributions will be licensed under the MIT License.

---

**Thank you for contributing! Your efforts help make this project better for everyone.** 🚀
