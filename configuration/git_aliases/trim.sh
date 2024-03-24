git branch --merged | grep --invert-match '[*]' | xargs --no-run-if-empty git branch --delete
