# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres
to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.1.3] - 2022-02-25

### Added

- changelog, versioning follows the Semantic Versioning concept: https://semver.org/lang/de/ (Major, Minor, Patch)
- Pipeline status where all 4 pipelines (Biceps, 2x Terraform, Ansible) are working via the DevOps Env
- Moved Ansible and Webserver in 2 different modules. Even if this is partly duplicate code it makes more sense and is
  easier to read and understand.
- verified that we use CIS hardened images (Ubuntu 18.04 LTS) for the webservers (See azure Marketplace: Ubuntu Pro
  18.04 LTS)

## [1.1.4] - 2022-02-28

### Added

- setup Github actions for Code formatting and security topics (super-linter and tfsec)
- Added readme to all tf modules, ansible and biceps
- added a Readme.md to all modules giving a brief overview
- pipelines in a state that they run out of the box on a new account

## [1.1.5] TODO

- improving overall security by following the Securtiy Principle least privilege for Keyvault, Service Principals, ...
  - network security groups vs application security groups
  - Network (whitelist, private endpoint only, network segregation)