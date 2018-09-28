#!/bin/bash

psql --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" --command 'create extension if not exists textsearch_ja'