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

class Relations::DeleteService < BaseServices::Delete
  def after_perform(_result)
    result = super
    if result.success? && successor_must_switch_to_manual_mode?
      deleted_relation.successor.update(schedule_manually: true)
    end
    result
  end

  private

  def deleted_relation
    model
  end

  def successor_must_switch_to_manual_mode?
    deleted_relation.follows? \
      && successor_has_dates? \
      && was_last_relation_to_the_successor?
  end

  def successor_has_dates?
    deleted_relation.successor.start_date.present? || deleted_relation.successor.due_date.present?
  end

  def was_last_relation_to_the_successor?
    Relation.follows.of_successor(deleted_relation.successor).none?
  end
end
