# Contributing to Cross-Chain Atomic Swap Protocol

Thank you for your interest in contributing to the Cross-Chain Atomic Swap Protocol! This document provides guidelines and information for contributors.

## 🤝 How to Contribute

### Reporting Issues

1. **Search existing issues** first to avoid duplicates
2. **Use the issue template** when creating new issues
3. **Provide detailed information** including:
   - Steps to reproduce
   - Expected vs actual behavior
   - Environment details (OS, Node.js version, Clarinet version)
   - Relevant logs or error messages

### Submitting Pull Requests

1. **Fork the repository** and create a feature branch
2. **Follow the coding standards** outlined below
3. **Add tests** for new functionality
4. **Update documentation** as needed
5. **Ensure all tests pass** before submitting
6. **Write clear commit messages** following conventional commits

## 🏗️ Development Setup

### Prerequisites

- Node.js 16+
- Clarinet CLI
- Git

### Setup Steps

```bash
# Clone your fork
git clone https://github.com/your-username/cross-chain-atomic-swap.git
cd cross-chain-atomic-swap

# Run setup script
./scripts/setup.sh

# Start development environment
npm run integrate
```

## 📝 Coding Standards

### Clarity Code Style

- Use descriptive function and variable names
- Add comprehensive comments for complex logic
- Follow consistent indentation (2 spaces)
- Use meaningful error codes and messages
- Validate all inputs thoroughly

Example:
```clarity
;; Good: Descriptive function name and comprehensive validation
(define-public (initiate-cross-chain-swap (participant principal) (amount uint))
  (begin
    ;; Validate inputs
    (asserts! (> amount MIN-SWAP-AMOUNT) (err ERR-INSUFFICIENT-FUNDS))
    (asserts! (not (is-eq tx-sender participant)) (err ERR-INVALID-PARTICIPANT))
    
    ;; Implementation...
    (ok true)
  )
)
```

### JavaScript/TypeScript Style

- Use ES6+ features
- Follow consistent naming conventions (camelCase)
- Add JSDoc comments for functions
- Handle errors gracefully
- Use async/await for asynchronous operations

Example:
```javascript
/**
 * Initiates an atomic swap transaction
 * @param {string} senderKey - Private key of the sender
 * @param {string} participant - Address of the participant
 * @param {number} amount - Amount to swap in microunits
 * @returns {Promise<string>} Transaction ID
 */
async function initiateSwap(senderKey, participant, amount) {
  try {
    // Implementation...
    return txId;
  } catch (error) {
    console.error('Failed to initiate swap:', error);
    throw error;
  }
}
```

### Testing Standards

- Write comprehensive test cases
- Test both success and failure scenarios
- Use descriptive test names
- Mock external dependencies
- Aim for high code coverage

Example:
```typescript
Clarinet.test({
  name: "Should successfully initiate swap with valid parameters",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    // Test implementation...
  }
});

Clarinet.test({
  name: "Should reject swap initiation with insufficient funds",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    // Test implementation...
  }
});
```

## 🧪 Testing Guidelines

### Running Tests

```bash
# Run all tests
npm test

# Run specific test file
clarinet test --filter atomic-swap

# Run with coverage
npm run test:coverage
```

### Test Categories

1. **Unit Tests**: Test individual functions in isolation
2. **Integration Tests**: Test contract interactions
3. **End-to-End Tests**: Test complete swap workflows
4. **Security Tests**: Test edge cases and attack vectors

### Writing New Tests

- Test all public functions
- Include negative test cases
- Test boundary conditions
- Verify error handling
- Test multi-signature scenarios
- Test privacy features

## 📚 Documentation

### Documentation Requirements

- Update README.md for new features
- Add API documentation for new functions
- Include usage examples
- Update CHANGELOG.md
- Add inline code comments

### Documentation Style

- Use clear, concise language
- Include code examples
- Provide context and rationale
- Link to relevant resources
- Keep examples up-to-date

## 🔒 Security Considerations

### Security Review Process

1. **Self-review** your code for security issues
2. **Consider attack vectors** and edge cases
3. **Test with malicious inputs**
4. **Review cryptographic implementations**
5. **Check for reentrancy vulnerabilities**

### Common Security Issues

- Integer overflow/underflow
- Reentrancy attacks
- Access control bypasses
- Timestamp manipulation
- Front-running attacks

### Security Checklist

- [ ] Input validation implemented
- [ ] Access controls verified
- [ ] Error handling secure
- [ ] No sensitive data exposure
- [ ] Cryptographic functions used correctly
- [ ] Time-based logic secure

## 🚀 Release Process

### Version Numbering

We follow [Semantic Versioning](https://semver.org/):
- MAJOR: Breaking changes
- MINOR: New features (backward compatible)
- PATCH: Bug fixes (backward compatible)

### Release Checklist

- [ ] All tests pass
- [ ] Documentation updated
- [ ] CHANGELOG.md updated
- [ ] Version bumped in package.json
- [ ] Security review completed
- [ ] Deployment tested on testnet

## 🏷️ Commit Message Format

We use [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

### Types

- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes
- `refactor`: Code refactoring
- `test`: Test additions/modifications
- `chore`: Maintenance tasks

### Examples

```
feat(swap): add multi-signature support for atomic swaps

Add configurable multi-signature requirements for enhanced security
in high-value atomic swaps.

Closes #123
```

```
fix(claim): prevent double claiming of swaps

Add additional validation to prevent race conditions in swap claiming.

Fixes #456
```

## 🎯 Areas for Contribution

### High Priority

- Security audits and improvements
- Performance optimizations
- Additional test coverage
- Documentation improvements
- Bug fixes

### Medium Priority

- New privacy features
- Cross-chain integrations
- Developer tooling
- Example applications
- UI/UX improvements

### Low Priority

- Code refactoring
- Style improvements
- Minor feature enhancements

## 📞 Getting Help

- **GitHub Issues**: For bugs and feature requests
- **GitHub Discussions**: For questions and general discussion
- **Discord**: [Join our community](https://discord.gg/stacks) (if applicable)
- **Email**: hexchange001@gmail.com for security issues

## 📄 License

By contributing to this project, you agree that your contributions will be licensed under the MIT License.

## 🙏 Recognition

Contributors will be recognized in:
- README.md contributors section
- Release notes
- Project documentation

Thank you for helping make the Cross-Chain Atomic Swap Protocol better! 🚀
