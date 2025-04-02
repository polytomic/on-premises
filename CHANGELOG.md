## 2.5.1 (2 Apr 2025)

- Support for attaching deny insecure transport policy to S3 bucket.

## 2.5.0 (24 Mar 2025)

- Isolate schema cache activity in dedicated service.
- Increased default ephemeral storage for sync containers.

## 2.4.2 (13 Jan 2025)

- Expose VPC ID to Fargate sync tasks.

## 2.4.1 (10 Jan 2025)

- Expose deployment key secret into supporting containers in ECS tasks.

## ~~2.4.0 (9 Jan 2025)~~

**This release did not work correctly when managed logging is enabled; 2.4.1
should be used instead.**

- Secrets are stored in AWS SSM, rather than directly in the environment.
- Removed container-specific memory reservations. These were redundant and
  prevented overriding tasks to use a smaller memory footprint than the default.

## 2.3.4 (20 Nov 2024)

- Remove hard-coded profiling, tracing settings from ECS task definitions.

## 2.3.3 (30 Apr 2024)

- Updated RDS CA Cert Identifier to `rds-ca-rsa2048-g1`.

## 2.3.2 (20 Mar 2024)

- Explicitly allow sync execution tasks to use sts:AssumeRole.

## 2.3.1 (8 Mar 2024)

- Version lock EFS module

## 2.3.0 (5 Mar 2024)

- Explicitly allow tagging of ECS resources by Polytomic containers.

## 2.2.12 (29 Jan 2024)

- Add redundancy for web service.

## 2.2.8 (28 Nov 2023)

- Expose Datadog Agent & Logging settings to Polytomic containers.

## 2.2.7 (10 Aug 2023)

- Add GCS bucket resource to GKE terraform module
- Various helm chart improvements (see polytomic-x.x.x releases for details)
- Add support for `schemacache` role

## 2.2.6 (7 Jul 2023)

- Add resource `Name` tags to AWS resources in ECS module

## 1.0.0 (18 May 2023)

- Initial release
