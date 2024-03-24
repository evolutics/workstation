git save && git switch "$(basename "$(git symbolic-ref refs/remotes/origin/HEAD)")" && git fetch && git reset --hard '@{upstream}'
