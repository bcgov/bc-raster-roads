
<!-- README.md is generated from README.Rmd. Please edit that file -->
[![img](https://img.shields.io/badge/Lifecycle-Stable-97ca00)](https://github.com/bcgov/repomountie/blob/master/doc/lifecycle-badges.md)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

# B.C. Roads in Raster Format

This analysis generates a raster spatial layer with the total length of
roads per hectare for British Columbia.

### Data

This analysis uses the British Columbia [Digital Road Atlas (DRA)
available from the B.C. Data
Catalogue](\(https://catalogue.data.gov.bc.ca/dataset/bb060417-b6e6-4548-b837-f9060d94743e\))
and distributed under the [Access Only - B.C. Crown
Copyright](https://www2.gov.bc.ca/gov/content?id=1AAACC9C65754E4D89A118B875E0FBDA)
licence.

The Digital Road Atlas is the [best available single source of road data
for the Province of
B.C.](https://www2.gov.bc.ca/gov/content?id=21FFEC94B0AD40818D2D2AF06D522714)
Metadata details for the Digital Road Atlas (DRA) are available in PDF
format from the [B.C. Data
Catalogue](https://catalogue.data.gov.bc.ca/dataset/bb060417-b6e6-4548-b837-f9060d94743e).

This analysis *excludes* some surface and road types in the [Digital
Road Atlas
(DRA)](https://catalogue.data.gov.bc.ca/dataset/bb060417-b6e6-4548-b837-f9060d94743e).
Boat (B), overgrown (O) & decomissioned (D) roads are excluded from
`TRANSPORT_LINE_SURFACE_CODE` and ferry routes (F, FP, FR, RWA),
non-motorized trails (T, TD), road proposed (RP), and road pedestrian
mall (RPM) are excluded from `TRANSPORT_LINE_TYPE_CODE`.

### Usage

There are four core scripts that are required for the raster road
density analysis, they need to be run in order:

  - 01\_load.R
  - 02\_clean.R
  - 03\_analysis.R
  - 04\_output.R

Or you can run all four scripts using run\_all.R.

**Note about running time**: This is a large dataset and it takes 7-12
hours to complete.

The packages used in the analysis can be installed from CRAN using
`install.packages()`.

### Getting Help or Reporting an Issue

To report bugs/issues/feature requests, please file an
[issue](https://github.com/bcgov/bc-raster-roads/issues/).

### How to Contribute

If you would like to contribute, please see our
[CONTRIBUTING](CONTRIBUTING.md) guidelines.

Please note that this project is released with a [Contributor Code of
Conduct](CODE_OF_CONDUCT.md). By participating in this project you agree
to abide by its terms.

### License

    Copyright 2017 Province of British Columbia
    
    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at 
    
       http://www.apache.org/licenses/LICENSE-2.0
    
    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.

This repository is maintained by
[ENVEcosystems](https://github.com/orgs/bcgov/teams/envecosystems/members)
and [Environmental Reporting
BC](http://www2.gov.bc.ca/gov/content?id=FF80E0B985F245CEA62808414D78C41B).
Click [here](https://github.com/bcgov/EnvReportBC-RepoList) for a
complete list of Environmental Reporting BC repositories on GitHub.
