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

module Meetings
  class Index::DialogComponent < ApplicationComponent
    include ApplicationHelper
    include OpenProject::FormTagHelper
    include OpTurbo::Streamable
    include OpPrimer::ComponentHelpers

    def initialize(meeting:, project:, copy_from: nil)
      super

      @meeting = meeting
      @project = project
      @copy_from = copy_from
    end

    private

    def render?
      if @project
        User.current.allowed_in_project?(:create_meetings, @project)
      else
        User.current.allowed_in_any_project?(:create_meetings)
      end
    end

    def title
      return I18n.t(:label_meeting_copy) if @copy_from
      return I18n.t(:label_meeting_edit) if @meeting.persisted?

      case @meeting
      when RecurringMeeting
        I18n.t("label_meeting_new_recurring")
      else
        I18n.t("label_meeting_new_dynamic")
      end
    end
  end
end
