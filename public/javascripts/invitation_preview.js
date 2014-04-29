/* Use an immediately invoked function to isolate variables */
(function(jQuery){

  jQuery(function() {
    jQuery('#invitation_preview').on('click', function(e) {
      loadModal('vocModal');
    });
    console.log("on click added.");
  });

  /*
  ============================================
  License for Application
  ============================================
  This license is governed by United States copyright law, and with respect to matters
  of tort, contract, and other causes of action it is governed by North Carolina law,
  without regard to North Carolina choice of law provisions. The forum for any dispute
  resolution shall be in Wake County, North Carolina.
  Redistribution and use in source and binary forms, with or without modification, are
  permitted provided that the following conditions are met:
  1. Redistributions of source code must retain the above copyright notice, this list
  of conditions and the following disclaimer.
  2. Redistributions in binary form must reproduce the above copyright notice, this
  list of conditions and the following disclaimer in the documentation and/or other
  materials provided with the distribution.
  3. The name of the author may not be used to endorse or promote products derived from
  this software without specific prior written permission.
  THIS SOFTWARE IS PROVIDED BY THE AUTHOR "AS IS" AND ANY EXPRESS OR IMPLIED
  WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY
  AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR BE
  LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
  DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
  THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
  ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
  */

  // jQuery formatted selector to search for focusable items
  var focusableElementsString = "a[href], area[href], input:not([disabled]), select:not([disabled]), textarea:not([disabled]), button:not([disabled]), iframe, object, embed, *[tabindex], *[contenteditable]";

  // store the item that has focus before opening the modal window
  var focusedElementBeforeModal;

  function acceptText() {
    var text = jQuery('#survey_invitation_accept_button_text').val();
    if(text.length > 0 ) {
      return text;
    } else {
      return "Yes";
    }
  }

  function rejectText() {
    var text = jQuery('#survey_invitation_reject_button_text').val();
    if(text.length > 0 ) {
      return text;
    } else {
      return "No";
    }
  }

  function loadModal(target_id) {
    var modalHTML = jQuery("#survey_invitation_text").text();

    if(modalHTML.length > 0) {
      modalHTML = modalHTML.replace("{{accept}}",
        '<input type="button" name="vocEnter" id="vocEnter" value="' + acceptText() + '">');
      modalHTML = modalHTML.replace("{{reject}}",
        '<input type="button" name="vocCancelButton" class="vocCancelButton" value="' + rejectText() + '">')


      jQuery('#' + target_id).html(modalHTML);
    }


    showModal(jQuery('#vocModal'));
    jQuery('#startModal').click(function(e) {
        showModal(jQuery('#vocModal'));
    });
    jQuery('#cancel').click(function(e) {
        hideModal();
        e.preventDefault();
    });
    jQuery('.vocCancelButton').click(function(e) {
        hideModal();
        e.preventDefault();
    });
    jQuery('#vocEnter').click(function(e) {
        enterButtonModal();
    });
    jQuery('#vocModalCloseButton').click(function(e) {
        hideModal();
    });
    jQuery('#vocModalCloseButton').keydown(function(event) {
        trapSpaceKey(jQuery(this), event, hideModal);
    });
    jQuery('#vocModal').keydown(function(event) {
        trapTabKey(jQuery(this), event);
    });
    jQuery('#vocModal').keydown(function(event) {
        trapEscapeKey(jQuery(this), event);
    });

  }


  function trapSpaceKey(obj, evt, f) {
      // if space key pressed
      if (evt.which == 32) {
          // fire the user passed event
          f();
          evt.preventDefault();
      }
  }

  function trapEscapeKey(obj, evt) {

      // if escape pressed
      if (evt.which == 27) {

          // get list of all children elements in given object
          var o = obj.find('*');

          // get list of focusable items
          var cancelElement;
          cancelElement = o.filter("#cancel")

          // close the modal window
          cancelElement.click();
          evt.preventDefault();
      }

  }

  function trapTabKey(obj, evt) {

      // if tab or shift-tab pressed
      if (evt.which == 9) {

          // get list of all children elements in given object
          var o = obj.find('*');

          // get list of focusable items
          var focusableItems;
          focusableItems = o.filter(focusableElementsString).filter(':visible')

          // get currently focused item
          var focusedItem;
          focusedItem = jQuery(':focus');

          // get the number of focusable items
          var numberOfFocusableItems;
          numberOfFocusableItems = focusableItems.length

          // get the index of the currently focused item
          var focusedItemIndex;
          focusedItemIndex = focusableItems.index(focusedItem);

          if (evt.shiftKey) {
              //back tab
              // if focused on first item and user preses back-tab, go to the last focusable item
              if (focusedItemIndex == 0) {
                  focusableItems.get(numberOfFocusableItems - 1).focus();
                  evt.preventDefault();
              }

          } else {
              //forward tab
              // if focused on the last item and user preses tab, go to the first focusable item
              if (focusedItemIndex == numberOfFocusableItems - 1) {
                  focusableItems.get(0).focus();
                  evt.preventDefault();
              }
          }
      }

  }

  function setInitialFocusModal(obj) {
      // get list of all children elements in given object
      var o = obj.find('*');

      // set focus to first focusable item
      var focusableItems;
      focusableItems = o.filter(focusableElementsString).filter(':visible').first().focus();

  }

  function enterButtonModal() {
    hideModal();
  }

  function showModal(obj) {
      jQuery('#mainPage').attr('aria-hidden', 'true'); // mark the main page as hidden
      jQuery('#vocModalOverlay').css('display', 'block'); // insert an overlay to prevent clicking and make a visual change to indicate the main apge is not available
      jQuery('#vocModal').css('display', 'block'); // make the modal window visible
      jQuery('#vocModal').attr('aria-hidden', 'false'); // mark the modal window as visible

      // save current focus
      focusedElementBeforeModal = jQuery(':focus');

      // get list of all children elements in given object
      var o = obj.find('*');

      // Safari and VoiceOver shim
      // if VoiceOver in Safari is used, set the initial focus to the modal window itself instead of
      // the first keyboard focusable item. This causes VoiceOver to announce the aria-labelled
      // attributes. Otherwise, Safari and VoiceOver will not announce the labels attached to the
      // modal window.

      // set the focus to the first keyboard focusable item
      o.filter(focusableElementsString).filter(':visible').first().focus();


  }

  function hideModal() {
      jQuery('#vocModalOverlay').css('display', 'none'); // remove the overlay in order to make the main screen available again
      jQuery('#vocModal').css('display', 'none'); // hide the modal window
      jQuery('#vocModal').attr('aria-hidden', 'true'); // mark the modal window as hidden
      jQuery('#mainPage').attr('aria-hidden', 'false'); // mark the main page as visible

      // set focus back to element that had it before the modal was opened
      focusedElementBeforeModal.focus();
  }

})(jQuery);
