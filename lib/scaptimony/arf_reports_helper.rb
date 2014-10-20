#
# Copyright (c) 2014 Red Hat Inc.
#
# This software is licensed to you under the GNU General Public License,
# version 3 (GPLv3). There is NO WARRANTY for this software, express or
# implied, including the implied warranties of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv3
# along with this software; if not, see http://www.gnu.org/licenses/gpl.txt
#

require 'digest'

module Scaptimony
  module ArfReportsHelper
    def self.create_arf(asset, params, arf_bzip)
      # TODO:RAILS-4.0: This should become policy = Policy.find_or_create_by!(name: params[:policy])
      policy = Policy.first_or_create!(:name => params[:policy])
      digest = Digest::SHA256.hexdigest arf_bzip
      # TODO:RAILS-4.0: This should become arf_report = ArfReport.find_or_create_by! ...
      arf_report = ArfReport.where(:asset_id => asset.id, :policy_id => policy.id, :date => params[:date], :digest => digest).first_or_create!
      arf_report.store!(arf_bzip)
    end
  end
end
