#!/bin/bash
# flutter clean
flutter build web
firebase use makeit-pub-dev
firebase deploy --only hosting