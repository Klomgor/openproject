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

module Storages
  module Peripherals
    module StorageInteraction
      module OneDrive
        class UserQuery
          def self.call(storage:, auth_strategy:)
            new(storage).call(auth_strategy:)
          end

          def initialize(storage)
            @storage = storage
          end

          def call(auth_strategy:)
            Authentication[auth_strategy].call(storage: @storage) do |http|
              handle_response http.get(UrlBuilder.url(@storage.uri, "/v1.0/me"))
            end
          end

          private

          def handle_response(response)
            case response
            in { status: 200..299 }
              ServiceResult.success(result: { id: response.json["id"] })
            in { status: 401 }
              ServiceResult.failure(result: :unauthorized, errors: StorageError.new(code: :unauthorized))
            in { status: 403 }
              ServiceResult.failure(result: :forbidden, errors: StorageError.new(code: :forbidden))
            else
              data = StorageErrorData.new(source: self.class, payload: response)
              ServiceResult.failure(result: :error, errors: StorageError.new(code: :error, data:))
            end
          end
        end
      end
    end
  end
end
