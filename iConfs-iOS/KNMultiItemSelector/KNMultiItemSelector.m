//
//  KNMultiItemSelector.m
//  KNFBFriendSelectorDemo
//
//  Created by Kent Nguyen on 4/6/12.
//  Copyright (c) 2012 Kent Nguyen. All rights reserved.
//

#import "KNMultiItemSelector.h"
#import "UIImageView+WebCache.h"
#import <QuartzCore/QuartzCore.h>

#pragma mark - Private Interface

#define CONTACT	3
#define PERSON 1
#define EVENT 2

@interface KNMultiItemSelector (){
    NSIndexPath* rowselected;
    NSString * preselectedSelectedValue;
    UISegmentedControl *contactToolbar;
    NSString * titlePage;

}
@property (strong, nonatomic) UIToolbar *t;
@end

#pragma mark - Implementation

@implementation KNMultiItemSelector {
  NSString * placeholderText;
    NSString * text;
}

@synthesize tableView, useTableIndex, selectedItems, searchTextField, allowSearchControl, allowModeButtons;
@synthesize useRecentItems, maxNumberOfRecentItems, recentItemStorageKey, maximumItemsSelected, tag;

-(id)initWithItems:(NSArray*)_items
          delegate:(id)_delegate {
  return [self initWithItems:_items
            preselectedItems:nil
                       title:NSLocalizedString(@"Select items", nil)
             placeholderText:NSLocalizedString(@"Search by keywords", nil)
                    delegate:_delegate
                        text:nil];

}

-(id)initWithItems:(NSArray*)_items
  preselectedItems:(NSArray*)_preselectedItems
             title:(NSString*)title
   placeholderText:(NSString*)_placeholder
          delegate:(id)delegateObject
              text:(NSString*)t {
    text = t;
  self = [super init];
  if (self) {
      
    preselectedSelectedValue = @"-1";
    delegate = delegateObject;
    self.title = title;
    self.maxNumberOfRecentItems = 5;
    self.useRecentItems = NO;
    self.recentItemStorageKey = @"recent_selected_items";
    self.allowModeButtons = YES;
    
    placeholderText = _placeholder;
    
    // Initialize item arrays
    items = [_items mutableCopy];
    if (_preselectedItems) {
        selectedItems = _preselectedItems;
        for (KNSelectorItem * i in selectedItems) {
            preselectedSelectedValue = i.selectValue;
      }
    } else {

      for (KNSelectorItem * i in self.selectedItems) {
        i.selected = NO;
      }
    }

    // Recent selected items section
    recentItems = [NSMutableArray array];
    NSMutableArray * rArr =[[NSUserDefaults standardUserDefaults] objectForKey:self.recentItemStorageKey];

    // Preparing indices and Recent items
    indices = [NSMutableDictionary dictionary];
    for (KNSelectorItem * i in items) {
      NSString * letter = [i.displayValue substringToIndex:1];
      if (![indices objectForKey:letter]) {
        [indices setObject:[NSMutableArray array] forKey:letter];
      }
      if ([rArr containsObject:i.selectValue]) {
        [recentItems addObject:i];
      }
      NSMutableArray * a = [indices objectForKey:letter];
      [a addObject:i];
    }
  }
  return self;
}

