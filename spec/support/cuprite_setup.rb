# frozen_string_literal: true

# -- copyright
# OpenProject is an open source project management software.
# Copyright (C) 2023 the OpenProject GmbH
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
# ++
#

require 'capybara/cuprite'

def headful_mode?
  ActiveRecord::Type::Boolean.new.cast(ENV.fetch('OPENPROJECT_TESTING_NO_HEADLESS', nil))
end

def headless_mode?
  !headful_mode?
end

def register_better_cuprite(language, name: :"better_cuprite_#{language}")
  Capybara.register_driver(name) do |app|
    options = {
      process_timeout: 10,
      inspector: true,
      headless: headless_mode?
    }
    options = options.merge(window_size: [1920, 1080]) if headless_mode?

    if ENV['CHROME_URL'].present?
      options = options.merge(url: ENV['CHROME_URL'])
    end

    browser_options = {
      'no-sandbox': nil,
      'disable-gpu': nil,
      'disable-popup-blocking': nil,
      'disable-dev-shm-usage': nil,
      lang: language
    }

    if ENV['OPENPROJECT_TESTING_AUTO_DEVTOOLS'].present?
      browser_options = browser_options.merge('auto-open-devtools-for-tabs': nil)
    end

    driver_options = options.merge(browser_options:)

    Capybara::Cuprite::Driver.new(app, **driver_options)
  end

  Capybara::Screenshot.register_driver(name) do |driver, path|
    driver.save_screenshot(path)
  end
end

register_better_cuprite 'en'

RSpec.configure do |config|
  config.around(:each, type: :feature, with_cuprite: true) do |example|
    original_driver = Capybara.javascript_driver
    Capybara.javascript_driver = :better_cuprite_en

    example.run

    Capybara.javascript_driver = original_driver
  end
end
