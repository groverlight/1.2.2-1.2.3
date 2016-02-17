
//! \file   SendToFriendSelectionView.m
//! \brief  UIView based class that show a list of friends and some other objects.
//__________________________________________________________________________________________________

#import "SendToFriendSelectionView.h"
#import "FriendRecord.h"
#import "GlobalParameters.h"
#import "ParseUser.h"
#import "FriendSelectionView.h"
#import "VideoViewController.h"
#import "BDKCollectionIndexView.h"
#import "Colors.h"
#import <contacts/contacts.h>
#import <addressbook/addressbook.h>
#import "Mixpanel.h"
//__________________________________________________________________________________________________

//! UIView based class that show a list of friends and some other objects.

@implementation SendToFriendSelectionView

{
    NSInteger SelectedFriend;
    UITableView *tableView;
    NSMutableArray *sectionTitles;
    NSMutableArray *sectionPeople;
    NSMutableArray *person;
    BDKCollectionIndexView *indexView;
    NSArray * indexTitles;
}

//____________________

//! Initialize the object however it has been created.
-(void)Initialize
{
    [super Initialize];
    if ([PFUser currentUser][@"phoneNumber"] != nil)
    {
        CNAuthorizationStatus permissions = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
        if(permissions == CNAuthorizationStatusAuthorized)
        {
            NSLog(@"not nil %@", [PFUser currentUser]);
            [self contactsync];
        }
    }
    indexView.delegate = self;
  self.clipsToBounds = NO;
  GlobalParameters* parameters  = GetGlobalParameters();
  ListName.text                 = parameters.friendsSendToLabelTitle;
  self.showSectionHeaders       = YES;
  self.useBlankState            = NO;
  self.ignoreUnreadMessages     = YES;
  self.maxNumRecentFriends      = GetGlobalParameters().friendsMaxRecentFriends;

}
//__________________________________________________________________________________________________

- (void)dealloc
{
  [self cleanup];
}


//__________________________________________________________________________________________________

- (void)cleanup
{
}
//__________________________________________________________________________________________________


- (void)updateFriendsLists // this is where I edit the index list.
{
    NSLog(@"updated");


    self.window.bounds = [[UIScreen mainScreen] bounds];
    indexTitles = @[@"💬", @"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z"];
    NSLog(@"%f", [[UIScreen mainScreen] bounds].size.width);
   /* self->indexView = [BDKCollectionIndexView indexViewWithFrame:CGRectMake(
                                        [[UIScreen mainScreen] bounds].size.width-28,
                                        [[UIScreen mainScreen] bounds].size.width/6,
                                        28,
                                        [[UIScreen mainScreen] bounds].size.height-
                                        [[UIScreen mainScreen] bounds].size.height/6) indexTitles:nil]; // Roast Beef
  self->indexView = [self->indexView initWithFrame:CGRectMake([[UIScreen mainScreen] bounds].size.width-28,[[UIScreen mainScreen] bounds].size.height-100,28,[[UIScreen mainScreen] bounds].size.height) indexTitles: indexTitles];*/
    self->indexView = [BDKCollectionIndexView indexViewWithFrame:CGRectMake(self.window.width-28,self.window.height/6,28,self.window.height-self.window.height/6) indexTitles:nil]; // Roast Beef
    
    self->indexView = [self->indexView initWithFrame:CGRectMake(self.window.width-28,self.window.height,28,self.window.height) indexTitles: indexTitles];
    
    //NSLog(@"INDEX VIEW FRAME2: %@", NSStringFromCGRect(self->indexView.frame));
    self->indexView.contentMode = UIViewContentModeScaleAspectFill;
    [self insertSubview:self->indexView atIndex:0];
    [self bringSubviewToFront:self->indexView];
    

   self.recentFriends  = GetTimeSortedFriendRecords();
   // NSLog(@"contacts: %@", recentListUsers);
    [recentListUsers sortUsingComparator:^NSComparisonResult(id obj1, id obj2)
     {
         FriendRecord* record1 = (FriendRecord*)obj1;
         FriendRecord* record2 = (FriendRecord*)obj2;
         
         return ([record1.fullName caseInsensitiveCompare:record2.fullName]);
     }];
    NSMutableArray *uniqueArray = [NSMutableArray array];
    NSMutableSet *names = [NSMutableSet set];
    for (FriendRecord* record in recentListUsers) {
        NSString *destinationName = record.fullName;
        if (![names containsObject:destinationName]) {
            [uniqueArray addObject:record];
            [names addObject:destinationName];
        }
    }
    recentListUsers = uniqueArray;
    self.allFriends     = recentListUsers;
  self->FriendsList.contentOffset = CGPointMake(0, 0- FriendsList.contentInset.top);
dispatch_async(dispatch_get_main_queue(), ^{
  [self->FriendsList ReloadTableData];
});
  [self->indexView addTarget:self action:@selector(indexViewValueChanged:) forControlEvents:UIControlEventValueChanged];


}

