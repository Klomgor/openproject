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

require "spec_helper"

RSpec.describe "Document categories",
               :aggregate_failures,
               :skip_csrf,
               type: :rails_request do
  shared_let(:admin) { create(:admin) }
  shared_let(:category) { create(:document_category, name: "Technical") }
  shared_let(:other_category) { create(:document_category, name: "Other") }

  before do
    login_as(admin)
  end

  describe "GET /admin/settings/document_categories" do
    it "renders the index template" do
      get admin_settings_document_categories_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include "Technical"
      expect(response.body).to include "Other"
    end
  end

  describe "DELETE /admin/settings/document_categories/:id" do
    let(:params) { {} }

    context "without documents assigned" do
      it "redirects to the categories index" do
        delete(admin_settings_document_category_path(category), params:)
        expect(response).to redirect_to admin_settings_document_categories_path
        expect { category.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context "with documents assigned" do
      shared_let(:document) { create(:document, category:) }

      it "renders the reassign template" do
        delete(admin_settings_document_category_path(category), params:)
        expect(response).to redirect_to reassign_admin_settings_document_category_path(category)
        expect { category.reload }.not_to raise_error
        expect(document.reload.category).to eq category
      end

      context "with documents assigned and reassigning" do
        let(:params) do
          {
            enumeration: { reassign_to_id: other_category.id }
          }
        end

        it "reassigns the category" do
          delete(admin_settings_document_category_path(category), params:)
          expect(response).to redirect_to admin_settings_document_categories_path
          expect { category.reload }.to raise_error(ActiveRecord::RecordNotFound)
          expect(document.reload.category).to eq other_category
        end
      end
    end
  end
end
