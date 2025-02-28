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

# Purpose: CRUD the global admin page of Storages (=Nextcloud servers)
class Storages::Admin::StoragesController < ApplicationController
  using Storages::Peripherals::ServiceResultRefinements

  include FlashMessagesOutputSafetyHelper
  include OpTurbo::ComponentStream

  # See https://guides.rubyonrails.org/layouts_and_rendering.html for reference on layout
  layout "admin"

  # specify which model #find_model_object should look up
  model_object Storages::Storage

  # Before executing any action below: Make sure the current user is an admin
  # and set the @<controller_name> variable to the object referenced in the URL.
  before_action :require_admin
  before_action :find_model_object,
                only: %i[show_oauth_application destroy edit edit_host edit_storage_audience confirm_destroy update
                         change_health_notifications_enabled replace_oauth_application]
  before_action :ensure_valid_wizard_parameters, only: [:new]
  before_action :require_ee_token_for_one_drive, only: [:new]

  menu_item :external_file_storages

  def index
    @storages = Storages::Storage.all
  end

  # Show the admin page to create a new Storage object.
  # Sets the attributes provider_type and name as default values and then
  # renders the new page (allowing the user to overwrite these values and to
  # fill in other attributes).
  # Used by: The index page above, when the user presses the (+) button.
  # Called by: Global app/config/routes.rb to serve Web page
  def new
    if @storage.blank?
      # Set default parameters using a "service".
      # See also: storages/services/storages/storages/set_attributes_services.rb
      # That service inherits from ::BaseServices::SetAttributes
      @storage = ::Storages::Storages::SetAttributesService
                   .new(user: current_user,
                        model: Storages::Storage.new(provider_type: @provider_type),
                        contract_class: EmptyContract)
                   .call
                   .result
    end

    @wizard = storage_wizard(@storage)
    @target_step = @wizard.prepare_next_step
  end

  def upsale; end

  def create
    service_result = Storages::Storages::CreateService
                       .new(
                         user: current_user,
                         create_oauth_app: false,
                         contract_class: Storages::Storages::CreateContract.with_provider_contract(
                           current_step_contract(permitted_storage_params[:provider_type])
                         )
                       ).call(permitted_storage_params)

    @storage = service_result.result

    service_result.on_failure do
      update_via_turbo_stream(component: Storages::Admin::Forms::GeneralInfoFormComponent.new(@storage))
      respond_with_turbo_streams
    end

    service_result.on_success do
      redirect_to_wizard(@storage)
    end
  end

  def show_oauth_application
    if params[:continue_wizard]
      redirect_to_wizard(@storage)
    else
      redirect_to(edit_admin_settings_storage_path(@storage), status: :see_other)
    end
  end

  def edit
    @wizard = storage_wizard(@storage)
  end

  def edit_host
    update_via_turbo_stream(
      component: Storages::Admin::Forms::GeneralInfoFormComponent.new(@storage)
    )

    respond_with_turbo_streams
  end

  def edit_storage_audience
    update_via_turbo_stream(component: Storages::Admin::Forms::NextcloudAudienceFormComponent.new(@storage))
    respond_with_turbo_streams
  end

  def update # rubocop:disable Metrics/AbcSize
    contract_class = Storages::Storages::UpdateContract.with_provider_contract(current_step_contract(@storage))
    service_result = ::Storages::Storages::UpdateService
                       .new(
                         user: current_user,
                         model: @storage,
                         contract_class:
                       ).call(permitted_storage_params)

    if service_result.success?
      if params[:continue_wizard]
        redirect_to_wizard(@storage)
      else
        redirect_to(edit_admin_settings_storage_path(@storage), status: :see_other)
      end
    else
      origin_component = params[:origin_component].presence || "general_information"
      update_via_turbo_stream(
        component: ::Storages::Peripherals::Registry.resolve("#{@storage}.components.forms.#{origin_component}").new(
          @storage,
          in_wizard: params[:continue_wizard].present?
        )
      )

      @wizard = storage_wizard(@storage)
      respond_with_turbo_streams do |format|
        # FIXME: This should be a partial stream update
        format.html { render :edit }
      end
    end
  end

  def change_health_notifications_enabled
    return head :bad_request unless %w[1 0].include?(permitted_storage_params[:health_notifications_enabled])

    if @storage.update(health_notifications_enabled: permitted_storage_params[:health_notifications_enabled])
      update_via_turbo_stream(component: Storages::Admin::SidePanel::HealthNotificationsComponent.new(storage: @storage))
      respond_with_turbo_streams
    else
      flash.now[:error] = I18n.t("storages.health_email_notifications.error_could_not_be_saved")
      @wizard = storage_wizard(@storage)
      render :edit
    end
  end

  def confirm_destroy
    @storage_to_destroy = @storage
  end

  def destroy
    service_result = Storages::Storages::DeleteService
                       .new(user: User.current, model: @storage)
                       .call

    # rubocop:disable Rails/ActionControllerFlashBeforeRender
    service_result.on_failure do
      flash[:error] = service_result.errors.full_messages
    end

    service_result.on_success do
      flash[:notice] = I18n.t(:notice_successful_delete)
    end
    # rubocop:enable Rails/ActionControllerFlashBeforeRender

    redirect_to admin_settings_storages_path
  end

  def replace_oauth_application
    @storage.oauth_application.destroy
    service_result = ::Storages::OAuthApplications::CreateService.new(storage: @storage, user: current_user).call

    if service_result.success?
      @storage.oauth_application = service_result.result

      update_via_turbo_stream(component: Storages::Admin::GeneralInfoComponent.new(@storage))
      update_via_turbo_stream(component: Storages::Admin::OAuthApplicationInfoCopyComponent.new(@storage))

      respond_with_turbo_streams
    else
      @wizard = storage_wizard(@storage)
      # FIXME: This should be a partial stream update
      render :edit
    end
  end

  def default_breadcrumb; end

  def show_local_breadcrumb
    false
  end

  private

  def prepare_storage_for_access_management_form
    return unless @storage.automatic_management_unspecified?

    @storage = ::Storages::Storages::SetProviderFieldsAttributesService
                 .new(user: current_user, model: @storage, contract_class: EmptyContract)
                 .call
                 .result
  end

  def ensure_valid_wizard_parameters
    if params[:continue_wizard].present?
      @storage = ::Storages::Storage.find(params[:continue_wizard])
      return
    end

    short_provider_type = params[:provider]
    if short_provider_type.blank? || (@provider_type = ::Storages::Storage::PROVIDER_TYPE_SHORT_NAMES[short_provider_type]).blank?
      flash[:error] = I18n.t("storages.error_invalid_provider_type")
      redirect_to admin_settings_storages_path
    end
  end

  # Called by create and update above in order to check if the
  # update parameters are correctly set.
  def permitted_storage_params(model_parameter_name = storage_provider_parameter_name)
    params
      .require(model_parameter_name)
      .permit("name",
              "provider_type",
              "host",
              "authentication_method",
              "audience_configuration",
              "storage_audience",
              "oauth_client_id",
              "oauth_client_secret",
              "tenant_id",
              "drive_id",
              "automatic_management_enabled",
              "health_notifications_enabled")
  end

  def storage_provider_parameter_name
    if params.key?(:storages_nextcloud_storage)
      :storages_nextcloud_storage
    elsif params.key?(:storages_one_drive_storage)
      :storages_one_drive_storage
    else
      :storages_storage
    end
  end

  def require_ee_token_for_one_drive
    if ::Storages::Storage::one_drive_without_ee_token?(@provider_type)
      redirect_to action: :upsale
    end
  end

  def storage_wizard(storage)
    ::Storages::Peripherals::Registry.resolve("#{storage}.components.setup_wizard")
                                     .new(model: storage, user: current_user)
  end

  def redirect_to_wizard(storage)
    redirect_to(new_admin_settings_storage_path(continue_wizard: storage.id), status: :see_other)
  end

  def current_step_contract(storage)
    storage_name = storage.is_a?(String) ? ::Storages::Storage.shorten_provider_type(storage) : storage.to_s
    origin_component = params[:origin_component].presence || "general_information"

    ::Storages::Peripherals::Registry.resolve("#{storage_name}.contracts.#{origin_component}")
  end
end
