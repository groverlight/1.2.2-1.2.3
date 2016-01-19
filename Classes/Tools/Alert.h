
//! \file   Alert.h
//! \brief  Display an alert on the screen.
//__________________________________________________________________________________________________

#import "Blocks.h"
//__________________________________________________________________________________________________

//! Display an alert with the specified title and message. Show up to two buttons.
id Alert
(
  NSString*       title,                //!< The title of the alert to display.
  NSString*       message,              //!< The message of the the alert to display.
  NSString*       ok_button_title,      //!< The title of the OK button, or nil if not used.
  NSString*       cancel_button_title,  //!< The title of the Cancel button, or nil if not used.
  BlockIntAction  clicked_button_block  //!< The block to call when a button is pressed.
);
//__________________________________________________________________________________________________