-(void)viewDidLoad {
    rowselected = nil;

  //self.view = [[UIView alloc] initWithFrame:CGRectZero];
  self.view.backgroundColor = [UIColor whiteColor];
  
  // Initialize tableView
  //self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width,self.view.frame.size.height- (3*self.navigationController.toolbar.frame.size.height)) style:UITableViewStyleGrouped];
  self.tableView.delegate = self;
  self.tableView.dataSource = self;
  self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
  [self.view addSubview:self.tableView];
  
  // Initialize search text field
  textFieldWrapper = [[UIView alloc] initWithFrame:CGRectZero];
  textFieldWrapper.autoresizingMask = UIViewAutoresizingFlexibleWidth;
  textFieldWrapper.autoresizesSubviews = YES;
  textFieldWrapper.backgroundColor = [UIColor whiteColor];
  textFieldWrapper.layer.shadowColor = [[UIColor blackColor] CGColor];
  textFieldWrapper.layer.shadowOffset = CGSizeMake(0,1);
  textFieldWrapper.layer.shadowRadius = 5.0f;
  textFieldWrapper.layer.shadowOpacity = 0.2;
 
    //self.searchTextField = [[UITextField alloc] initWithFrame:CGRectZero];
    self.searchTextField = [[UITextField alloc] initWithFrame:CGRectMake(0, 40, self.view.frame.size.width, 40)];
  self.searchTextField.backgroundColor = [UIColor whiteColor];
  self.searchTextField.clipsToBounds = NO;
  self.searchTextField.keyboardType = UIKeyboardTypeASCIICapable;
  self.searchTextField.autocorrectionType = UITextAutocorrectionTypeNo;
  self.searchTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
  self.searchTextField.returnKeyType = UIReturnKeyDone;
  self.searchTextField.clearButtonMode = UITextFieldViewModeAlways;
  self.searchTextField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
  self.searchTextField.delegate = self;
  self.searchTextField.leftView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"KNZoomIcon"]];
  self.searchTextField.leftViewMode = UITextFieldViewModeAlways;
  self.searchTextField.placeholder = placeholderText ? placeholderText : NSLocalizedString(@"Search by keywords", nil);
  self.searchTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
  [self.view addSubview:textFieldWrapper];
  [textFieldWrapper addSubview:self.searchTextField];
  
  // Image indicator
  modeIndicatorImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"KNSelectorTip"]];
  modeIndicatorImageView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
  modeIndicatorImageView.contentMode = UIViewContentModeCenter;
  [self.view addSubview:modeIndicatorImageView];
  
  // Two mode buttons
  normalModeButton = [UIButton buttonWithType:UIButtonTypeCustom];
  selectedModeButton = [UIButton buttonWithType:UIButtonTypeCustom];
  [normalModeButton setTitle:NSLocalizedString(@"All", nil) forState:UIControlStateNormal];
  [normalModeButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
  [selectedModeButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
  [normalModeButton setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
  [selectedModeButton setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
  [normalModeButton addTarget:self action:@selector(modeButtonDidTouch:) forControlEvents:UIControlEventTouchUpInside];
  [selectedModeButton addTarget:self action:@selector(modeButtonDidTouch:) forControlEvents:UIControlEventTouchUpInside];
  normalModeButton.titleLabel.font = selectedModeButton.titleLabel.font = [UIFont boldSystemFontOfSize:13];
  normalModeButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
  selectedModeButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
  [normalModeButton setSelected:YES];
  [self.view addSubview:normalModeButton];
  [self.view addSubview:selectedModeButton];
  [self updateSelectedCount];
  
    [self createToolbar];
    [self navigationButtons];
}





- (IBAction)goHome:(UIBarButtonItem *)sender {
    [[self navigationController] popToViewController:[self.navigationController.viewControllers objectAtIndex:1] animated:YES];
}

- (IBAction)goSearch:(UIBarButtonItem *)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle: nil];
    SearchViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"SearchViewController"];
    titlePage = self.title;
    [self setTitle:@"Back"];
    [self.navigationController pushViewController:viewController animated:NO];

}



-(void)navigationButtons{
    
  //  UIBarButtonItem *homeButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Home.png"] style:UIBarButtonItemStylePlain target:self action:@selector(goHome:)];
    
    if(self.infoType == CONTACT){
        
        UIBarButtonItem *homeButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Home.png"] style:UIBarButtonItemStylePlain target:self action:@selector(goHome:)];
        [self.navigationItem setLeftBarButtonItem:homeButton animated:YES];
        [self.navigationItem setLeftItemsSupplementBackButton:YES];
        UIBarButtonItem *search = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(goSearch:)];
        [self.navigationItem setRightBarButtonItem:search];
    } else {
        // Nav bar button
        
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Choose" style:UIBarButtonItemStyleBordered target:self action:@selector(didFinish)];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(didCancel)];
        
    }
}


- (IBAction)goBack:(UIButton *)sender {


[self dismissViewControllerAnimated:YES completion:nil];
}


