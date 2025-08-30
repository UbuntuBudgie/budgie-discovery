#!/bin/sh

mkdir -p ./locale/de/LC_MESSAGES
msgfmt ./po/de.po --output-file=./locale/de/LC_MESSAGES/discovery-applet.mo