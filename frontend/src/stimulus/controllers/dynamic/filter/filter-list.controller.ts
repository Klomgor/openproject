/*
 * -- copyright
 * OpenProject is an open source project management software.
 * Copyright (C) the OpenProject GmbH
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License version 3.
 *
 * OpenProject is a fork of ChiliProject, which is a fork of Redmine. The copyright follows:
 * Copyright (C) 2006-2013 Jean-Philippe Lang
 * Copyright (C) 2010-2013 the ChiliProject Team
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 *
 * See COPYRIGHT and LICENSE files for more details.
 * ++
 */

import { Controller } from '@hotwired/stimulus';

export default class FilterListController extends Controller {
  static targets = [
    'filter',
    'searchItem',
    'noResultsText',
  ];

  static values = {
    clearButtonId: String,
  };

  declare readonly filterTarget:HTMLInputElement;
  declare readonly noResultsTextTarget:HTMLInputElement;
  declare readonly hasNoResultsTextTarget:boolean;
  declare readonly searchItemTargets:HTMLInputElement[];
  declare readonly clearButtonIdValue:string;

  connect():void {
    document.getElementById(this.clearButtonIdValue)?.addEventListener('click', () => {
      this.resetFilterViaClearButton();
    });
  }

  disconnect():void {
    document.getElementById(this.clearButtonIdValue)?.removeEventListener('click', () => {
      this.resetFilterViaClearButton();
    });
  }

  /**
   * Filters the list of items based on the input value in the filter target.
   *
   * This method converts the input value to lowercase and compares it with the text content
   * of each search item. To avoid unwanted text from being part of the search string. E.g. the
   * labels of buttons, the method first tries to find an element with the class `filter-target-visible-text`.
   * If such an element exists, only the content of that element is used for the search.
   * If the text content includes the input value, the item is shown;
   * otherwise, it is hidden. Additionally, it controls the visibility of the no results text
   * based on whether any items match the input value.
   */
  filterLists() {
    const query = this.filterTarget.value.toLowerCase();
    let showNoResultsText = true;

    this.searchItemTargets.forEach((item) => {
      const text = item.querySelector('.filter-target-visible-text')?.textContent?.toLowerCase() || item.textContent?.toLowerCase();

      if (text?.includes(query)) {
        this.setVisibility(item, true);
        showNoResultsText = false;
      } else {
        this.setVisibility(item, false);
      }
    });

    if (this.hasNoResultsTextTarget) {
      this.setVisibility(this.noResultsTextTarget, showNoResultsText);
    }
  }

  resetFilterViaClearButton() {
    this.searchItemTargets.forEach((item) => {
      this.setVisibility(item, true);
    });
  }

  setVisibility(element:HTMLElement, visible:boolean) {
    element.classList.toggle('d-none', !visible);
  }
}
