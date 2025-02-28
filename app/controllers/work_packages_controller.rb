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

class WorkPackagesController < ApplicationController
  include QueriesHelper
  include PaginationHelper
  include Layout
  include WorkPackagesControllerHelper
  include OpTurbo::DialogStreamHelper
  include OpTurbo::ComponentStream

  accept_key_auth :index, :show

  before_action :authorize_on_work_package,
                :project, only: %i[show generate_pdf_dialog generate_pdf]
  before_action :load_and_authorize_in_optional_project,
                :check_allowed_export,
                :protect_from_unauthorized_export, only: %i[index export_dialog]

  before_action :authorize, only: :show_conflict_flash_message
  authorization_checked! :index, :show, :export_dialog, :generate_pdf_dialog, :generate_pdf

  before_action :load_and_validate_query, only: :index, unless: -> { request.format.html? }
  before_action :load_work_packages, only: :index, if: -> { request.format.atom? }
  before_action :load_and_validate_query_for_export, only: :export_dialog

  def index
    respond_to do |format|
      format.html do
        render :index,
               locals: { query: @query, project: @project, menu_name: project_or_global_menu },
               layout: "angular/angular"
      end

      format.any(*supported_list_formats) do
        export_list(request.format.symbol)
      end

      format.atom do
        atom_list
      end
    end
  end

  def show
    respond_to do |format|
      format.html do
        render :show,
               locals: { work_package:, menu_name: project_or_global_menu },
               layout: "angular/angular"
      end

      format.any(*supported_single_formats) do
        export_single(request.format.symbol)
      end

      format.atom do
        atom_journals
      end

      format.all do
        head :not_acceptable
      end
    end
  end

  def export_dialog
    respond_with_dialog WorkPackages::Exports::ModalDialogComponent.new(query: @query, project: @project, title: params[:title])
  end

  def generate_pdf_dialog
    respond_with_dialog WorkPackages::Exports::Generate::ModalDialogComponent.new(work_package: work_package, params: params)
  end

  def generate_pdf
    export = work_package_exporter.export!
    send_data(export.content, type: export.mime_type, filename: export.title)
  rescue ::Exports::ExportError => e
    flash[:error] = e.message
    redirect_back(fallback_location: work_package_path(work_package))
  end

  def work_package_exporter
    case params[:template]
    when "contract"
      WorkPackage::PDFExport::DocumentGenerator.new(work_package, params)
    else
      # when "attributes"
      WorkPackage::PDFExport::WorkPackageToPdf.new(work_package, params)
    end
  end

  def show_conflict_flash_message
    scheme = params[:scheme]&.to_sym || :danger

    render_flash_message_via_turbo_stream(
      component: WorkPackages::UpdateConflictComponent,
      scheme:,
      message: I18n.t("notice_locking_conflict_#{scheme}"),
      button_text: I18n.t("notice_locking_conflict_action_button")
    )

    respond_with_turbo_streams
  end

  protected

  def load_and_validate_query_for_export
    load_and_validate_query
  end

  def export_list(mime_type)
    job_id = WorkPackages::Exports::ScheduleService
               .new(user: current_user)
               .call(query: @query, mime_type:, params:)
               .result

    if request.headers["Accept"]&.include?("application/json")
      render json: { job_id: }
    else
      redirect_to job_status_path(job_id)
    end
  end

  def export_single(mime_type)
    exporter = Exports::Register
                 .single_exporter(WorkPackage, mime_type)
                 .new(work_package, params)

    export = exporter.export!
    send_data(export.content, type: export.mime_type, filename: export.title)
  rescue ::Exports::ExportError => e
    flash[:error] = e.message
    redirect_back(fallback_location: work_package_path(work_package))
  end

  def atom_journals
    render template: "journals/index",
           layout: false,
           content_type: "application/atom+xml",
           locals: { title: "#{Setting.app_title} - #{work_package}",
                     journals: }
  end

  private

  def authorize_on_work_package
    deny_access(not_found: true) unless work_package
  end

  def per_page_param
    case params[:format]
    when "atom"
      Setting.feeds_limit.to_i
    else
      super
    end
  end

  def project
    @project ||= work_package&.project
  end

  def work_package
    @work_package ||= WorkPackage.visible(current_user).find_by(id: params[:id])
  end

  def journals
    @journals ||= begin
      order =
        if current_user.wants_comments_in_reverse_order?
          Journal.arel_table["created_at"].desc
        else
          Journal.arel_table["created_at"].asc
        end

      work_package
        .journals
        .changing
        .includes(:user)
        .order(order).to_a
    end
  end

  def index_redirect_path
    if @project
      project_work_packages_path(@project)
    else
      work_packages_path
    end
  end

  def load_work_packages
    @results = @query.results
    @work_packages =
      if @query.valid?
        @results
          .work_packages
          .page(page_param)
          .per_page(per_page_param)
      else
        []
      end
  end

  def login_back_url_params
    params.permit(:query_id, :state, :query_props)
  end
end
