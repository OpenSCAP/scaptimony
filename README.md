# SCAPtimony

SCAPtimony project gives full testimony about compliance of your infrastructure.
SCAPtimony is SCAP storage and database server build on top of OpenSCAP library.
SCAPtimony can be deployed as a part of your Rails application (i.e. Foreman) or
as a stand-alone sealed server.

+ Current features:
  + Achieve SCAP audit results from your infrastructure
    + Provide API for tools to upload collected SCAP results
  + Rails artefacts to display audit results within your application
+ Future features:
  + Define security/compliance policies
    + Archive distinct versions of the policy
    + Upload SCAP content and assign it with the policy
    + Set-up a periodical schedule of audits for the policy
    + Organization defined targeting (Assign a set of nodes with the policy)
    + Define known-issues and waivers (Assign waivers with a set of nodes and the policy)
    + Set-up rules for automated deletion of results
  + Result post-processing
    + Search SCAP results
    + Search for non-compliant systems
    + Search for not audited systems
    * Comparison of audit results
    + Waive known issues
      + One time waivers of a report
      + Set-up periodic waivers for a given policy and system
      + Set a waiver expirations time (to give the time to remediate things)
  + Let us know, if your feature is missing.

## Installation

- Get SCAPtimony sources

  ```
  $ git clone https://github.com/OpenSCAP/scaptimony.git
  ```

- Build SCAPtimony RPM (instructions for Red Hat Enterprise Linux 6)

  Enable Software Collections as per [instructions](https://access.redhat.com/documentation/en-US/Red_Hat_Software_Collections/1/html-single/1.1_Release_Notes/index.html#sect-Installation_and_Usage-Subscribe).

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
