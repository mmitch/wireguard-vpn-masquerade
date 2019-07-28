Be aware that both `wg-conf.server` and `wg-conf.clients` have been
added to `.gitignore` so that you don't accidentially check in your
configuration and reveal it to the world.

If you want to check in your configuration anyways, you can use `git add --force`.

Better yet: set up a local branch for your local configuration, remove
both files from `.gitignore` in that branch and check in your
configuration.  Then merge (or rebase) any official changes from the
master branch as needed.