//__________________________________________________________________________________________________
- (void)indexViewValueChanged:(BDKCollectionIndexView *)sender {
  // NSLog(@"indexView.currentIndex %lu", indexView.currentIndex);
   //NSLog(@"Array of Section Titles: %lu",[self->FriendsList->arrayOfSectionTitles indexOfObject:[indexTitles objectAtIndex:indexView.currentIndex]]);
    [self->FriendsList reloadData];
    [self->FriendsList layoutIfNeeded];
    if (self->FriendsList->arrayOfSectionTitles != nil)
    {
        NSInteger listIndex =[self->FriendsList->arrayOfSectionTitles indexOfObject:[indexTitles objectAtIndex:indexView.currentIndex]];
        NSLog(@"%lu", listIndex);
        NSIndexPath *path = [NSIndexPath indexPathForItem:0 inSection:listIndex];
        if (listIndex < 100)
                if (([self->FriendsList numberOfSectionsInTableView:self->FriendsList] > path.section) &&
                    ([self->FriendsList numberOfRowsInSection:listIndex] > path.row))
                {

                
       //self->FriendsList->indexForList = indexView.currentIndex;
            [self->FriendsList scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionNone animated:NO];
                }
    }

}

-(void) contactsync
{
    [GetCurrentParseUser() loadFriendsListWithCompletion:^(NSArray* friends, NSError* loadError)
     {
         
         UpdateFriendRecordListForFriends(friends);
         
         FriendsList.allFriends = GetNameSortedFriendRecords();
         
         [FriendsList ReloadTableData];
     }];
    NSMutableArray *fullName = [[NSMutableArray alloc]init];
    NSMutableArray *phoneNumber = [[NSMutableArray alloc]init];
    if (1)
    {
        NSLog(@"INITIATING CONTACT SYNC"); // IMPORTANT
        
        // NSMutableArray *contacts = [[NSMutableArray alloc]init];
        
        if([CNContactStore class]) // this is where you say yes or noiOS 9 or later
        {
            
            
            CNContactStore* addressBook = [[CNContactStore alloc]init];
            CNAuthorizationStatus permissions = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
            if(permissions == CNAuthorizationStatusNotDetermined || permissions == CNAuthorizationStatusAuthorized) {
                
                [addressBook requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable contactError) {
                    
                    if (granted)
                    {
                        NSLog(@"Said YES to Contacts Sync");
                        
                        Mixpanel *mixpanel = [Mixpanel sharedInstance];
                        
                        [mixpanel track:@"Said YES to Contacts Sync"];
                        
                        [mixpanel identify:mixpanel.distinctId];
                        
                        [mixpanel.people increment:@"Said YES to Contacts Sync" by:[NSNumber numberWithInt:1]];
                        
                        
                        [addressBook containersMatchingPredicate:[CNContainer predicateForContainersWithIdentifiers: @[addressBook.defaultContainerIdentifier]] error:&contactError];
                        
                        
                        NSArray * keysToFetch =@[CNContactEmailAddressesKey, CNContactPhoneNumbersKey, CNContactFamilyNameKey, CNContactGivenNameKey, CNContactPostalAddressesKey];
                        CNContactFetchRequest * request = [[CNContactFetchRequest alloc]initWithKeysToFetch:keysToFetch];
                        
                        
                        [addressBook enumerateContactsWithFetchRequest:request error:&contactError usingBlock:^(CNContact * __nonnull contact, BOOL * __nonnull stop){
                            
                            NSString *name = [NSString stringWithFormat:@"%@ %@",contact.givenName,contact.familyName];
                            NSString *phone = [NSString string];
                            
                            for (CNLabeledValue *value in contact.phoneNumbers) {
                                
                                if ([value.label isEqualToString:@"_$!<Mobile>!$_"])
                                {
                                    CNPhoneNumber *phoneNum = value.value;
                                    phone = phoneNum.stringValue;
                                }
                                
                                if ([phone isEqualToString:@""])
                                {
                                    if ([value.label isEqualToString:@"_$!<Home>!$_"])
                                    {
                                        CNPhoneNumber *phoneNum = value.value;
                                        phone = phoneNum.stringValue;
                                    }
                                }
                                if ([phone isEqualToString:@""])
                                {
                                    if ([value.label isEqualToString:@"_$!<Work>!$_"])
                                    {
                                        CNPhoneNumber *phoneNum = value.value;
                                        phone = phoneNum.stringValue;
                                    }
                                }
                                
                            }
                            
                            [fullName addObject:name];
                            [phoneNumber addObject:[self formatNumber:phone]];
                            
                            
                            
                        }];
                        
                        [self updateTable:fullName phone:phoneNumber];
                        
                        
                    }
                    
                    else
                        
                    {
                        
                        NSLog(@"You said NO to Contacts");
                        
                        Mixpanel *mixpanel = [Mixpanel sharedInstance];
                        
                        [mixpanel track:@"Said NO to Contacts Sync"];
                        
                        [mixpanel identify:mixpanel.distinctId];
                        
                        [mixpanel.people increment:@"Said NO to Contacts Sync" by:[NSNumber numberWithInt:1]];
                        
                        
                    }
                    
                    
                    
                }];
                
            }
            
            else
            {
                NSLog(@"did not ask permissions");
            }
        }
        
        
        else
        {
            
            __block NSString *firstName;
            __block NSString *lastName;
            ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, NULL);
            if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized)
            {
                
                CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBookRef);
                CFIndex numberOfPeople = CFArrayGetCount(allPeople);
                NSLog(@"%lu", numberOfPeople);
                for(int  i = 0; i < numberOfPeople; i++) {
                    
                    ABRecordRef person = CFArrayGetValueAtIndex( allPeople, i );
                    // Use a general Core Foundation object.
                    CFTypeRef generalCFObject = ABRecordCopyValue(person, kABPersonFirstNameProperty);
                    
                    // Get the first name.
                    if (generalCFObject) {
                        firstName =(__bridge NSString *)generalCFObject;
                        CFRelease(generalCFObject);
                    }
                    
                    // Get the last name.
                    generalCFObject = ABRecordCopyValue(person, kABPersonLastNameProperty);
                    if (generalCFObject) {
                        lastName =(__bridge NSString *)generalCFObject;
                        CFRelease(generalCFObject);
                    }
                    [fullName addObject: [NSString stringWithFormat:@"%@ %@", firstName, lastName]];
                    NSLog(@"%@", [fullName objectAtIndex:i]);
                    ABMultiValueRef phoneNumbers = ABRecordCopyValue(person, kABPersonPhoneProperty);
                    
                    for (CFIndex j = 0; j < ABMultiValueGetCount(phoneNumbers); j++) {
                        CFStringRef currentPhoneLabel = ABMultiValueCopyLabelAtIndex(phoneNumbers, j);
                        CFStringRef currentPhoneValue = ABMultiValueCopyValueAtIndex(phoneNumbers, j);
                        
                        if (CFStringCompare(currentPhoneLabel, kABPersonPhoneMobileLabel, 0) == kCFCompareEqualTo) {
                            [phoneNumber addObject:[self formatNumber:(__bridge NSString *)currentPhoneValue]];
                        }
                        
                        else if (CFStringCompare(currentPhoneLabel, kABHomeLabel, 0) == kCFCompareEqualTo) {
                            [phoneNumber addObject:[self formatNumber:(__bridge NSString *)currentPhoneValue]];                 }
                        else if (CFStringCompare(currentPhoneLabel, kABWorkLabel, 0) == kCFCompareEqualTo) {
                            [phoneNumber addObject:[self formatNumber:(__bridge NSString *)currentPhoneValue]];
                        }
                        
                        CFRelease(currentPhoneLabel);
                        CFRelease(currentPhoneValue);
                    }
                    CFRelease(phoneNumbers);
                    
                }
                
                
            }
            
            
            [self updateTable:fullName phone:phoneNumber];
            
            
            
            
        }
        
        [[PFUser currentUser] setObject:@YES forKey:@"didContactSync"];
        [[PFUser currentUser]saveInBackground];
    }
    
    [self updateFriendsLists];
    
}
-(void)updateTable:(NSArray*)fullName phone:(NSArray*)phoneNumber
{
    NSMutableArray *contacts = [[NSMutableArray alloc] init];
    
    PFQuery *query = [PFUser query];
    
    [query whereKey:@"phoneNumber" containedIn:phoneNumber];
    // NSLog(@" this %@ ", [query findObjects]);
    //NSLog(@"%@, %@",fullName, phoneNumber);
    NSInteger index = 0;
    if(recentListUsers == nil)
    {
        recentListUsers = [[NSMutableArray alloc]init];
    }
    
    for (NSString* name in fullName)
    {
        BOOL containsLetter = NSNotFound != [name rangeOfCharacterFromSet:NSCharacterSet.letterCharacterSet].location;
        if(containsLetter)
        {
            // if (![name isEqualToString:@""];
            //NSLog( @"timestampstring:%@ timestampdouble:%f",timeStamp, [[NSDate date] timeIntervalSince1970]);
            FriendRecord * newUser = [FriendRecord new];
            newUser.fullName = name;
            newUser.phoneNumber = [phoneNumber objectAtIndex:index];
            newUser.lastActivityTime = [[NSDate date] timeIntervalSince1970];
            
            
            
            
            [recentListUsers addObject:newUser];
        }
        index++;
    }
    // clear duplicate contacts
    NSMutableArray *uniqueArray = [NSMutableArray array];
    NSMutableSet *names = [NSMutableSet set];
    
    //for (FriendRecord* record in recentListUsers) {
    for (NSInteger i = 0; i < [recentListUsers count]; i ++){
        
        // NSLog(@"Timestamp : %f", record.lastActivityTime);
        FriendRecord *record = recentListUsers[i];
        NSString *destinationName = record.phoneNumber;
        if (![names containsObject:destinationName]) {
            if (destinationName != nil)
            {
                
                
                [uniqueArray addObject:record];
                [names addObject:destinationName];
            }
        }
        else
        {
            if (record.user != nil)
            {
                for (NSInteger j = 0; j < [uniqueArray count]; j++)
                {
                    FriendRecord *record2 = uniqueArray[j];
                    if ([record2.phoneNumber isEqualToString: record.phoneNumber])
                    {
                        uniqueArray[j] = record;
                    }
                }
            }
        }
        
    }
    recentListUsers = uniqueArray;
    // clear contacts with no phone numbers
    NSMutableArray *filterArray = [[NSMutableArray alloc]init];
    
    //for (FriendRecord *record in recentListUsers)
    for (NSInteger i = 0; i < [recentListUsers count]; i++)
    {
        FriendRecord *record = recentListUsers[i];
        if ([[self formatNumber:record.phoneNumber] length] == 10)
        {
            [filterArray addObject: record];
        }
    }
    
    recentListUsers = filterArray;
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        if (!error) {
            if(objects != nil)
            {NSLog(@"The find succeeded");
                // NSLog(@"%@", objects);
            }
            
            
            for (PFUser* object in objects)
            {
                NSLog(@"%@", object.username);
                PFQuery *pushQuery = [PFInstallation query];
                [pushQuery whereKey:@"user" equalTo:object];
                NSString * Name = [[PFUser currentUser] objectForKey:@"fullName"];
                NSString * Username = [[PFUser currentUser] objectForKey:@"username"];
                
                // Send push notification to query
                NSDictionary *data = @{
                                       
                                       @"content-available": @"1",
                                       @"alert" : [NSString stringWithFormat:@"Uh-oh! %@ (%@) is using Typeface! 🙈" ,Name, Username],
                                       @"sound" : @"digi_blip_hi_2x.aif",
                                       @"p" :[PFUser currentUser].objectId,
                                       @"t" :[PFUser currentUser][@"phoneNumber"],
                                       
                                       };
                
                PFPush *push = [[PFPush alloc] init];
                [push setQuery:pushQuery];
                [push setMessage:@"this works"];
                [push setData:data];
                /*[push sendPushInBackgroundWithBlock:^(BOOL succeeded, NSError *sendError)
                 {
                 NSLog(@"Sending Push");
                 }];*/
                
                //[[PFUser currentUser] addUniqueObject:object.objectId forKey:@"friends"];
                [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *saveerror) {
                }];
                
            }
            
            [GetCurrentParseUser() loadFriendsListWithCompletion:^(NSArray* friends, NSError* loadError)
             {
                 
                 PFObject* localDatastore = [PFObject objectWithClassName:@"localDatastore"];
                 
                 UpdateFriendRecordListForFriends(friends);
                 
                 
                 for (NSInteger i=0; i < [recentListUsers count]; i++)
                 {
                     
                     FriendRecord *temprecord = [recentListUsers objectAtIndex:i];
                     for (FriendRecord *record in GetNameSortedFriendRecords())
                     {
                         
                         if ([temprecord.phoneNumber isEqualToString: record.phoneNumber] )
                         {
                             recentListUsers[i] = record;
                             break;
                         }
                         
                     }
                     
                     FriendRecord *anothertemprecord = recentListUsers[i];
                     NSMutableDictionary *contact;
                     if (anothertemprecord.user == nil)
                     {
                         contact = [[NSMutableDictionary alloc] initWithObjects:@[anothertemprecord.fullName, anothertemprecord.phoneNumber, [NSString stringWithFormat:@"%f",anothertemprecord.lastActivityTime], ] forKeys:@[@"fullName", @"phoneNumber", @"lastActivityTime"]];
                     }
                     else
                     {
                         contact = [[NSMutableDictionary alloc] initWithObjects:@[anothertemprecord.fullName, anothertemprecord.phoneNumber, [NSString stringWithFormat:@"%f",anothertemprecord.lastActivityTime], anothertemprecord.user] forKeys:@[@"fullName", @"phoneNumber", @"lastActivityTime", @"user"]];
                     }
                     
                     
                     //NSLog(@"contact:%@", contact);
                     
                     
                     [contacts addObject:contact];
                 }
                 [recentListUsers sortUsingComparator:^NSComparisonResult(id obj1, id obj2)
                  {
                      FriendRecord* record1 = (FriendRecord*)obj1;
                      FriendRecord* record2 = (FriendRecord*)obj2;
                      
                      return ([record1.fullName caseInsensitiveCompare:record2.fullName]);
                  }];
                 
                 [localDatastore addUniqueObjectsFromArray:contacts forKey:@"FriendsList"];
                 
                 [localDatastore pinInBackgroundWithBlock:^(BOOL succeeded, NSError *pinError) {
                     NSLog(@"pinned");
                 }];
                 [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *saveerror2) {
                 }];
                 NSLog(@"contacts");
                 
                 
                 // NSLog(@"contacts: %@", contacts);
                 
                 [self updateFriendsLists];
             }];
        }
        
        
        
        else {
            NSLog(@"Did not find anyone");
            
        }
        [self updateFriendsLists];
        if ([PFUser currentUser] != nil)
        {
            PFQuery *friendquery = [PFUser query];
            
            [friendquery whereKey:@"friends" equalTo:[PFUser currentUser].objectId];
            [friendquery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable friends, NSError * _Nullable error1) {
                if (friends != nil)
                    for (PFUser *user in friends)
                    {
                        [[PFUser currentUser] addUniqueObject:user.objectId  forKey:@"friends"];
                    }
            }];
        }
        PFQuery *queryLocal = [PFQuery queryWithClassName:@"localDatastore"];
        
        [queryLocal fromLocalDatastore];
        
        //NSLog(@"temp %@", temp);
        
        if( recentListUsers == nil)
        {
            recentListUsers = [[NSMutableArray alloc]init];
        }
        if (1)
        {
            
            
            NSArray* friends = [PFUser currentUser][@"friends"];
            //NSLog(@"friends: %@", friends);
            for (NSString * objectId in friends)
            {
                //NSLog(@"hi");
                [ParseUser findUserWithObjectId:objectId completion:^(ParseUser* user, NSError* error2)
                 {
                     
                     NSLog(@"USER YO:%@", user);
                     FriendRecord *record = [FriendRecord new];
                     record.fullName = user.fullName;
                     record.phoneNumber = user.phoneNumber;
                     record.user = user;
                     NSInteger flag = 0;
                     for (NSInteger i = 0; i < [recentListUsers count]; i++)
                     {
                         FriendRecord *friend =  recentListUsers[i];
                         // NSLog(@"friend: %@ record: %@", friend.phoneNumber, record.phoneNumber);
                         if ([friend.phoneNumber isEqualToString: record.phoneNumber])
                         {
                             // NSLog(@"found");
                             record.lastActivityTime = friend.lastActivityTime;
                             recentListUsers[i] = record;
                             //NSLog(@"record:%@",record.user);
                         }
                         else{
                             flag++;
                         }
                         
                     }
                     if (flag == [recentListUsers count])
                     {
                         [recentListUsers addObject:record];
                     }
                 }];
            }
            
            
            
            
            [recentListUsers sortUsingComparator:^NSComparisonResult(id obj1, id obj2)
             {
                 FriendRecord* record1 = (FriendRecord*)obj1;
                 FriendRecord* record2 = (FriendRecord*)obj2;
                 
                 return ([record1.fullName caseInsensitiveCompare:record2.fullName]);
             }];
            
            //NSLog(@"recentListUsers udpated: %@", recentListUsers);
            
        }
        
        
    }];
    
    
    
    
    
}

-(NSString*)formatNumber:(NSString*)mobileNumber
{
    
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"(" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@")" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"+" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"." withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"\u00a0" withString:@""];
    
    
    
    
    NSInteger length = [mobileNumber length];
    if(length > 10)
    {
        mobileNumber = [mobileNumber substringFromIndex: length-10];
        
    }
    
    
    return mobileNumber;
}

@end
