
//! \file   GlobalParameters.h
//! \brief  All the App parameters are declared here.
//__________________________________________________________________________________________________

#import <UIKit/UIKit.h>

#import "Blocks.h"
#import "PopBaseView.h"
//__________________________________________________________________________________________________

//! All the App parameters are declared here.
@interface GlobalParameters: NSObject
{
}
//____________________

// Common parameters.
@property UIColor*            primaryButtonColor;                   //!< Main color used for the buttons. In the specs, looks like milked cyan.
@property UIColor*            secondaryButtonColor;                 //!< Secondary color used for buttons. In the specs, looks violet.
@property UIColor*            disabledButtonColor;
//____________________

// Gradient parameters;
@property UIColor*            gradientTopColor;
@property UIColor*            gradientBottomColor;
@property CGFloat             gradientAlpha;
//____________________

// Circled images parameters.
@property CGFloat             circleLiveRadius;
@property CGFloat             circleFriendRadius;
//____________________

// Separator line parameters.
@property CGFloat             separatorLineWidth;
@property UIColor*            separatorLineColor;
@property CGFloat             separatorLineSideMargin;
//____________________

// White button parameters.
@property CGFloat             whiteButtonBounceScaleFactor;
@property CGFloat             whiteButtonHeight;
@property CGFloat             whiteButtonFontSize;
@property UIColor*            whiteButtonIdleColor;
@property UIColor*            whiteButtonHighlightedColor;
@property UIColor*            whiteButtonDisabledColor;
@property CGFloat             whiteButtonBounceDuration;
@property PopAnimParameters*  whiteButtonAnimParameters;
//____________________

// Header bar parameters.
@property NSString*           headerLeftLabelTitle;
@property NSString*           headerCenterLabelTitle;
@property NSString*           headerRightLabelTitle;
@property CGFloat             headerHeight;
@property CGFloat             headerTopMargin;
@property CGFloat             headerSideMargin;
@property CGFloat             headerUnderlineHeight;
@property CGFloat             headerUnderlineGap;
@property UIColor*            headerUnderlineColor;
@property PopAnimParameters*  headerUnderlineAnimParameters;
//____________________

// HeaderButton parameters.
@property CGFloat             headerButtonBounceScaleFactor;
@property CGFloat             headerButtonFontSize;
@property UIColor*            headerButtonIdleColor;
@property UIColor*            headerButtonHighlightedColor;
@property UIColor*            headerButtonSelectedColor;
@property UIColor*            headerButtonDisabledColor;
@property CGFloat             headerButtonDotRadius;
@property CGFloat             headerButtonHighlightedDotRadius;
@property UIColor*            headerButtonDotColor;
@property CGFloat             headerButtonDotFadeDuration;
@property CGFloat             headerButtonDotHorizontalOffset;
@property CGFloat             headerButtonDotVerticalOffset;
@property PopAnimParameters*  headerButtonAnimParameters;
@property PopAnimParameters*  headerButtonDotAnimParameters;
//____________________

// Network activity indicator parameters.
@property UIColor*            networkActivityBackgroundColor;
@property CGFloat             networkActivityBackgroundOpacity;
@property UIColor*            networkActivityWheelColor;
//____________________

// Navigator parameters.
@property BOOL                navigatorScrollViewBounces;
//____________________

