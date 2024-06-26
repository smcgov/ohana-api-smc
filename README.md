[![CircleCI](https://circleci.com/gh/smcgov/ohana-api-smc/tree/master.svg?style=svg)](https://circleci.com/gh/smcgov/ohana-api-smc/tree/master) [![Maintainability](https://api.codeclimate.com/v1/badges/0682b0329126025eff84/maintainability)](https://codeclimate.com/github/smcgov/ohana-api-smc/maintainability) [![Test Coverage](https://api.codeclimate.com/v1/badges/0682b0329126025eff84/test_coverage)](https://codeclimate.com/github/smcgov/ohana-api-smc/test_coverage)
[![View performance data on Skylight](https://badges.skylight.io/status/2Zmxo3CcNDZ5.svg)](https://oss.skylight.io/app/applications/2Zmxo3CcNDZ5)

# Ohana API - San Mateo County

This is the API + Admin Interface portion for the San Mateo County instance of the [Ohana API](http://ohanapi.org). The API exposes information about community resources in San Mateo County to make it easier for residents in need to find services they are eligible for.

## Apps that are using the Ohana API in San Mateo County
[SMC-Connect](http://www.smc-connect.org), a mobile-friendly website for looking up community and human services. ([GitHub repo for SMC-Connect](https://github.com/smcgov/SMC-Connect))

We encourage third-party developers to build additional applications on top of the API. You can register your app on our [developer portal](http://developer.smc-connect.org), and view the [API documentation](http://codeforamerica.github.io/ohana-api-docs/).

## Taxonomy
We are currently using the [Open Eligibility](http://openeligibility.org) taxonomy to assign Services to [Categories](https://github.com/smcgov/ohana-api-smc/blob/master/app/models/category.rb).
The easiest way to assign categories to a service is to use the Admin interface. Here's a screenshot:

![Editing categories in Ohana API Admin](https://github.com/codeforamerica/ohana-api/raw/master/categories-in-ohana-api-admin.png)

## API documentation
[http://codeforamerica.github.io/ohana-api-docs/](http://codeforamerica.github.io/ohana-api-docs/)

## Client libraries

## Ruby wrapper
[https://github.com/codeforamerica/ohanakapa](https://github.com/codeforamerica/ohanakapa)

## Stack Overview

* Ruby version 3.1.4
* Rails version 6.1.7
* Postgres version 14.5
* Redis
* Testing Frameworks: RSpec, Factory Girl, Capybara

## Local Installation
Follow the instructions in [INSTALL.md][install].

[install]: https://github.com/smcgov/ohana-api-smc/blob/master/INSTALL.md

## Running the tests
Run tests locally with this simple command:

    script/test

To see the actual tests, browse through the [spec](https://github.com/smcgov/ohana-api-smc/tree/master/spec) directory.

## Contributing

We'd love to get your help developing this project! Take a look at the [Contribution Document](https://github.com/smcgov/ohana-api-smc/blob/master/CONTRIBUTING.md) to see how you can make a difference.

## Copyright
Copyright (c) 2013 Code for America. See [LICENSE](https://github.com/codeforamerica/ohana-api/blob/master/LICENSE.md) for details.