- (void)createToolbar {
    
    if(self.infoType == CONTACT){
        
        NSArray *itemArray = [NSArray arrayWithObjects: @"My contacts", @"Participants", @"Pending contacts", nil];
        contactToolbar  = [[UISegmentedControl alloc] initWithItems:itemArray];
        
        
        contactToolbar.frame = CGRectMake(0, 5, self.view.frame.size.width-12, 30);
        contactToolbar.segmentedControlStyle = UISegmentedControlStyleBar;
        contactToolbar.selectedSegmentIndex = 1;
        [contactToolbar addTarget:self action:@selector(valueChanged:) forControlEvents: UIControlEventValueChanged];
        
        
        contactToolbar.segmentedControlStyle = UISegmentedControlStyleBar;
        contactToolbar.momentary = NO;
        
        
        UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithCustomView:contactToolbar];
        buttonItem.style = UIBarButtonItemStyleBordered;
        
        _t = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 464, self.view.frame.size.width, 40)];
        _t.autoresizingMask |= UIViewAutoresizingFlexibleWidth;
        [_t setItems: [NSArray arrayWithObjects:buttonItem,  nil]];
        [self.view addSubview:_t];

    
    } else {
    
        //UIBarButtonItem *addNoteButton = [[UIBarButtonItem alloc] initWithTitle:@"Add note" style:UIBarButtonItemStyleBordered target:self action:@selector(addNote:)];
        UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        NSLog(@"%f", self.view.frame.size.height);
        NSArray *buttonItems = [NSArray arrayWithObjects:flexibleSpace, flexibleSpace, nil];
        _t = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 464, self.view.frame.size.width, 40)];
        _t.autoresizingMask |= UIViewAutoresizingFlexibleWidth;
        [_t setItems:buttonItems];
        [self.view addSubview:_t];
    }
   
    //[self.toolbar setItems:buttonItems];
    //[self.view addSubview:self.toolbar];
}

- (void)valueChanged:(UISegmentedControl *)segment {
    //get index position for the selected control
   NSInteger selectedIndex = [segment selectedSegmentIndex];
    if(selectedIndex == 1) {
        [self setTitle:@"Participants"];
        [self getAllPersons];
        [self indexOfTable];
        
    }else if (selectedIndex == 0){
        [self setTitle:@"My contacts"];
        [items removeAllObjects];
        [self getMyContacts:@"contact.db" withClause:@"select * from main.PEOPLE people inner join SECOND.CONTACT contact  on people.SERVER_ID = contact.PERSON_ID"];
        
        [self indexOfTable];
    } else if(selectedIndex == 2){
        [self setTitle:@"Pending"];
        [items removeAllObjects];
        [self getMyContacts:@"pending_contact.db" withClause:@"select * from main.PEOPLE people inner join SECOND.PENDING_CONTACT contact  on people.SERVER_ID = contact.PERSON_ID"];
        [self indexOfTable];
    }
    [self.tableView reloadData];
    
}

-(void) indexOfTable{
    NSMutableArray * rArr =[[NSUserDefaults standardUserDefaults] objectForKey:self.recentItemStorageKey];
    
    // Preparing indices and Recent items
    [indices removeAllObjects];
    for (KNSelectorItem * i in items) {
        NSString * letter = [i.displayValue substringToIndex:1];
        if (![indices objectForKey:letter]) {
            [indices setObject:[NSMutableArray array] forKey:letter];
        }
        if ([rArr containsObject:i.selectValue]) {
            [recentItems addObject:i];
        }
        NSMutableArray * a = [indices objectForKey:letter];
        [a addObject:i];
    }
}


