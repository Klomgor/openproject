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

module API
  module V3
    module Queries
      module Schemas
        class VersionFilterDependencyRepresenter <
          FilterDependencyRepresenter
          def json_cache_key
            super + (filter.project.present? ? [filter.project.id] : [])
          end

          def href_callback
            query_params = "sortBy=#{to_query [%i(semver_name asc)]}&pageSize=-1"

            if filter.project.nil?
              filter_params = [{ sharing: { operator: "=", values: ["system"] } }]

              "#{api_v3_paths.versions}?filters=#{to_query filter_params}&#{query_params}"
            else
              "#{api_v3_paths.versions_by_project(filter.project.id)}?#{query_params}"
            end
          end

          def type
            "[]Version"
          end

          private

          def to_query(param)
            CGI.escape(::JSON.dump(param))
          end
        end
      end
    end
  end
end
