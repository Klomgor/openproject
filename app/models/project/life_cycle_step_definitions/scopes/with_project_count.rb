# frozen_string_literal: true

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

module Project::LifeCycleStepDefinitions::Scopes
  module WithProjectCount
    extend ActiveSupport::Concern

    class_methods do
      def with_project_count
        project_counts = Project::LifeCycleStep
          .where(active: true)
          .group(:definition_id)
          .select(:definition_id, "COUNT(project_id) AS count")

        Project::LifeCycleStepDefinition
          .with(project_counts:)
          .joins("LEFT OUTER JOIN project_counts ON #{quoted_table_name}.id = project_counts.definition_id")
          .select("#{quoted_table_name}.*")
          .select("COALESCE(project_counts.count, 0) AS project_count")
      end
    end
  end
end