-(void)getAllPersons{
    
    sqlite3_stmt *statement;
    sqlite3 *db;
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [path objectAtIndex:0];
    NSString *dbPathString = [docPath stringByAppendingPathComponent:@"people.db"];
    [items removeAllObjects];
    if (sqlite3_open([dbPathString UTF8String], &db)==SQLITE_OK) {
        
        NSString *querySql = [NSString stringWithFormat:@"SELECT * FROM PEOPLE"];
        const char* query_sql = [querySql UTF8String];
        
        if (sqlite3_prepare(db, query_sql, -1, &statement, NULL)==SQLITE_OK) {
            while (sqlite3_step(statement)==SQLITE_ROW) {
                
                NSString *firstName = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement, 1)];
                NSString *lastName = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement, 2)];
                NSString *photo = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement, 6)];
                
                NSString *personID = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement, 8)];
                
                NSString *name = [[firstName stringByAppendingString:@" "]stringByAppendingString:lastName];
                [items addObject:[[KNSelectorItem alloc] initWithDisplayValue:name selectValue:personID imageUrl:photo]];
            }
        }
        sqlite3_close(db);
    }
}



-(void)getMyContacts:(NSString*)table withClause:(NSString*)clause{
    
    sqlite3 *db;
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [path objectAtIndex:0];
    NSString *dbPathPeople = [docPath stringByAppendingPathComponent:@"people.db"];
    NSString *dbPathContacts = [docPath stringByAppendingPathComponent:table];

    if (sqlite3_open([dbPathPeople UTF8String], &db) == SQLITE_OK)
    {
        NSString *strSQLAttach = [NSString stringWithFormat:@"ATTACH DATABASE \'%s\' AS SECOND", [dbPathContacts UTF8String]];
        char *errorMessage;
        sqlite3_stmt *statment;

        if (sqlite3_exec(db, [strSQLAttach UTF8String], NULL, NULL, &errorMessage) == SQLITE_OK)
        {
            
            if (sqlite3_prepare_v2(db, [clause UTF8String], -1, &statment, nil) == SQLITE_OK){
                while (sqlite3_step(statment)==SQLITE_ROW) {
                    NSString *firstName = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statment, 1)];
                    NSString *lastName = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statment, 2)];
                    NSString *photo = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statment, 6)];
                    
                    NSString *personID = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statment, 8)];
                    
                    NSString *name = [[firstName stringByAppendingString:@" "]stringByAppendingString:lastName];
                    [items addObject:[[KNSelectorItem alloc] initWithDisplayValue:name selectValue:personID imageUrl:photo]];
                    NSLog(@"%@", name);
                }
            }
        sqlite3_close(db);
        }
    }
}


-(void)viewWillAppear:(BOOL)animated {
    
    if(contactToolbar.selectedSegmentIndex == 0){
          [self setTitle:@"My contacts"];
    } else if (contactToolbar.selectedSegmentIndex == 1){
        [self setTitle:@"Participants"];
    } else if(contactToolbar.selectedSegmentIndex == 2)
        [self setTitle:@"Pending"];
    
    [self.tableView reloadData];
  [super viewWillAppear:animated];

    
  // Layout UI elements
  CGRect f = self.view.frame;
  textFieldWrapper.frame = CGRectMake(0, 0, f.size.width, 44);
  self.searchTextField.frame = CGRectMake(6,6, f.size.width-12, 32);

  // Show or hide search control
  if ((textFieldWrapper.hidden = !self.allowSearchControl)) {
    self.tableView.frame = CGRectMake(0, 0, f.size.width, f.size.height - 40);
  } else {
    self.tableView.frame = CGRectMake(0, textFieldWrapper.frame.size.height, f.size.width, f.size.height - textFieldWrapper.frame.size.height - 40);
  }

  normalModeButton.frame = CGRectMake(f.size.width/2-90, f.size.height-44, 90, 44);
  selectedModeButton.frame = CGRectMake(f.size.width/2, f.size.height-44, 90, 44);
  modeIndicatorImageView.center = CGPointMake(normalModeButton.center.x, f.size.height-44+modeIndicatorImageView.frame.size.height/2);

  [self showHideModeButtons];
}

-(void)showHideModeButtons {  
  normalModeButton.hidden = selectedModeButton.hidden = modeIndicatorImageView.hidden = !self.allowModeButtons;

  CGRect tableFrame = self.tableView.frame;

  if (self.allowModeButtons) {
    tableFrame.size.height = CGRectGetMinY(modeIndicatorImageView.frame) - CGRectGetMinY(tableFrame);
  } else {
    tableFrame.size.height = CGRectGetHeight(self.view.bounds) - CGRectGetMinY(tableFrame);
  }

  self.tableView.frame = tableFrame;

}

