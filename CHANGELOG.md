# Changelog
All notable changes to the pipeline-name pipeline.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

This project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [Unreleased]

## 1.1.0-rc1 - 2024/06/24

- Change to group input VEP files by source.
- Fix issue when `novel_orf_peptide` and `alt_translation_peptide` are not specified.
- Fix file name collision of VEP files.
- Set `ucla_cds` to `false` as default. #120
- Set file path in test cases to environment variables.
- Add `--skip-failed`

## 1.0.0 - 2024/04/10

### Added

- Initial pipeline set up.
