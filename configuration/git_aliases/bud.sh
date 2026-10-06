git switch --create "$(
  git show --format=%f --no-patch | tr --squeeze-repeats . - | sed 's/^-//'
)"