-(void)setAllowModeButtons:(BOOL)allow {
  allowModeButtons = allow;
  [self showHideModeButtons];
}

-(void)updateSelectedCount {
  NSUInteger count = self.selectedItems.count;
  if (count == 0) {
    [selectedModeButton setTitle:NSLocalizedString(@"Selected (0)", @"0 is the initial count; nothing selected.") forState:UIControlStateNormal];
  } else {
    [selectedModeButton setTitle:[NSString stringWithFormat:NSLocalizedString(@"Selected (%d)", @"%d is the count of selected items"), self.selectedItems.count] forState:UIControlStateNormal];
  }
}

#pragma mark - UITableView Datasource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  
  if (selectorMode == KNSelectorModeNormal) {
    int noSec = useTableIndex ? [[self sortedIndices] count] : 1;
    return self.useRecentItems && recentItems.count ? noSec+1 : noSec;
  } else {
    return 1;
  }
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (selectorMode == KNSelectorModeSearch) {

    return filteredItems.count;
  } else if (selectorMode == KNSelectorModeNormal) {

    if (useRecentItems && section==0 && recentItems.count) {

      return recentItems.count;
    } else if (useTableIndex) {

      if (useRecentItems && recentItems.count) section -= 1;
      NSMutableArray * rows = [indices objectForKey:[[self sortedIndices] objectAtIndex:section]];

      return rows.count;
    } else {

      return items.count;
    }
  } else {

    return self.selectedItems.count;
  }
}

-(UITableViewCell*)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  
    static NSString *CellIdentifier = @"KNSelectorItemCell";
    UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    
    KNSelectorItem * item = [self itemAtIndexPath:indexPath];
  
    // Change the cell appearance    
    cell.textLabel.text = item.displayValue;
    if (item.imageUrl) {
        UIImage * imageFromURL;
        if([item.imageUrl isEqualToString:@""])
            imageFromURL = [UIImage imageNamed:@"defaultPerson.jpg"];
        else
            imageFromURL = [UIImage imageWithContentsOfFile:item.imageUrl];
        
        cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [cell.imageView setImage:imageFromURL];
    }
    
    
    if (item.image) {
        [cell.imageView setImage:item.image];
    }
    
    if([preselectedSelectedValue isEqualToString:item.selectValue] && indexPath.section != 0){
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        item.selected = YES;
        rowselected = indexPath;
    } else
        cell.accessoryType = item.selected ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    
    return cell;
}

#pragma mark - UITableView Delegate
-(void)tableView:(UITableView *)_tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [_tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
    if(self.infoType == CONTACT){
        PersonProfileViewController * person = [[PersonProfileViewController alloc] init];
        KNSelectorItem * item = [self itemAtIndexPath:indexPath];
        person.personID = item.selectValue;
        [[self navigationController] pushViewController:person animated:YES];
        return;
    }
    
    
    //user carrega na pessoa que tinha seleccionado, mal abre a pag
    if([rowselected isEqual: indexPath] && ![preselectedSelectedValue isEqualToString:@"-1"]){
        [self hideSelection:_tableView ];
        preselectedSelectedValue = @"-1";
        return;
    }
    
    // user carrega noutra pessoa para alem da que tinha seleccionado, mal abre a pag
    else if(rowselected != indexPath && ![preselectedSelectedValue isEqualToString:@"-1"]){
        [self hideSelection:_tableView ];
        preselectedSelectedValue = @"-1";
        //return;
    }
    
    if([rowselected isEqual: indexPath] ){
        [self hideSelection:_tableView ];
        return;
    }

    // Which item?
    if(rowselected){
        [self hideSelection:_tableView ];
    } 
    
        KNSelectorItem * item = [self itemAtIndexPath:indexPath];
        item.selected = !item.selected;
        rowselected = indexPath;
        // Recount selected items
        [self updateSelectedCount];
        
        // Update UI
        [_tableView deselectRowAtIndexPath:indexPath animated:YES];
        [_tableView cellForRowAtIndexPath:indexPath].accessoryType = item.selected ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
        if ([self.searchTextField isFirstResponder]) {
            self.searchTextField.tag = 1;
            [self.searchTextField resignFirstResponder];
        }
        
        // Delegate callback
        if (item.selected) {
            if ([delegate respondsToSelector:@selector(selector:didSelectItem:)]) [delegate selector:self didSelectItem:item];
        } else {
            if ([delegate respondsToSelector:@selector(selectorDidDeselectItem:)]) [delegate selector:self didDeselectItem:item];
            if (selectorMode==KNSelectorModeSelected) {
                [_tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            }
        }
    
}


-(void)hideSelection:(UITableView*)_tableView{
    KNSelectorItem * item = [self itemAtIndexPath:rowselected];
    item.selected = NO;
    [_tableView deselectRowAtIndexPath:rowselected animated:YES];
    [_tableView cellForRowAtIndexPath:rowselected].accessoryType = UITableViewCellAccessoryNone;//item.selected ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    if ([self.searchTextField isFirstResponder]) {
        self.searchTextField.tag = 1;
        [self.searchTextField resignFirstResponder];
    }
    rowselected = nil;
}




