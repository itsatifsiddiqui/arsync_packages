Prepare and publish this Dart package:

1. Check git status to see all changes

2. Create a git commit with an appropriate message based on the changes (e.g., "chore: bump version to X.X.X" or include a summary of what changed)

3. Run `dart pub publish --dry-run` first to check for any issues

4. If dry-run succeeds, ask the user if they want to proceed with the actual publish

5. If confirmed, run `dart pub publish --force` to publish the package

Do NOT push to remote unless explicitly asked.
