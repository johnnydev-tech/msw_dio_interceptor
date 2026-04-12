## [1.0.5](https://github.com/johnnydev-tech/msw_dio_interceptor/compare/v1.0.4...v1.0.5) (2026-04-12)


### Bug Fixes

* Add documentation for handler override feature ([df81388](https://github.com/johnnydev-tech/msw_dio_interceptor/commit/df81388eff7282ce41fe20e6774118584f1ead9e))

## [1.0.4](https://github.com/johnnydev-tech/msw_dio_interceptor/compare/v1.0.3...v1.0.4) (2026-04-12)


### Bug Fixes

* Update MockRegistry to ensure newer handlers override previous ones and add tests for handler precedence ([02e9ad8](https://github.com/johnnydev-tech/msw_dio_interceptor/commit/02e9ad85c0e10b6ff597cb7734678de2c243ae5c))

## [1.0.3](https://github.com/johnnydev-tech/msw_dio_interceptor/compare/v1.0.2...v1.0.3) (2025-11-14)


### Bug Fixes

* Ensure LICENSE file is OSI-compliant for recognition ([0f85fa4](https://github.com/johnnydev-tech/msw_dio_interceptor/commit/0f85fa482bf26243ec34dd8241a550054142e488))
* Update copyright year in LICENSE file to 2025 ([d4ce587](https://github.com/johnnydev-tech/msw_dio_interceptor/commit/d4ce58791f03a3faf8f413d3171148856c60420b))

# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.0.0] - 2023-11-13
### Added
- Initial release of MSW Dio Interceptor.
- Core mocking engine with client-agnostic request/response models.
- Dio adapter for seamless integration with the Dio package.
- Flexible mock rule matching (path, regex, URL, query parameters).
- Support for simulating status codes, delays, and different response body types.
- Customizable logging for mocked requests.
- Comprehensive test suite.
- Detailed README with usage examples and testing guide.
- GitHub Actions for CI and publishing.
