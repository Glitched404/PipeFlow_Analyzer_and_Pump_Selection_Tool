# Contributing to PipeFlow-Analyzer

Thank you for your interest in contributing! This project welcomes contributions from the community.

## How to Contribute

### Reporting Bugs
- Check if the bug has already been reported in Issues
- Include MATLAB version, OS, and steps to reproduce
- Attach sample input files if relevant

### Suggesting Enhancements
- Open an issue with the "enhancement" label
- Describe the feature and its use case
- Explain how it fits with the project goals

### Code Contributions

1. **Fork the repository**
2. **Create a feature branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```
3. **Make your changes**
   - Follow existing code style
   - Add comments for complex logic
   - Update documentation if needed
4. **Test your changes**
   - Run `validation_suite` to ensure tests pass
   - Test with multiple input scenarios
5. **Commit with clear messages**
   ```bash
   git commit -m "Add: Brief description of changes"
   ```
6. **Push and create a Pull Request**

## Code Style Guidelines

- One function per `.m` file
- Function name must match filename
- Include header comments with description, inputs, outputs
- Use meaningful variable names
- Add inline comments for complex calculations

## Testing

All contributions should:
- Pass existing validation tests
- Include new tests for new features
- Not break backward compatibility (unless discussed)

## Questions?

Open an issue or contact: skaftabhosen695@gmail.com
