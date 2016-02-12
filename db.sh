#!/bin/sh
${HOME}/.brew/opt/postgresql/bin/postgres -D ${HOME}/.postgresql -r ${HOME}/.postgresql/server.log
