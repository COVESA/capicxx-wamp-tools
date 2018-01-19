#!/bin/bash

  REPO_SRC_DIR=capicxx-wamp-tools/org.genivi.commonapi.wamp.updatesite/target/repository
  REPO_DEST_DIR=updatesite/integration
  GH_URL=github.com/GENIVI/capicxx-wamp-tools

  echo -e "Deploying integration p2 site to GitHub pages...\n"
  cp -R $TRAVIS_BUILD_DIR/$REPO_SRC_DIR $HOME/$REPO_DEST_DIR
  cd $HOME
  git config --global user.email "deploy@travis-ci.org"
  git config --global user.name "travis-ci"
  git clone --quiet --branch=gh-pages https://${GH_TOKEN}@$GH_URL gh-pages > /dev/null
  cd gh-pages
  git rm -rf ./$REPO_DEST_DIR
  cp -Rf $HOME/$REPO_DEST_DIR ./$REPO_DEST_DIR
  git add -f .
  git commit -m "Latest p2 updatesite on successful travis build $TRAVIS_BUILD_NUMBER auto-pushed to gh-pages."
  git push -fq origin gh-pages > /dev/null
  echo -e "Deployment finished.\n"
