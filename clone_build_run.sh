#!/bin/bash
# Liste des dépôts à cloner
REPOS=(
  "https://github.com/RonanGir/maple-orders-api.git"
  "https://github.com/RonanGir/sugar-shack-ui.git"
)


# Dossier où les dépôts seront clonés
DEST_DIR=sugar-shack-app

# Créer le dossier de destination si il n'existe pas déjà
mkdir -p $DEST_DIR

# Fonction pour cloner les dépôts
clone_repos() {
  echo "Clonage des dépôts..."
  for REPO in "${REPOS[@]}"; do
    REPO_NAME=$(basename "$REPO" .git)
    if [ -d "$DEST_DIR/$REPO_NAME" ]; then
      echo "Le dépôt $REPO_NAME existe déjà, mise à jour (pull)..."
      cd "$DEST_DIR/$REPO_NAME" && git pull
    else
      echo "Clonage du dépôt $REPO_NAME..."
      git clone "$REPO" "$DEST_DIR/$REPO_NAME"
    fi
  done
}


# Fonction pour lancer un build Angular (ng build)
build_angular() {
  cd sugar-shack-ui
  if [ -f "angular.json" ]; then
    echo "Lancement du build Angular pour $(basename $(pwd))..."
    npm install  # Assurez-vous que les dépendances sont installées
    npm run build  # Lancer la build en mode production
    cd ..
    pwd
    if [ $? -ne 0 ]; then
      echo "Erreur lors du build Angular pour $(basename $(pwd))"
      exit 1
    else
      echo "Build Angular terminé avec succès pour $(basename $(pwd))"
    fi
  else
    echo "Aucun fichier angular.json trouvé dans $(basename $(pwd))"
  fi
}

# Fonction pour lancer un build Gradle
build_gradle() {
  cd maple-orders-api
  if [ -f "build.gradle" ]; then
    echo "Lancement du build Gradle pour $(basename $(pwd))..."
    ./gradlew clean build  # Utilisez './gradlew' si le wrapper Gradle est disponible
    cd ..
    pwd
    if [ $? -ne 0 ]; then
      echo "Erreur lors du build Gradle pour $(basename $(pwd))"
      exit 1
    else
      echo "Build Gradle terminé avec succès pour $(basename $(pwd))"
    fi
  else
    echo "Aucun fichier build.gradle trouvé dans $(basename $(pwd))"
  fi
}


build_and_run_docker() {
  # Répertoire où se trouve le fichier docker-compose.yml
  TARGET_DIR="sugar-shack-infra"  # Remplacez par le chemin de votre projet

  DOCKER_COMPOSE_FILE="$TARGET_DIR/docker-compose.yml"

  if [ -f "$DOCKER_COMPOSE_FILE" ]; then
    echo "Construction et démarrage des conteneurs pour $(basename $TARGET_DIR)..."
    cd "$TARGET_DIR"
    docker-compose up --build -d
    if [ $? -ne 0 ]; then
      echo "Erreur lors de la construction des conteneurs Docker."
      exit 1
    else
      echo "Conteneurs Docker démarrés avec succès pour $(basename $TARGET_DIR)."
    fi
  else
    echo "Aucun fichier docker-compose.yml trouvé dans $TARGET_DIR"
  fi
}

# Exécution des fonctions
clone_repos
cd sugar-shack-app
# Lancer le build Gradle si un projet Gradle est détecté
build_gradle
# Lancer le build Angular si un projet Angular est détecté
build_angular
cd ..
build_and_run_docker

echo "Tous les dépôts ont été clonés et les conteneurs Docker sont lancés."