#pragma mark - UITextfield Delegate & Filtering

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
  NSString * searchString = [textField.text stringByReplacingCharactersInRange:range withString:string];
  if (searchString.length > 0) {
    selectorMode = KNSelectorModeSearch;
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"displayValue LIKE[cd] %@ OR displayValue LIKE[cd] %@",
                         [searchString stringByAppendingString:@"*"],
                         [NSString stringWithFormat:@"* %@*",searchString]];
    filteredItems = [items filteredArrayUsingPredicate:pred];
  } else {
    selectorMode = KNSelectorModeNormal;
  }
  [self.tableView reloadData];
  return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
  [textField resignFirstResponder];
  return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
  selectorMode = KNSelectorModeNormal;
  [self.tableView reloadData];
  return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
  if (self.searchTextField.tag == 1) {
    self.searchTextField.tag = 0;
    self.searchTextField.text = @"";
  }
  return YES;
}

#pragma mark - Custom getters/setters

-(NSArray*)selectedItems {
  NSPredicate *pred = [NSPredicate predicateWithFormat:@"selected = YES"];
  return [items filteredArrayUsingPredicate:pred];
}

-(NSArray*)sortedIndices {
  return [indices.allKeys sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
}

#pragma mark - Helpers

-(KNSelectorItem*)itemAtIndexPath:(NSIndexPath*)indexPath {
  // Determine the correct item at different settings
  int r = indexPath.row;
  int s = indexPath.section;
  if (selectorMode == KNSelectorModeSearch) {
    return [filteredItems objectAtIndex:r];
  }

  if (selectorMode == KNSelectorModeNormal) {
    if (self.useRecentItems && recentItems.count && s==0) {
      return [recentItems objectAtIndex:r];
    }
    if (useTableIndex) {
      if(self.useRecentItems && recentItems.count) s-=1;
      NSMutableArray * rows = [indices objectForKey:[[self sortedIndices] objectAtIndex:s]];
      return [rows objectAtIndex:r];
    }
    return [items objectAtIndex:r];
  }

  if (selectorMode == KNSelectorModeSelected) {
    return [self.selectedItems objectAtIndex:r];
  }

  return [items objectAtIndex:r];
}

#pragma mark - Cancel or Done button event

-(void)didCancel {

    // Clear all selections
  for (KNSelectorItem * i in self.selectedItems) {
    i.selected = NO;
  }
  // Delegate callback
    if ([delegate respondsToSelector:@selector(selectorDidCancelSelection:)]) {
      [delegate selectorDidCancelSelection:text];
  }
}

-(void)didFinish {
    
    
  // Delegate callback
  if ([delegate respondsToSelector:@selector(selectorDidFinishSelectionWithItems:)]) {      
      [delegate selector:self didFinishSelectionWithItems:self.selectedItems withText:text];
  }

  // Store recent items FIFO
  if (self.useRecentItems && self.maxNumberOfRecentItems < items.count) {
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray * array = [(NSMutableArray*)[defaults objectForKey:self.recentItemStorageKey] mutableCopy];
    if (!array) array = [NSMutableArray array];
    for (KNSelectorItem * i in self.selectedItems) {
      [array insertObject:i.selectValue atIndex:0];
    }
    while (array.count > self.maxNumberOfRecentItems) {
      [array removeLastObject];
    }
    [defaults setObject:array forKey:self.recentItemStorageKey];
    [defaults synchronize];
  }
    
}

#pragma mark - Handle mode switching UI

-(void)modeButtonDidTouch:(id)sender {
  UIButton * s = (UIButton*)sender;
  if (s.selected) return;

  if (s == normalModeButton) {
    selectorMode = self.searchTextField.text.length > 0 ? KNSelectorModeSearch : KNSelectorModeNormal;
    normalModeButton.selected = YES;
    selectedModeButton.selected = NO;
    [self.tableView reloadData];
    [UIView animateWithDuration:0.3 animations:^{
      if (!textFieldWrapper.hidden) {
        CGRect f = self.tableView.frame;
        f.origin.y = textFieldWrapper.frame.size.height;
        f.size.height -= f.origin.y;
        self.tableView.frame = f;
        textFieldWrapper.alpha = 1;
      }
      modeIndicatorImageView.center = CGPointMake(normalModeButton.center.x, modeIndicatorImageView.center.y);
    }];
  } else {
    selectorMode = KNSelectorModeSelected;
    normalModeButton.selected = NO;
    selectedModeButton.selected = YES;
    [self.tableView reloadData];
    [UIView animateWithDuration:0.3 animations:^{
      if (!textFieldWrapper.hidden) {
        CGRect f = self.tableView.frame;
        f.origin.y = 0;
        f.size.height += textFieldWrapper.frame.size.height;
        self.tableView.frame = f;
        textFieldWrapper.alpha = 0;
      }
      modeIndicatorImageView.center = CGPointMake(selectedModeButton.center.x, modeIndicatorImageView.center.y);
    }];
  }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    NSInteger lastSectionIndex = [self.tableView numberOfSections] - 1;
    if(lastSectionIndex == section)
        return 60.0f;
    return 0.0f;
}

#pragma mark - Table indices

- (NSString *)tableView:(UITableView *)aTableView titleForHeaderInSection:(NSInteger)section {
  if (selectorMode == KNSelectorModeNormal) {
    if (self.useRecentItems && recentItems.count) {
      if (section==0) return NSLocalizedString(@"Recent", nil);
      if (!useTableIndex) return @" ";
    }
    if (useTableIndex) {
      if(self.useRecentItems && recentItems.count) section-=1;
      return [[self sortedIndices] objectAtIndex:section];
    }
  }
  return nil;
}
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
  if (selectorMode == KNSelectorModeNormal && useTableIndex) {
    if (self.useRecentItems && recentItems.count) {
      NSMutableArray * iArr = [[self sortedIndices] mutableCopy];
      [iArr insertObject:@"★" atIndex:0];
      return iArr;
    } else {
      return [self sortedIndices];
    }
  }
  return nil;
  return selectorMode == KNSelectorModeNormal && useTableIndex ? [self sortedIndices] : nil;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
  return index;
}

#pragma mark - Other memory stuff

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)viewDidUnload {
  self.tableView = nil;
  self.searchTextField = nil;
  textFieldWrapper = nil;
  modeIndicatorImageView = nil;
  normalModeButton = nil;
  selectedModeButton = nil;
  
  [super viewDidUnload];
}



- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    
    CGRect navigationToolbarFrame = self.navigationController.navigationBar.frame;
    NSLog(@"%f", navigationToolbarFrame.origin.x);
        NSLog(@"%f", navigationToolbarFrame.origin.y);
        NSLog(@"%f", navigationToolbarFrame.size.width);
   // CGRect customToolbarFrame = CGRectOffset(navigationToolbarFrame, 0.0, navigationToolbarFrame.size.height);
    [UIView animateWithDuration:duration animations:^{
        _t.frame = CGRectMake(0, 228, self.view.frame.size.width, 40);//customToolbarFrame;
    }];

    
}

-(NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}

-(BOOL)shouldAutorotate{
    return NO;
}
@end
