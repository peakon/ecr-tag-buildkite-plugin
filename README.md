# ECR Tag Buildkite Plugin

![CI](https://github.com/peakon/ecr-tag-buildkite-plugin/workflows/CI/badge.svg?branch=master)

Retag docker images in AWS ECR based on a lightweight approach described in [AWS documentation](https://docs.aws.amazon.com/AmazonECR/latest/userguide/image-retag.html)

## Example

Add the following to your `pipeline.yml`:

```yml
steps:
  - key: tag-docker-image-ecr
    plugins:
      - peakon/ecr-tag#v0.0.4:
          registry-id: ${AWS_ACCOUNT_ID}
          repository: ${BUILDKITE_PIPELINE_NAME}
          tag: ${BUILDKITE_COMMIT}
          new-tags:
          - ${BUILDKITE_BRANCH}-${BUILDKITE_COMMIT}
          - ${BUILDKITE_BRANCH}
```
## Requirements

- AWS cli, jq
- AWS IAM Permissions that allow `BatchGetImage` and `PutImage` operations.

## Configuration

| property | description |
| ---------|-------------|
| registry-id | ECR registry ID (AWS account id) |
| repository  | ECR repository name |
| tag | Existing docker image tag |
| new-tags | Array of tags to be created |

### AWS profiles

You can specify a custom AWS profile to be used by AWS CLI

- in pipeline YAML (`aws_profile: profile_name`)
- as `BUILDKITE_PLUGIN_ECR_TAG_AWS_PROFILE` environment variable (e.g. inside agent environment hook).

## Developing

To run the tests:

```shell
docker-compose run --rm tests
```

## Contributing

1. Fork the repo
2. Make the changes
3. Run shellcheck and plugin lint
4. Commit and push your changes
5. Send a pull request
>>>>>>> 8aa7528 (Initial commit)
