# Releasing

A checklist for a GitHub release with a Zenodo DOI. Nothing here runs automatically.

## Before the release

1. Set the new version in `VERSION` and in the `version` field of `CITATION.cff` (`test_version` fails when they differ), and add a section to `RELEASE_NOTES.md`.
2. Rebuild the generated files: `build_ride_lib`, `build_demo('halfcar')`, `build_demo('quartercar')`, `examples/live/build_live_scripts.m`.
3. Run the tests on a clean path: `restoredefaultpath; setup; results = runtests('tests')`. All must pass, Simulink included.
4. Run `examples/paper/make_all.m` and look at every figure.
5. Build the toolbox, `addpath toolbox; package_toolbox`, install the `.mltbx` in a fresh MATLAB session, and run `runtests(fullfile(ride.root(), 'tests'))` there. Uninstall it afterwards.
6. Check `CITATION.cff`, for example with `cffconvert --validate` (`pip install cffconvert`).
7. Commit, tag `v<version>`, push the commit and the tag.

## GitHub release and Zenodo

1. Zenodo archives public repositories only. The repository has to be public before the first archived release.
2. On zenodo.org, sign in with GitHub and switch the repository on under GitHub settings. Zenodo then archives every GitHub release.
3. On GitHub, draft a release from the tag, paste the release notes and attach `dist/ride-models-<version>.mltbx`.
4. Zenodo creates a DOI for the release and a concept DOI for all versions. Add the DOI to `CITATION.cff` (`doi:` and, in `identifiers`, the version DOI) and to the README, and commit that on the main branch. Zenodo reads `CITATION.cff` for the authors and title of the archive, so it has to be correct before the release.
5. Optionally, link the GitHub repository on MATLAB File Exchange, which picks up GitHub releases.

The DOI only exists after step 4; do not write one in before.
