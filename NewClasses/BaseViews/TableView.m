
//! \file   TableView.m
//! \brief  Custom view that integrate the UITableView into the khView edifice.
//__________________________________________________________________________________________________

#import "TableView.h"
#import "Colors.h"
//__________________________________________________________________________________________________

//! Custom view that integrate the UITableView into the khView edifice.
@interface TableView() <UITableViewDataSource, UITableViewDelegate>
{
}
//__________________________________________________________________________________________________

@end
//__________________________________________________________________________________________________

@implementation TableView
{
  NSInteger LastScrolledRow;
}
//____________________

//! Handle the basic initialization of the class.
- (void)Initialize
{
  [self Initialize:UITableViewStylePlain];
}
//__________________________________________________________________________________________________

//! Handle the basic initialization of the class, with style.
- (void)Initialize:(UITableViewStyle)style
{
  self.backgroundColor          = Transparent;
  self.separatorColor           = Transparent;
  self.delegate                 = self;
  self.dataSource               = self;
  LastScrolledRow               = 0;
  self.canCancelContentTouches  = NO;
}
//__________________________________________________________________________________________________

//! Initialize the object when it has been allocated programmatically.
- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
	self = [super initWithFrame:frame style:style];
	if (self)
	{
    [self Initialize];
	}
	return self;
}
//__________________________________________________________________________________________________

- (void)dealloc
{
}
//__________________________________________________________________________________________________

- (BOOL)touchesShouldBegin:(NSSet *)touches
                 withEvent:(UIEvent *)event
             inContentView:(UIView *)view
{
  return YES;
}
//__________________________________________________________________________________________________

- (void)setLastScrolledRow:(NSInteger)lastScrolledRow
{
  LastScrolledRow = lastScrolledRow;
}
//__________________________________________________________________________________________________

- (NSInteger)lastScrolledRow
{
  return LastScrolledRow;
}
//__________________________________________________________________________________________________

- (NSString*)GetCellIdentifier:(NSIndexPath*)indexPath
{
  return @"khTableViewCell";
}
//__________________________________________________________________________________________________

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return 1;
}
//__________________________________________________________________________________________________

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return 0;
}
//__________________________________________________________________________________________________

//! Specialize this method in the derived class to retrieve an existing desired table view cell object. Return nil if not found.
- (TableViewCell*)RetrieveCellForTableView:(UITableView*)tableView atIndexPath:(NSIndexPath*)indexPath
{
  NSString* cell_identifier   = [self GetCellIdentifier:indexPath];
  TableViewCell* cell  = (TableViewCell*)[tableView dequeueReusableCellWithIdentifier:cell_identifier];
  return cell;
}
//__________________________________________________________________________________________________

//! Specialize this method in the derived class to create the desired table view cell object.
- (TableViewCell*)CreateCellForTableView:(UITableView*)tableView atIndexPath:(NSIndexPath*)indexPath
{
  NSString* cell_identifier = [self GetCellIdentifier:indexPath];
  TableViewCell* cell       = [[TableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cell_identifier];
  cell.tableView            = self;
  return cell;
}
//__________________________________________________________________________________________________

//!< Specialize this method in the derived class to get the desired table view cell object.
- (TableViewCell*)GetCellForTableView:(UITableView*)tableView atIndexPath:(NSIndexPath*)indexPath
{
	TableViewCell* cell = [self RetrieveCellForTableView:tableView atIndexPath:indexPath];
	if (cell == nil)
	{
		cell = [self CreateCellForTableView:tableView atIndexPath:indexPath];
    [self BuildCellContent:cell atIndexPath:indexPath];
	}
  cell.tableRow     = indexPath.row;
  cell.tableSection = indexPath.section;
  return cell;
}
//__________________________________________________________________________________________________

// Tell our table what kind of cell to use and its title for the given row.
- (UITableViewCell *)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
  TableViewCell* cell = [self GetCellForTableView:tableView atIndexPath:indexPath];

  [self InitCell:cell atIndexPath:indexPath];
	return cell;
}
//__________________________________________________________________________________________________

// The table's selection has changed.
- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
  [self DidSelectRow:indexPath];
}
//__________________________________________________________________________________________________

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
  return [self CanMoveRowAtIndexPath:indexPath];
}
//__________________________________________________________________________________________________

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
  [self MovedRowAtIndexPath:fromIndexPath toIndexPath:toIndexPath];
}
//__________________________________________________________________________________________________

- (void)BuildCellContent:(TableViewCell*)cell atIndexPath:(NSIndexPath*)indexPath
{
  NSLog(@"This method (BuildCellContent) shall be implemented by derived classes!");
}
//__________________________________________________________________________________________________

- (void)InitCell:(TableViewCell*)cell atIndexPath:(NSIndexPath*)indexPath
{
  NSLog(@"This method (InitCell) shall be implemented by derived classes!");
}
//__________________________________________________________________________________________________

- (void)LayoutCell:(TableViewCell*)cell;
{
  NSLog(@"This method (LayoutCell) shall be implemented by derived classes!");
}
//__________________________________________________________________________________________________

- (bool)CanMoveRowAtIndexPath:(NSIndexPath*)indexPath;
{
  return NO;  // By default, do not enable reordering.
}
//__________________________________________________________________________________________________

- (void)MovedRowAtIndexPath:(NSIndexPath*)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath;
{
}
//__________________________________________________________________________________________________

- (void)DidSelectRow:(NSIndexPath*)indexPath;
{
  NSLog(@"This method (DidSelectRow) shall be implemented by derived classes!");
}
//__________________________________________________________________________________________________

- (void)layoutSubviews
{
  [super layoutSubviews];
}
//__________________________________________________________________________________________________

//! Force refresh of the table data.
- (void)ReloadTableData
{
  dispatch_async(dispatch_get_main_queue(), ^
  {
    [self reloadData];
  });
}
//__________________________________________________________________________________________________

@end
//__________________________________________________________________________________________________

