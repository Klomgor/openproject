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

import {
  ChangeDetectorRef,
  ChangeDetectionStrategy,
  Component,
  ElementRef,
  OnInit,
} from '@angular/core';
import { distinctUntilChanged } from 'rxjs/operators';
import { I18nService } from 'core-app/core/i18n/i18n.service';
import { EnterpriseTrialService } from 'core-app/features/enterprise/enterprise-trial.service';
import {
  HttpClient,
  HttpErrorResponse,
} from '@angular/common/http';
import { EEActiveTrialBase } from 'core-app/features/enterprise/enterprise-active-trial/ee-active-trial.base';
import { GonService } from 'core-app/core/gon/gon.service';
import { EXTERNAL_REQUEST_HEADER } from 'core-app/features/hal/http/openproject-header-interceptor';
import { IEnterpriseData } from 'core-app/features/enterprise/enterprise-trial.model';

@Component({
  selector: 'enterprise-active-trial',
  templateUrl: './ee-active-trial.component.html',
  styleUrls: ['./ee-active-trial.component.sass'],
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class EEActiveTrialComponent extends EEActiveTrialBase implements OnInit {
  public subscriber:string;

  public email:string;

  public company:string;

  public domain:string;

  public userCount:string;

  public startsAt:string;

  public expiresAt:string;

  public plan:string;

  public additionalFeatures:string;

  constructor(
    readonly elementRef:ElementRef,
    readonly cdRef:ChangeDetectorRef,
    readonly I18n:I18nService,
    readonly http:HttpClient,
    readonly Gon:GonService,
    public eeTrialService:EnterpriseTrialService,
  ) {
    super(I18n);
  }

  ngOnInit() {
    if (!this.subscriber) {
      void this.eeTrialService.userData$
        .pipe(
          distinctUntilChanged(),
          this.untilDestroyed(),
        )
        .subscribe((data:IEnterpriseData) => {
          this.formatUserData(data);
          this.cdRef.detectChanges();
        });

      this.initialize();
    }
  }

  private initialize():void {
    const eeTrialKey = this.Gon.get('ee_trial_key') as { value:string } | undefined;
    const { data } = this.eeTrialService.current;

    if (eeTrialKey && !data) {
      // after reload: get data from Augur using the trial key saved in gon
      const trialLink = `${this.eeTrialService.baseUrlAugur}/public/v1/trials/${eeTrialKey.value}`;
      this.eeTrialService.store.update({ trialLink });
      this.getUserDataFromAugur(trialLink);
    }
  }

  // use the trial key saved in the db
  // to get the user data from Augur
  private getUserDataFromAugur(trialLink:string) {
    this
      .http
      .get(
        `${trialLink}/details`,
        {
          headers: {
            [EXTERNAL_REQUEST_HEADER]: 'true',
          },
        },
      )
      .toPromise()
      .then((data:IEnterpriseData) => {
        this.eeTrialService.store.update({ data });
        this.eeTrialService.retryConfirmation();
      })
      .catch(() => {
        // Check whether the mail has been confirmed by now
        this.eeTrialService.getToken();
      });
  }

  private formatUserData(userForm:IEnterpriseData) {
    this.subscriber = `${userForm.first_name} ${userForm.last_name}`;
    this.email = userForm.email;
    this.company = userForm.company;
    this.domain = userForm.domain;
  }
}
