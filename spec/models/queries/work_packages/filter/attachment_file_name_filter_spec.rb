#-- copyright
# OpenProject is an open source project management software.
# Copyright (C) the OpenProject GmbH
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License version 3.
#
# OpenProject is a fork of ChiliProject, which is a fork of Redmine. The copyright follows:
# Copyright (C) 2006-2013 Jean-Philippe Lang
# Copyright (C) 2010-2013 the ChiliProject Team
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
#
# See COPYRIGHT and LICENSE files for more details.
#++

require "spec_helper"

RSpec.describe Queries::WorkPackages::Filter::AttachmentFileNameFilter do
  if OpenProject::Database.allows_tsv?
    it_behaves_like "basic query filter" do
      let(:type) { :text }
      let(:name) { "Attachment file name" }
      let(:class_key) { :attachment_file_name }

      describe "#available?" do
        it "is available" do
          expect(instance).to be_available
        end
      end

      describe "#allowed_values" do
        it "is nil" do
          expect(instance.allowed_values).to be_nil
        end
      end

      describe "#valid_values!" do
        it "is a noop" do
          instance.values = ["none", "is", "changed"]

          instance.valid_values!

          expect(instance.values)
            .to contain_exactly("none", "is", "changed")
        end
      end

      describe "#available_operators" do
        it "supports ~ and !~" do
          expect(instance.available_operators)
            .to eql [Queries::Operators::Contains, Queries::Operators::NotContains]
        end
      end

      it_behaves_like "non ar filter"
    end
  end
end
