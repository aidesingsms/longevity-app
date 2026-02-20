#!/bin/bash
# Comandos para subir la versión avanzada a GitHub
# Ejecutar en tu máquina local

echo "🚀 Subiendo versión avanzada a GitHub..."

# Ir al directorio del proyecto
cd ~/Downloads/longevity-app  # o donde tengas el proyecto

# Verificar estado
git status

# Agregar archivos nuevos
git add web-demo/advanced.html

# Commit
git commit -m "feat: Advanced AI biological age calculator

- TensorFlow.js PoseNet integration
- Real-time pose analysis
- Body posture scoring (posture, symmetry, spine, shoulders)
- Advanced biomarkers (ABSI, BRI)
- AI-generated personalized insights
- Cardiovascular metrics (BP, resting HR, VO2 Max)
- Metabolic markers (glucose, cholesterol)
- Photo upload with AI analysis"

# Push a GitHub
git push origin main

echo "✅ Versión avanzada subida!"
echo ""
echo "URL: https://github.com/aidesingsms/longevity-app"
echo "Web demo: https://aidesingsms.github.io/longevity-app/web-demo/advanced.html"
