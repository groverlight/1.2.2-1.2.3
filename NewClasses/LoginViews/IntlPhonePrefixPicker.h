
//! \file   IntlPhonePrefixPicker.h
//! \brief  Picker view for selection the country phone prefix code.
//__________________________________________________________________________________________________

#import <UIKit/UIKit.h>
#import "Blocks.h"
//__________________________________________________________________________________________________

//! Picker view for selection the country phone prefix code.
@interface IntlPhonePrefixPicker : UIPickerView
{
}
//____________________

@property BlockIntAction rowSelectedAction; //!< Action block called when the user selected a country.
//____________________

- (NSString*)getCountryNameAtRow:(NSInteger)row;          //!< Get the name of the country at the specified index.
- (NSString*)getCountryPrefixAtRow:(NSInteger)row;        //!< Get the country prefix code at the specified index.
- (NSInteger)getRowForCountryName:(NSString*)countryName; //!< Retrieve index of the row holding the specified country name.
//____________________

@end
//__________________________________________________________________________________________________