// Friend lists parameters.
@property CGFloat         friendsTopBarBorderOffset;
@property CGFloat         friendsTopBarTopOffset;
@property UIFont*         friendsUsernameFont;
@property UIFont*         friendsUsernameMediumFont;
@property UIColor*        friendsUsernameTextColor;
@property UIColor*        friendsSelectedUsernameTextColor;
@property CGFloat         friendsPhotoRadius;
@property CGFloat         friendsPhotoLeftMargin;
@property CGFloat         friendsTextLeftMargin;
@property CGFloat         friendsTextLeftMarginNoPhoto;
@property CGFloat         friendsStateViewLeftMargin;
@property CGFloat         friendsStateViewRightMargin;
@property CGFloat         friendsListRowHeight;
@property CGFloat         friendsListHeaderHeight;
@property CGFloat         friendsListHeaderTextLeftMargin;
@property UIFont*         friendsListHeaderTextFont;
@property UIColor*        friendsListHeaderTextColor;
@property UIColor*        friendsListHeaderBackgroundColor;
@property UIColor*        friendsListBackgroundColor;
@property UIColor*        friendsListSeparatorColor;
@property CGFloat         friendsListSeparatorHeight;
@property CGFloat         friendsListSeparatorBorderMargin;
@property NSString*       friendsListRecentSectionHeaderTitle;
@property NSString*       friendsListAllSectionHeaderTitle;
@property CGFloat         friendsListParseRefreshThresholdOffset;
@property CGFloat         friendsProgressRadius;
@property CGFloat         friendsProgressLineWidth;
@property UIColor*        friendsProgressStrokeColor;
@property UIColor*        friendsProgressFillColor;
@property CGFloat         friendsProgressDuration;
@property NSString*       friendsSendToLabelTitle;
@property NSString*       friendsA_ZLabelTitle;
@property NSString*       friendsActivityLabelTitle;
@property UIColor*        friendsLabelTitleColor;
@property CGFloat         friendsLabelTitleFontSize;
@property NSInteger       friendsMaxRecentFriends;
@property NSString*       friendsEditorPlaceholderText;
@property CGFloat         friendsEditorFontSize;
@property CGFloat         friendsEditorHeight;
@property CGFloat         friendsEditorLeftMargin;
@property CGFloat         friendsInviteFriendButtonWidth;
@property CGFloat         friendsAddFriendButtonLateralMargin;
@property CGFloat         friendsInviteButtonBottomGap;
@property CGFloat         friendsAddButtonBottomGap;
@property NSString*       friendsInviteButtonTitle;
@property NSString*       friendsAddButtonTitle;
@property CGFloat          faceButtonWidth;
//____________________

// FriendListItemStateView parameters.
@property CGFloat             friendStateViewCircleLineWidth;
@property CGFloat             friendStateViewCircleRadius;
@property CGFloat             friendStateViewProgressCircleRadius;
@property CGFloat             friendStateViewDiskRadius;
@property CGFloat             friendStateViewProgressDiskRadius;
@property UIColor*            friendStateViewColor;
@property CGFloat             friendStateViewProgressAnimationDuration;
@property PopAnimParameters*  friendStateViewAnimParameters;
//____________________

// Friend menu parameters.
@property NSString*           friendMenuRemoveFriendTitle;
@property NSString*           friendMenuBlockFriendTitle;
@property NSString*           friendMenuCancelTitle;
//____________________

// Add friend parameters.
@property BOOL                addFriendAutoSearch;
@property BOOL                addFriendIgnoreBlankSpaces;
@property BOOL                addFriendAllLowercase;
//____________________

// ThreeDotsPseudoButtonView parameters.
@property CGFloat             threeDotsPseudoButtonDotRadius;
@property CGFloat             threeDotsPseudoButtonDotInterval;
@property CGFloat             threeDotsPseudoButtonHighlightedScaleFactor;
@property UIColor*            threeDotsPseudoButtonColor;
@property PopAnimParameters*  ThreeDotsPseudoButtonAnimParameters;
//____________________

// Camera control parameters.
@property CGFloat         cameraExposureTargetBias;             //!< Auto exposure compensation.
@property BOOL            cameraManualExposureEnabled;          //!< If YES, the following parameters are used to control the camera exposure settings.
@property BOOL            cameraAutoVideoHdrEnabled;
@property BOOL            cameraLowLightBoostEnabled;
@property CGFloat         cameraExposureDuration;
@property CGFloat         cameraIso;
@property BOOL            cameraManualWhiteBalanceEnabled;      //!< If YES, the following parameters are used to control the camera white balance settings.
@property CGFloat         cameraWhiteBalanceRedGain;
@property CGFloat         cameraWhiteBalanceGreenGain;
@property CGFloat         cameraWhiteBalanceBlueGain;
@property CGFloat         cameraUseBackCamera;                  //!< If YES, uses the back camera for taking the snapshots.
//____________________

