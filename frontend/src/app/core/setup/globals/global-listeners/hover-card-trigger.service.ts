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

import { Injectable, Injector, NgZone } from '@angular/core';
import { computePosition, flip, limitShift, shift } from '@floating-ui/dom';

@Injectable({ providedIn: 'root' })
export class HoverCardTriggerService {
  private mouseInModal = false;
  private hoverTimeout:number|null = null;
  private closeTimeout:number|null = null;
  private previousTarget:HTMLElement|null = null;

  // Track whether we currently show a hover card or not. It is important not to open multiple hover cards at
  // the same time, and refrain from closing the wrong kind of modal overlay.
  private isShowingHoverCard:boolean = false;

  // The time you need to keep hovering over a trigger before the hover card is shown
  OPEN_DELAY_IN_MS = 1000;
  // The time you need to keep away from trigger/hover card before an opened card is closed
  CLOSE_DELAY_IN_MS = 250;

  constructor(
    readonly ngZone:NgZone,
    readonly injector:Injector,
  ) {
  }

  setupListener() {
    jQuery(document.body).on('mouseover', '.op-hover-card--preview-trigger', (e) => {
      e.preventDefault();
      e.stopPropagation();

      // eslint-disable-next-line @typescript-eslint/no-unsafe-assignment
      const el = e.target as HTMLElement;
      if (!el) { return; }

      if (this.previousTarget && this.previousTarget === el) {
        // Re-entering the trigger counts as hovering over the card:
        this.mouseInModal = true;
        // But we will not re-render the same card, abort here
        return;
      }

      // Hovering over a new target. Close the old one (if any).
      this.close(true);

      const turboFrameUrl = this.parseHoverCardUrl(el);
      if (!turboFrameUrl) { return; }

      // Reset close timer for when hovering over multiple triggers in quick succession.
      // A timer from a previous hover card might still be running. We do not want it to
      // close the new (i.e. this) hover card.
      this.clearCloseTimer();

      // Set a delay before showing the hover card
      this.hoverTimeout = window.setTimeout(() => {
        this.showHoverCard(el, turboFrameUrl);
      }, this.OPEN_DELAY_IN_MS);
    });

    jQuery(document.body).on('mouseleave', '.op-hover-card--preview-trigger', () => {
      this.clearHoverTimer();
      this.mouseInModal = false;
      this.closeAfterTimeout();
    });

    jQuery(document.body).on('mouseleave', '.op-hover-card', () => {
      this.clearHoverTimer();
      this.mouseInModal = false;
      this.closeAfterTimeout();
    });

    jQuery(document.body).on('mouseenter', '.op-hover-card', () => {
      this.mouseInModal = true;
    });
  }

  private showHoverCard(el:HTMLElement, turboFrameUrl:string) {
    // Abort if the element is no longer present in the DOM. This can happen when this method is called after a delay.
    if (!document.body.contains(el)) { return; }
    // Do not try to show two hover cards at the same time.
    if (this.isShowingHoverCard) { return; }

    this.loadAndShowHoverCard(el, turboFrameUrl);
  }

  private loadAndShowHoverCard(el:HTMLElement, turboFrameUrl:string) {
    const overlay = jQuery('#hover-card-overlay').get(0);
    if (!overlay) { return; }

    overlay.innerHTML = '';

    const div = document.createElement('div');
    div.className = 'op-hover-card';
    overlay.appendChild(div);

    const turboFrame = document.createElement('turbo-frame');
    turboFrame.id = 'op-hover-card-body';
    div.appendChild(turboFrame);
    turboFrame.setAttribute('src', turboFrameUrl);

    this.isShowingHoverCard = true;
    this.previousTarget = el;

    this.setOpacity(div, 0);

    turboFrame.addEventListener('turbo:frame-load', () => {
      void this.reposition(div, el);

      // Content has been loaded, card has been positioned. Show it!
      this.setOpacity(div, 1);
    });
  }

  private setOpacity(element:HTMLElement, opacity:number) {
    element.style.opacity = opacity.toString();
  }

  private async reposition(element:HTMLElement, target:HTMLElement) {
    const floatingEl = element;

    const { x, y } = await computePosition(
      target,
      floatingEl,
      {
        placement: 'top',
        middleware: [
          flip({
            mainAxis: true,
            crossAxis: true,
            fallbackAxisSideDirection: 'start',
          }),
          shift({ limiter: limitShift() }),
        ],
      },
    );
    Object.assign(floatingEl.style, {
      left: `${x}px`,
      top: `${y}px`,
    });
  }

  // Should be called when the mouse leaves the hover-zone so that we no longer attempt ot display the hover card.
  private clearHoverTimer() {
    if (this.hoverTimeout) {
      clearTimeout(this.hoverTimeout);
      this.hoverTimeout = null;
    }
  }

  private clearCloseTimer() {
    if (this.closeTimeout) {
      clearTimeout(this.closeTimeout);
      this.closeTimeout = null;
    }
  }

  private closeAfterTimeout() {
    this.ngZone.runOutsideAngular(() => {
      this.closeTimeout = window.setTimeout(() => {
        this.close();
      }, this.CLOSE_DELAY_IN_MS);
    });
  }

  private close(forceClose=false) {
    if (forceClose) {
      this.mouseInModal = false;
    }

    // It is important to check if we are currently showing a hover card. If we closed the modal service without
    // doing so, we might accidentally close another modal (e.g. share dialog).
    if (this.isShowingHoverCard && !this.mouseInModal) {
      const overlay = jQuery('#hover-card-overlay').get(0);
      if (!overlay) { return; }
      overlay.innerHTML = '';

      this.isShowingHoverCard = false;
      // Allow opening this target once more, since it has been orderly closed
      this.previousTarget = null;
    }
  }

  private parseHoverCardUrl(el:HTMLElement) {
    return el.getAttribute('data-hover-card-url');
  }
}
