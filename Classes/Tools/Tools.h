
//! \file   Tools.h
//! \brief  Definitions and functions that could be useful almost everywhere.
//__________________________________________________________________________________________________

#import <UIKit/UIKit.h>
//__________________________________________________________________________________________________

#ifndef min
#define min(a, b) ((a)<(b)?(a):(b))         //!< Macro for finding minimum of two values.
#endif

#ifndef max
#define max(a, b) ((a)>(b)?(a):(b))         //!< Macro for finding maximum of two values.
#endif

#ifndef minmax
#define minmax(a, b, c) (min(max(a, b), c)) //!< Macro for bounding a value between minimum and maximum bounds.
#endif

//__________________________________________________________________________________________________

CGFloat GetFloatOsVersion(void);
//__________________________________________________________________________________________________

//! Check if this app is running in the simulator.
bool IsSimulator(void);
//__________________________________________________________________________________________________

//! Check if this device runs over iOS 8 or higher.
bool IsIOS_8(void);
//__________________________________________________________________________________________________

//! Check if this device is an iPad.
bool IsIpad(void);
//__________________________________________________________________________________________________

//! Check if this device is an iPhone with a 3.5" screen.
bool IsIphone3_5(void);
//__________________________________________________________________________________________________

//! Check if this device is an iPhone with a 4.0" screen.
bool IsIphone4_0(void);
//__________________________________________________________________________________________________

//! Check if this device is an iPhone with a 4.7" screen.
bool IsIphone4_7(void);
//__________________________________________________________________________________________________

//! Check if this device is an iPhone with a 5.5" screen.
bool IsIphone5_5(void);
//__________________________________________________________________________________________________

//! Return YES if the device is curently in portrait orientation.
bool IsPortraitOrientation(void);
//__________________________________________________________________________________________________

//! Return YES if the device is curently in landscape orientation.
bool IsLandscapeOrientation(void);
//__________________________________________________________________________________________________

bool IsPortraitDirectOrientation(void);
//__________________________________________________________________________________________________

bool IsPortraitUpsideDownOrientation(void);
//__________________________________________________________________________________________________

bool IsLandscapeLeftOrientation(void);
//__________________________________________________________________________________________________

bool IsLandscapeRightOrientation(void);
//__________________________________________________________________________________________________

CGFloat GetScreenWidth(void);
//__________________________________________________________________________________________________

CGFloat GetScreenHeight(void);
//__________________________________________________________________________________________________

CGFloat GetStatusBarHeight(void);
//__________________________________________________________________________________________________

//! Rename a file.
bool RenameUrlFile(NSURL* oldUrl, NSURL* newUrl);
//__________________________________________________________________________________________________

//! Delete a file.
bool DeleteUrlFile(NSURL* url);
//__________________________________________________________________________________________________

//! Get the Url of a file in the documents folder.
NSURL* UrlOfFileInDocumentsFolder(NSString* fileName, NSString* extension);
//__________________________________________________________________________________________________

CGSize CalculateTextSize
(
        NSString* text,
  const CGSize    constraintToSize,
        UIFont*   font
);
//__________________________________________________________________________________________________

CGSize CalculateAttributedTextSize
(
        NSAttributedString* attrString,
  const CGSize              constraintToSize
);
//__________________________________________________________________________________________________
