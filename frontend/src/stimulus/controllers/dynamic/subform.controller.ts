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

export default class SubformController extends Controller {
  static targets = [
    'template',
    'table',
  ];

  declare readonly tableTarget:HTMLTableElement;

  private rowTemplate:HTMLElement;

  connect() {
    // We can't use a target as we duplicate the "template" without  much cleaning up
    const item = this.element.querySelector('[data-row-target]') as HTMLElement;
    this.rowTemplate = item;
    item.remove();
  }

  deleteRow(evt:Event) {
    const row = (evt.target as HTMLElement).closest('tr');
    row?.remove();
  }

  addRow() {
    const index = this.itemCount;
    const newRow = this.rowTemplate.cloneNode(true) as HTMLElement;
    this.tableTarget.appendChild(newRow);
    newRow.style.removeProperty('display');
    newRow.outerHTML = newRow.outerHTML.replace(/INDEX/g, index.toString());

    // Autofocus
    setTimeout(() => newRow.querySelector<HTMLElement>('input')?.focus(), 10);
  }

  get itemCount():number {
    return this.tableTarget.querySelectorAll('tr').length;
  }
}