// New editor parameters.
@property UIColor*        typingBackgroundColor;                //!< Color of the editor's background area.
@property UIColor*        typingValidatedBackgroundColor;       //!< Color of the validated text's background area.
@property CGFloat         typingTopBarBorderOffset;
@property CGFloat         typingTopBarTopOffset;
@property NSString*       typingFaceButtonTitle;                //!< Title of the FACE button. In the specs, shows FACE.
@property NSInteger       typingMaxCharacterCount;              //!< Maximal number of characters that can be entered in the editor.
@property NSInteger       typingFontSizeCharacterCountTrigger;  //!< The character count limit that triggers the font size change.
@property CGFloat         typingCharacterCountFontSize;         //!< The font size of the label that displays the remaining character count.
@property UIColor*        typingCharacterCountColor;            //!< The color of the label that displays the remaining character count.
@property CGFloat         typingCharacterCountRightMargin;      //!< Margin on the right of the label that displays the remaining character count.
@property UIColor*        typingTextColor;                      //!< Color of the edited text in the typing screen.
@property UIColor*        typingValidatedTextColor;             //!< Color of the edited text in the typing screen.
@property UIColor*        typingValidatedTextBackgroundColor;   //!< Background color of the already validated text blocks.
@property UIColor*        typingCursorColor;                    //!< Color used for the typing screen editor cursor. In the specs, looks pinky purple.
@property UIFont*         typingFont;                           //!< Font used for the large part of the text.
@property CGFloat         typingLargeFontSize;                  //!< Font used for the large part of the text.
@property CGFloat         typingSmallFontSize;                  //!< Font used for the small part of the text.
@property UIFont*         TypingButtonFont;                     //!< The font used to render the TAB/HOLD/LETGO buttons labels.
@property UIColor*        TypingButtonColor;                    //!< Ths color used to render the TAB/HOLD/LETGO buttons labels.
@property NSString*       typingLeftButtonAlertTitle;           //!< The title string of the one time alert related to the left button.
@property NSString*       typingLeftButtonAlertMessage;         //!< The message string of the one time alert related to the left button.
@property NSString*       typingLeftButtonAlertOkString;        //!< The OK string of the one time alert related to the left button.
@property NSString*       typingLeftButtonAlertCancelString;    //!< The CANCEL string of the one time alert related to the left button.
@property NSString*       typingRightButtonAlertTitle;          //!< The title string of the one time alert related to the right button.
@property NSString*       typingRightButtonAlertMessage;        //!< The message string of the one time alert related to the right button.
@property NSString*       typingRightButtonAlertOkString;       //!< The OK string of the one time alert related to the right button.
@property NSString*       typingRightButtonAlertCancelString;   //!< The CANCEL string of the one time alert related to the right button.
@property CGFloat         typingTextBlockGap;                   //!< The additional gap between the two blocks of text.
@property CGFloat         typingTopOffset;                      //!< The vertical offset from the header bar to the editor area.
@property CGFloat         typingFaceButtonGap;                  //!< The vertical gap above and below the FACE Button.
@property CGFloat         typingFaceButtonLateralMargin;        //!< The lateral distance between the screen border and the FACE button.
@property CGFloat         typingEditorLateralMargin;            //!< The lateral distance between the screen border and the editor area.
@property CGFloat         typingForceCapitalizingFirstChar;     //!< When YES, forces the first letter of a chunk to always be capitalized.
@property CGFloat         typingSnapshotFlashDuration;          //!< The duration of the screen flash when taking a snapshot.
@property CGFloat         typingHideKeyboardDuringFlash;        //!< When YES, the keyboard is hidden during screen flash.
//____________________

// Player parameters.
@property CGFloat             playerLabelCenterOffsetFromBottom;    //!< The vertical distance betten the bottom of the screen to the center of the text label.
@property CGFloat             playerLabelLateralMargin;             //!< The lateral distance between the screen border and the text label.
@property CGFloat             playerShortTextFontSize;
@property CGFloat             playerLongTextFontSize;
@property UIColor*            playerTextColor;
@property NSInteger           playerFontSizeCharacterCountTrigger;  //!< The character count limit that triggers the font size change.
@property PopAnimParameters*  playerCircleToScreenAnimParameters;
@property PopAnimParameters*  playerChunkColorIntroAnimParameters;
@property PopAnimParameters*  playerChunkColorLeaveAnimParameters;
@property PopAnimParameters*  playerChunkScaleIntroAnimParameters;
@property PopAnimParameters*  playerChunkScaleLeaveAnimParameters;
@property NSInteger           playerShortTextLength;
@property CGFloat             playerAdjustmentRatio;
@property UIFont*             playerFont;

// Snapshots parameters.
@property CGFloat           dimmedGradientAlpha;                  //!< The alpha factor to apply to the background gradient to let see the underlying picture or live camera feed. Defaults to 0.85.
@property CGFloat           jpegCompressionQuality;               //!< The jpeg compression quality of the Parse saved snapshots. Defaults to 0.8 and internally limited to 0.9.
//____________________

