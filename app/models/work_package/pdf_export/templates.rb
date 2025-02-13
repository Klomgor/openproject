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

module WorkPackage::PDFExport
  Template = Data.define(:id, :label, :caption, :enabled)

  class Templates
    def self.build_template_list(disabled_ids, ordered_ids)
      disabled = disabled_ids || []
      templates = static_templates.map do |build_in_template|
        Template.new(**build_in_template, enabled: disabled.exclude?(build_in_template[:id]))
      end
      order = ordered_ids || []
      return templates if order.empty?

      indexes = order.each_with_index.to_a.to_h
      templates.sort_by { |template| indexes[template.id] }
    end

    def self.static_templates
      [
        {
          id: "attributes",
          label: I18n.t("pdf_generator.template_attributes.label"),
          caption: I18n.t("pdf_generator.template_attributes.caption")
        },
        {
          id: "contract",
          label: I18n.t("pdf_generator.template_contract.label"),
          caption: I18n.t("pdf_generator.template_contract.caption")
        }
      ]
    end
  end
end
