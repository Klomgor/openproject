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

module API::V3::StorageFiles
  class StorageFileRepresenter < ::API::Decorators::Single
    include API::Decorators::DateProperty

    def initialize(model, storage, current_user:)
      super(model, current_user:)

      @storage_id = storage.id
    end

    link :self do
      {
        href: api_v3_paths.storage_file(@storage_id, represented.id),
        title: represented.name
      }
    end

    property :id
    property :name
    property :size
    property :mime_type
    date_time_property :created_at
    date_time_property :last_modified_at
    property :created_by_name
    property :last_modified_by_name
    property :location
    property :permissions

    def _type
      Storages::StorageFile.name.split("::").last
    end
  end
end
