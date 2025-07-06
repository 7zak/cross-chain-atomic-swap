#!/bin/bash

# Cross-Chain Atomic Swap Setup Script
# This script sets up the development environment for the atomic swap protocol

set -e

echo "🚀 Setting up Cross-Chain Atomic Swap development environment..."

# Check if Clarinet is installed
if ! command -v clarinet &> /dev/null; then
    echo "❌ Clarinet is not installed. Please install it first:"
    echo "   curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh"
    echo "   cargo install clarinet-cli"
    exit 1
fi

echo "✅ Clarinet found: $(clarinet --version)"

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo "❌ Node.js is not installed. Please install Node.js 16+ first."
    exit 1
fi

echo "✅ Node.js found: $(node --version)"

# Install npm dependencies if package.json exists
if [ -f "package.json" ]; then
    echo "📦 Installing npm dependencies..."
    npm install
    echo "✅ Dependencies installed"
fi

# Check Clarity contracts
echo "🔍 Checking Clarity contracts..."
if clarinet check; then
    echo "✅ All contracts are valid"
else
    echo "❌ Contract validation failed"
    exit 1
fi

# Run tests
echo "🧪 Running tests..."
if clarinet test; then
    echo "✅ All tests passed"
else
    echo "❌ Some tests failed"
    exit 1
fi

# Create necessary directories
echo "📁 Creating project directories..."
mkdir -p logs
mkdir -p tmp
mkdir -p deployments/artifacts

echo "✅ Project directories created"

# Set up git hooks (if .git exists)
if [ -d ".git" ]; then
    echo "🔧 Setting up git hooks..."
    
    # Pre-commit hook
    cat > .git/hooks/pre-commit << 'EOF'
#!/bin/bash
echo "Running pre-commit checks..."

# Check Clarity contracts
if ! clarinet check; then
    echo "❌ Contract check failed"
    exit 1
fi

# Run tests
if ! clarinet test; then
    echo "❌ Tests failed"
    exit 1
fi

echo "✅ Pre-commit checks passed"
EOF

    chmod +x .git/hooks/pre-commit
    echo "✅ Git hooks configured"
fi

# Generate example configuration
echo "⚙️ Generating example configuration..."

cat > .env.example << 'EOF'
# Example environment configuration
# Copy this to .env and fill in your values

# Network configuration
STACKS_NETWORK=testnet
STACKS_API_URL=https://stacks-node-api.testnet.stacks.co

# Contract deployment
CONTRACT_ADDRESS=
DEPLOYER_PRIVATE_KEY=

# API keys (if needed)
BITCOIN_RPC_URL=
BITCOIN_RPC_USER=
BITCOIN_RPC_PASS=

# Monitoring
LOG_LEVEL=info
ENABLE_METRICS=false
EOF

echo "✅ Example configuration created (.env.example)"

# Create development scripts
echo "📝 Creating development scripts..."

cat > scripts/dev.sh << 'EOF'
#!/bin/bash
# Development helper script

case "$1" in
    "start")
        echo "Starting development environment..."
        clarinet integrate
        ;;
    "test")
        echo "Running tests..."
        clarinet test
        ;;
    "check")
        echo "Checking contracts..."
        clarinet check
        ;;
    "console")
        echo "Starting Clarinet console..."
        clarinet console
        ;;
    *)
        echo "Usage: $0 {start|test|check|console}"
        exit 1
        ;;
esac
EOF

chmod +x scripts/dev.sh

echo "✅ Development scripts created"

# Final setup verification
echo "🔍 Verifying setup..."

# Check if all required files exist
required_files=(
    "Clarinet.toml"
    "contracts/atomic-swap.clar"
    "tests/atomic-swap_test.ts"
    "settings/Devnet.toml"
)

for file in "${required_files[@]}"; do
    if [ -f "$file" ]; then
        echo "✅ $file exists"
    else
        echo "❌ $file is missing"
        exit 1
    fi
done

echo ""
echo "🎉 Setup completed successfully!"
echo ""
echo "Next steps:"
echo "1. Copy .env.example to .env and configure your settings"
echo "2. Run 'npm run integrate' to start the development environment"
echo "3. Run 'npm test' to execute the test suite"
echo "4. Check out the examples/ directory for usage examples"
echo ""
echo "Happy coding! 🚀"
