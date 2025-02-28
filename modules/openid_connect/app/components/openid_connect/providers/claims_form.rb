#-- copyright
# OpenProject is an open source project management software.
# Copyright (C) 2012-2024 the OpenProject GmbH
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

module OpenIDConnect
  module Providers
    class ClaimsForm < BaseForm
      include Redmine::I18n

      form do |f|
        f.text_area(
          name: :claims,
          rows: 10,
          label: I18n.t("activerecord.attributes.openid_connect/provider.claims"),
          caption: link_translate(
            "openid_connect.instructions.claims",
            links: {
              docs_url: ::OpenProject::Static::Links[:sysadmin_docs][:oidc_claims][:href]
            }
          ),
          disabled: provider.seeded_from_env?,
          required: false,
          input_width: :large
        )

        f.text_field(
          name: :acr_values,
          label: I18n.t("activerecord.attributes.openid_connect/provider.acr_values"),
          caption: link_translate(
            "openid_connect.instructions.acr_values",
            links: {
              docs_url: ::OpenProject::Static::Links[:sysadmin_docs][:oidc_acr_values][:href]
            }
          ),
          disabled: provider.seeded_from_env?,
          required: false,
          input_width: :large
        )
      end
    end
  end
end
