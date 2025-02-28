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
  class NextcloudStorage < Storage
    PROVIDER_FIELDS_DEFAULTS = {
      automatic_management_enabled: true,
      username: "OpenProject"
    }.freeze

    AUTHENTICATION_METHODS = %w[two_way_oauth2 oauth2_sso oauth2_sso_with_two_way_oauth2_fallback].freeze

    store_attribute :provider_fields, :automatically_managed, :boolean
    store_attribute :provider_fields, :username, :string
    store_attribute :provider_fields, :password, :string
    store_attribute :provider_fields, :group, :string
    store_attribute :provider_fields, :group_folder, :string
    store_attribute :provider_fields, :authentication_method, :string, default: "two_way_oauth2"
    store_attribute :provider_fields, :storage_audience, :string

    def oauth_configuration
      Peripherals::OAuthConfigurations::NextcloudConfiguration.new(self)
    end

    def automatic_management_new_record?
      if provider_fields_changed?
        previous_configuration = provider_fields_change.first
        previous_configuration.values_at("automatically_managed", "password").compact.empty?
      else
        automatic_management_unspecified?
      end
    end

    def available_project_folder_modes
      if automatic_management_enabled?
        ProjectStorage.project_folder_modes.keys
      else
        ["inactive", "manual"]
      end
    end

    def audience
      storage_audience
    end

    def authenticate_via_idp?
      %w[oauth2_sso oauth2_sso_with_two_way_oauth2_fallback].include?(authentication_method)
    end

    def authenticate_via_storage?
      %w[two_way_oauth2 oauth2_sso_with_two_way_oauth2_fallback].include?(authentication_method)
    end

    def configuration_checks
      {
        storage_oauth_client_configured: !authenticate_via_storage? || oauth_client.present?,
        openproject_oauth_application_configured: !authenticate_via_storage? || oauth_application.present?,
        host_name_configured: host.present? && name.present?,
        storage_audience_configured: !authenticate_via_idp? || storage_audience.present?
      }
    end

    %i[username group group_folder].each do |attribute_method|
      define_method(attribute_method) do
        super().presence || PROVIDER_FIELDS_DEFAULTS[:username]
      end
    end

    def provider_fields_defaults
      PROVIDER_FIELDS_DEFAULTS
    end
  end
end