// Notification parameters.
@property NSString*         parseNotificationFormatString;              //!< The format for the remote notification message.
@property NSString*         parseRemoveFriendNotificationFormatString;  //!< The format for the remote notification message when removing friend.
//____________________

// Blocked user parameters.
@property NSString*         blockedUserReasonMessage;
//____________________

// Login parameters.
@property NSString*         customizableLoginLabel;             //!< Content of the label placed on top of the login screen.
@property NSString*         selectCountryMessage;               //!< Content of the second label from top of the login screen when the country selector is visible.
@property NSString*         phoneNumberPlaceholder;             //!< Phone number editor placeholder string.
@property NSString*         verificationCodePlaceholder;        //!< Verification code editor placeholder string.
@property NSString*         fullNamePlaceholder;                //!< User's full name editor placeholder string.
@property NSString*         usernamePlaceholder;                //!< Username editor placeholder string.
@property NSString*         termsAndPrivacyPolicyMessage;       //!< Terms and Privacy Policy string.
@property NSString*         loginLeftButtonLabel;               //!< Label for the login left button.
@property NSString*         loginRightButtonLabel;              //!< Label for the login right button.
@property NSString*         initialCountry;                     //!< Name of the initially selected country, eg: @"United States".
@property BlockIdAction     termsAndPolicyLinkAction;           //!< Action block for displaying of the terms and policy pages.
@property BlockAction       invalidParseSessionToken;           //!< Action block to notify the app of an invalid Parse session token.
@property BlockBlockAction  missingInternetConnection;          //!< Action block to notify the app of a missing internet connection.
@property BlockStringAction userIsBlocked;                      //!< Action block to notify the app that the user has been blocked.
@property BlockBoolAction   loginDone;                          //!< Action block to notify the app that the login process has terminated. Param is YES if this is the first login of a new user.
//____________________

// Find user parameters;
@property NSString*     findUserLabel;                          //!< Content of the label placed on top of the user search screen.
@property NSString*     findUsernamePlaceholder;                //!< Search username editor placeholder string.
@property NSString*     findUserLeftButtonLabel;                //!< Label for the search user left button.
@property NSString*     findUserRightButtonLabel;               //!< Label for the search user right button.
@property NSString*     findUserMessagingSampleText;            //!< Default sample text to insert in the iMessage editor.
@property BlockAction   findUserMessagingNotSupportedAction;    //!< Action block to notify the app that the device does not support iMessage.
@property BlockAction   findUserFailedToSendMessageAction;      //!< Action block to notify the app that sending the iMessage has failed.
//____________________

// Roll down error message view parameters.
@property UIColor*      rollDownViewBackgroundColor;            //!< Color of the roll down error message views.
//____________________

// Login roll down error message view parameters.
@property NSString*     loginRollDownViewTitle;                      //!< Title of the roll down error message view.
@property NSString*     loginRollDownPhoneNumberFormatErrorMessage;  //!< Phone number format error message string.
@property NSString*     loginRollDownPhoneNumberErrorMessage;        //!< Phone number error message string.
@property NSString*     loginRollDownVerificationCodeErrorMessage;   //!< Verification code error message string.
@property NSString*     loginRollDownUsernameErrorMessage;           //!< Already used username error message string.
//@property NSString*     rollDownUnknownUsernameErrorMessage;        //!< Unknown user error message string.
//____________________

// Add friend roll down error message view parameters.
@property NSString*     addFriendRollDownViewTitle;                         //!< Title of the add friend roll down error message view.
@property NSString*     AddFriendRollDownAlreadyFriendErrorMessage;         //!< Already friend error message string.
@property NSString*     AddFriendRollDownAlreadyPendingFriendErrorMessage;  //!< Already pending friend error message string.
@property NSString*     AddFriendRollDownBlockedFriendErrorMessage;         //!< This friend is blocked error message string.
@property NSString*     AddFriendRollDownBlockingUserErrorMessage;          //!< This user is blocking the current user error message string.
@property NSString*     AddFriendRollDownUnknownUsernameErrorMessage;       //!< Unknown username error message string.
//____________________

@end
//__________________________________________________________________________________________________

GlobalParameters* GetGlobalParameters(void);
//__________________________________________________________________________________________________
