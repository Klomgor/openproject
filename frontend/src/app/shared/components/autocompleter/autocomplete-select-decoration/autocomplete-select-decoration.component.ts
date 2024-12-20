//-- copyright
// OpenProject is an open source project management software.
// Copyright (C) the OpenProject GmbH
//
// This program is free software; you can redistribute it and/or
// modify it under the terms of the GNU General Public License version 3.
//
// OpenProject is a fork of ChiliProject, which is a fork of Redmine. The copyright follows:
// Copyright (C) 2006-2013 Jean-Philippe Lang
// Copyright (C) 2010-2013 the ChiliProject Team
//
// This program is free software; you can redistribute it and/or
// modify it under the terms of the GNU General Public License
// as published by the Free Software Foundation; either version 2
// of the License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program; if not, write to the Free Software
// Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
//
// See COPYRIGHT and LICENSE files for more details.
//++

import { AfterViewInit, Component, Input, OnInit, ViewChild } from '@angular/core';
import { NgSelectComponent } from '@ng-select/ng-select';
import {
  IAutocompleteItem,
  OpAutocompleterComponent,
} from 'core-app/shared/components/autocompleter/op-autocompleter/op-autocompleter.component';
import { populateInputsFromDataset } from 'core-app/shared/components/dataset-inputs';

type SelectItem = { label:string, value:string, selected?:boolean };

export const autocompleteSelectDecorationSelector = 'autocomplete-select-decoration';

@Component({
  template: `
    <ng-select
      [items]="options"
      [labelForId]="labelForId"
      bindLabel="label"
      [multiple]="multiple"
      [virtualScroll]="true"
      [ngModel]="selected"
      [appendTo]="appendTo"
      [placeholder]="text.placeholder"
      (ngModelChange)="updateSelection($event)">
      <ng-template ng-option-tmp let-item="item" let-index="index">
        {{ item.label }}
      </ng-template>
    </ng-select>
  `,
  selector: autocompleteSelectDecorationSelector,
})
export class AutocompleteSelectDecorationComponent extends OpAutocompleterComponent<IAutocompleteItem> implements OnInit, AfterViewInit {
  @ViewChild(NgSelectComponent) public ngSelectComponent:NgSelectComponent;

  public options:SelectItem[];

  /** Get the selected options */
  public selected:SelectItem|SelectItem[];

  /** The field key (e.g. status, type, or project)  */
  @Input() key:string;

  text = {
    placeholder: this.I18n.t('js.placeholders.selection'),
  };

  ngOnInit():void {
    populateInputsFromDataset(this);
    const element = this.elementRef.nativeElement as HTMLElement;

    // Add Rails multiple identifier if multiple
    if (this.multiple) {
      this.inputName += '[]';
    }

    // Prepare and build the options
    // Expected array of objects with id, name, select
    const data:SelectItem[] = JSON.parse(element.dataset.options!);

    // Set initial selection
    this.setInitialSelection(data);

    if (!this.multiple) {
      this.selected = (this.selected as SelectItem[])[0];
    }

    this.options = data;

    // Unhide the parent
    element.parentElement!.hidden = false;
  }

  // eslint-disable-next-line @angular-eslint/no-empty-lifecycle-method
  ngAfterViewInit():void {
    // do nothing and prevent the parent hook to be called
  }

  setInitialSelection(data:SelectItem[]):void {
    this.updateSelection(data.filter((element) => element.selected));
  }

  updateSelection(items:SelectItem|SelectItem[]):void {
    this.selected = items;
    items = _.castArray(items);

    this.removeCurrentSyncedFields();
    items.forEach((el:SelectItem) => {
      this.createSyncedField(el.value);
    });
  }

  createSyncedField(value:string):void {
    const element = jQuery(this.elementRef.nativeElement);
    element
      .parent()
      .append(`<input type="hidden" name="${this.inputName || ''}" value="${value}" />`);
  }

  removeCurrentSyncedFields():void {
    const element = jQuery(this.elementRef.nativeElement);
    element
      .parent()
      .find(`input[name="${this.inputName}"]`)
      .remove();
  }
}
