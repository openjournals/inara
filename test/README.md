# Testing

There are two different versions of the files here that use `-m test/metadata.yaml` to
override some of the built-in metadata.

1. `expected-pub` is for **production** files. These are created
   by adding the `-p` flag to the entrypoint script.
2. `expected-paper.*` is for **draft** files. These are created w/o the `-p` flag

All of these files get generated on the GitHub action, so you can do the following to update them:

1. Start a PR with your changes. This will engage the CI action that builds things for you
2. Navigate to https://github.com/openjournals/inara/actions
3. Find the most recent "Compile paper example" run corresponding to your run
4. Scroll down to the "Artifacts" section
5. Download the `production-golden` and `draft-golden` folders which contain all the parts you need.
