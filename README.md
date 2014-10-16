# SCAPtimony

SCAPtimony is SCAP storage and database server build on top of OpenSCAP library.
SCAPtimony can be deployed as a part of your Rails application (i.e. Foreman) or
as a stand-alone sealed server.

+ Current features:
  + Collect & achieve OpenSCAP audit results from your infrastructure
+ Future features:
  + Rails artefacts to display audit results within your application
  + API to set-up organization defined targeting (connect set of system, a policy and time schedule)
  + Comparison of audit results
  + Waive known issues (one-time waivers, re-occurring, waivers)

## Installation

- Get SCAPtimony sources

  ```
  $ git clone https://github.com/OpenSCAP/scaptimony.git
  ```

- Build SCAPtimony RPM (instructions for Red Hat Enterprise Linux 6)

  ```
  $ cd scaptimony
  $ gem build scaptimony.gemspec
  # yum install yum-utils rpm-build scl-utils scl-utils-build ruby193-rubygems-devel
  # yum-builddep extra/rubygem-scaptimony.spec
  $ rpmbuild  --define "_sourcedir `pwd`" --define "scl ruby193" -ba extra/rubygem-scaptimony.spec
  ```

- Install SCAPtimony RPM

  ```
  # yum local install ~/rpmbuild/RPMS/noarch/ruby193-rubygem-scaptimony-*.noarch.rpm
  ```

## Usage

Users are currently adviced to use SCAPtimony only through
[foreman_openscap](https://github.com/OpenSCAP/foreman_openscap).

## Copyright

Copyright (c) 2014 Red Hat, Inc.

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
