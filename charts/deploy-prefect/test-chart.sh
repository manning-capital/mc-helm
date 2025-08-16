#!/bin/bash

# Test script for deploy-prefect Helm chart
# This script validates the chart and tests template rendering

set -e

echo "🧪 Testing deploy-prefect Helm chart..."

# Check if we're in the right directory
if [ ! -f "Chart.yaml" ]; then
    echo "❌ Error: Chart.yaml not found. Please run this script from the chart directory."
    exit 1
fi

echo "✅ Chart.yaml found"

# Lint the chart
echo "🔍 Linting chart..."
if helm lint . > /dev/null 2>&1; then
    echo "✅ Chart linting passed"
else
    echo "❌ Chart linting failed"
    helm lint .
    exit 1
fi

# Test template rendering with sample values
echo "🔧 Testing template rendering..."
if helm template . --set image.repository=test-image --set image.tag=latest --dry-run > /dev/null 2>&1; then
    echo "✅ Template rendering passed"
else
    echo "❌ Template rendering failed"
    exit 1
fi

# Test validation (should fail without required values)
echo "🚫 Testing validation (should fail without required values)..."
if helm template . --dry-run > /dev/null 2>&1; then
    echo "❌ Validation failed - chart should require image.repository and image.tag"
    exit 1
else
    echo "✅ Validation working correctly - required values enforced"
fi

echo ""
echo "🎉 All tests passed! Your chart is ready for deployment."
echo ""
echo "To deploy, run:"
echo "  helm install deploy-prefect . \\"
echo "    --set image.repository=your-image \\"
echo "    --set image.tag=your-tag"
echo ""
echo "Or use the example values:"
echo "  helm install deploy-prefect . -f values-example.yaml"
