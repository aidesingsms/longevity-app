#!/bin/bash
# GitHub Repository Setup Script for Longevity App
# Run this after creating repo on GitHub

echo "🚀 Setting up Longevity App GitHub Repository..."

# Initialize git repository
git init

# Add all files
git add .

# Initial commit
git commit -m "🎉 Initial commit: Longevity App MVP

- Biological age calculator algorithm
- Web demo (HTML/CSS/JS)
- Flutter project structure
- Supabase backend setup
- Database schema
- Documentation"

# Add remote (replace with your actual repo URL)
# git remote add origin https://github.com/YOUR_USERNAME/longevity-app.git

echo "✅ Repository initialized!"
echo ""
echo "Next steps:"
echo "1. Create repo on GitHub: https://github.com/new"
echo "2. Name: longevity-app"
echo "3. Run: git remote add origin https://github.com/YOUR_USERNAME/longevity-app.git"
echo "4. Run: git push -u origin main"
echo ""
echo "🔗 GitHub repo will be at: https://github.com/YOUR_USERNAME/longevity-app"
