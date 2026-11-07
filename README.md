# publish-preview

Built by the **Publish — build** workflow from the Supabase database. Not site code.
The live site does not read this branch.

- `versions/<id>/` holds one build: data files, `report/`, and `manifest.json` with the sha256 of every file.
- `channels/preview.json` says which version is the preview now (`current`), and the promote stack a rollback walks back through.

The manual is `docs/publish-job.md` on the `main` branch.
