import { DeviceService } from 'core-app/core/browser/device.service';
import { scrollHeaderOnMobile } from 'core-app/core/setup/globals/global-listeners/top-menu-scroll';
import { detectOnboardingTour } from 'core-app/core/setup/globals/onboarding/onboarding_tour_trigger';
import { setupToggableFieldsets } from 'core-app/core/setup/globals/global-listeners/toggable-fieldset';
import { installMenuLogic } from 'core-app/core/setup/globals/global-listeners/action-menu';
import { listenToSettingChanges } from 'core-app/core/setup/globals/global-listeners/settings';
import { makeColorPreviews } from 'core-app/core/setup/globals/global-listeners/color-preview';
import { dangerZoneValidation } from 'core-app/core/setup/globals/global-listeners/danger-zone-validation';
import { fixFragmentAnchors } from 'core-app/core/setup/globals/global-listeners/fix-fragment-anchors';
import {
  activateFlashError,
  activateFlashNotice,
  focusFirstErroneousField,
  initMainMenuExpandStatus,
} from 'core-app/core/setup/globals/global-listeners/setup-server-response';

export function addTurboGlobalListeners() {
  document.addEventListener('turbo:load', () => {
    // Add to content if warnings displayed
    if (document.querySelector('.warning-bar--item')) {
      const content = document.querySelector('#content') as HTMLElement;
      if (content) {
        content.style.marginBottom = '100px';
      }
    }

    const deviceService:DeviceService = new DeviceService();
    // Register scroll handler on mobile header
    if (deviceService.isMobile) {
      scrollHeaderOnMobile();
    }

    // Detect and trigger the onboarding tour
    // through a lazy loaded script
    detectOnboardingTour();

    //
    // Legacy scripts from app/assets that are not yet component based
    //

    // Toggable fieldsets
    setupToggableFieldsets();

    // Action menu logic
    jQuery('.toolbar-items').each((_, menu:HTMLElement) => {
      installMenuLogic(jQuery(menu));
    });

    // Legacy settings listener
    listenToSettingChanges();

    // Color patches preview the color
    makeColorPreviews();

    // Danger zone input validation
    dangerZoneValidation();

    // Replace fragment
    fixFragmentAnchors();

    // Legacy server response setup
    initMainMenuExpandStatus();
    focusFirstErroneousField();
    activateFlashNotice();
    activateFlashError();
  });

  document.addEventListener('turbo:before-morph-element', (event) => {
    const element = event.target as HTMLElement;

    // In case the element is an OpenProject custom dom element, morphing is prevented.
    if (element.tagName.toUpperCase().startsWith('OPCE-')) {
      event.preventDefault();
    }
  });
}
