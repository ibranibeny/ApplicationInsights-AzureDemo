# 🤝 Contributing Guide

Thank you for your interest in contributing to the Azure Monitor Demo project!

## 🚀 How to Contribute

### 1. Fork and Clone
```bash
git fork https://github.com/your-repo/azure-monitor-demo
git clone https://github.com/your-username/azure-monitor-demo
cd azure-monitor-demo
```

### 2. Create a Branch
```bash
git checkout -b feature/new-functionality
```

### 3. Make Changes
- Keep code clean and documented
- Follow existing naming conventions
- Update documentation if necessary

### 4. Test
```powershell
# Run local tests
.\scripts\demo-final.ps1
```

### 5. Commit and Push
```bash
git add .
git commit -m "feat: description of new functionality"
git push origin feature/new-functionality
```

### 6. Create Pull Request
- Describe the changes made
- Include screenshots if applicable
- Reference related issues

## 📋 Pull Request Checklist

- [ ] Code tested locally
- [ ] Documentation updated
- [ ] No sensitive information (passwords, keys, etc.)
- [ ] Clear commit messages
- [ ] No temporary files or logs

## 🏷️ Conventions

### Commit Messages
- `feat:` new functionality
- `fix:` bug fixes
- `docs:` documentation changes
- `refactor:` code refactoring
- `test:` add or modify tests

### Code
- Use descriptive names for variables and functions
- Comment complex code
- Keep functions small and focused

## 🛠️ Development Setup

### Prerequisites
- Azure CLI
- PowerShell 5.1+
- Git
- Code editor (VS Code recommended)

### Initial Setup
```bash
# Install recommended VS Code extensions
code --install-extension ms-vscode.azure-tools
code --install-extension ms-vscode.powershell
```

Thank you for contributing! 🎉
