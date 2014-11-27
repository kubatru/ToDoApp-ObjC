//
//  SettingsViewController.m
//  ToDoApp
//
//  Created by Jakub Truhlar on 20.11.14.
//  Copyright (c) 2014 Jakub Truhlar. All rights reserved.
//

#import "SettingsViewController.h"
#import "CategoryViewController.h"
#import "AppDelegate.h"
#import "Macros.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    // Apply appearance
    [self applyAppearance];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:true];
    
    // Get data
    [self getData];
}

- (void)getData {
    
    self.categoryNames = [[NSMutableArray alloc] init];
    self.categoryColors = [[NSMutableArray alloc] init];
    
    // Core Data
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Category"];
    
    NSError *error = nil;
    NSArray *objects = [context executeFetchRequest:request error:&error];
    
    // Fill the arrays with data
    for (int i = 0; i < [objects count]; i++) {
            
        [self.categoryNames addObject:[[objects objectAtIndex:i] valueForKey:@"catName"]];
        [self.categoryColors addObject:[[objects objectAtIndex:i] valueForKey:@"catColor"]];
    }
    
    // Reload tableView if data were loaded
    [self.tableView reloadData];
}

- (void)applyAppearance {
    
    // Add the done button
    UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(closeController)];
    [self.navigationItem setRightBarButtonItem:doneBtn];
    
    // Stop adding separators behind the last cell (Add footer for iOS7+ is this the best solution)
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    // Footer Separator - Do to position stuck bug defined here :(
    UIView *footerSeparator = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 736, 1)]; // max width (iP6+) is 736p so its easiest to do set is fixed since we dont have a landscape mod in the app
    footerSeparator.backgroundColor = [UIColor separatorColor];
    self.tableView.tableFooterView = footerSeparator;
}

#pragma mark - UITableView

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Custom cell
    // DO NOT FORGET TO NOT use the identifier so the cell are not reused.
    UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:nil];
    
    if (cell == nil) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
    }
    
    if (indexPath.section == 0) {
        
        // Last cell is the add button
        if (indexPath.row == [self.categoryNames count]) {
            
            UIButton *button = [UIButton buttonWithType:UIButtonTypeContactAdd];
            [button addTarget:self action:@selector(newCategoryPressed:) forControlEvents:UIControlEventTouchUpInside];
            button.frame = CGRectMake(0, 0, self.tableView.frame.size.width, cell.frame.size.height);
            [cell.contentView addSubview:button];
            cell.backgroundColor = [UIColor whiteColor];
        }
        
        else {
            
            // Regular cells data setup
            cell.textLabel.text = [self.categoryNames objectAtIndex:indexPath.row];
            
            if ([[self.categoryColors objectAtIndex:indexPath.row] isEqualToString:@"Red"]) {
                cell.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.8f];
            }
            
            else if ([[self.categoryColors objectAtIndex:indexPath.row] isEqualToString:@"Blue"]) {
                cell.backgroundColor = [[UIColor blueColor] colorWithAlphaComponent:0.8f];
            }
            
            else if ([[self.categoryColors objectAtIndex:indexPath.row] isEqualToString:@"Orange"]) {
                cell.backgroundColor = [[UIColor orangeColor] colorWithAlphaComponent:0.8f];
            }
            
            else if ([[self.categoryColors objectAtIndex:indexPath.row] isEqualToString:@"Green"]) {
                cell.backgroundColor = [[UIColor greenColor] colorWithAlphaComponent:0.8f];
            }
            
            else if ([[self.categoryColors objectAtIndex:indexPath.row] isEqualToString:@"Yellow"]) {
                cell.backgroundColor = [[UIColor yellowColor] colorWithAlphaComponent:0.8f];
            }
            
            else if ([[self.categoryColors objectAtIndex:indexPath.row] isEqualToString:@"Purple"]) {
                cell.backgroundColor = [[UIColor purpleColor] colorWithAlphaComponent:0.8f];
            }
            
            else if ([[self.categoryColors objectAtIndex:indexPath.row] isEqualToString:@"Brown"]) {
                cell.backgroundColor = [[UIColor brownColor] colorWithAlphaComponent:0.8f];
            }
        }
    }
    
    else {
        
        // Notification cell
        if (indexPath.row == 0) {
            
            cell.textLabel.text = @"Enable Notification";
            UISwitch *switchView = [[UISwitch alloc] initWithFrame:CGRectZero];
            cell.accessoryView = switchView;
            [switchView addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
            
            // Core Data
            AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
            NSManagedObjectContext *context = [appDelegate managedObjectContext];
            NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Settings"];
            
            NSError *error = nil;
            NSManagedObject *object = [[context executeFetchRequest:request error:&error] objectAtIndex:0];
            
            if ([[object valueForKey:@"notifications"] isEqualToNumber:[NSNumber numberWithBool:true]]) {
                
                [switchView setOn:true];
            }
            
            else {
                
                [switchView setOn:false];
            }
        }
        
        // Sorted by cell
        else {
            
            cell.textLabel.text = @"Tasks sorted";
            
            // Core Data
            AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
            NSManagedObjectContext *context = [appDelegate managedObjectContext];
            NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Settings"];
            
            NSError *error = nil;
            NSManagedObject *object = [[context executeFetchRequest:request error:&error] objectAtIndex:0];
            
            if ([[object valueForKey:@"sortedAtoZ"] isEqualToNumber:[NSNumber numberWithBool:true]]) {
                
                cell.detailTextLabel.text = @"Alphabetical";
            }
            
            else {
                
                cell.detailTextLabel.text = @"by Date";
            }
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Tasks sorted by cell
    if (indexPath.section == 1 && indexPath.row == 1) {
        
        // Core Data
        AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        NSManagedObjectContext *context = [appDelegate managedObjectContext];
        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Settings"];
        
        NSError *error = nil;
        NSManagedObject *object = [[context executeFetchRequest:request error:&error] objectAtIndex:0];
        
        // Add observer
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTasksSortedByCell) name:NSManagedObjectContextDidSaveNotification object:context];
        
        // ActionSheet
        UIAlertController *alert = [UIAlertController
                                    alertControllerWithTitle:@"Tasks sorted by"
                                    message:@""
                                    preferredStyle:UIAlertControllerStyleActionSheet];
        
        [self presentViewController:alert animated:YES completion:nil];
        
        UIAlertAction *first = [UIAlertAction
                                actionWithTitle:@"Alphabet"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action)
                                {
                                    NSError *error = nil;
                                    [object setValue:[NSNumber numberWithBool:true] forKey:@"sortedAtoZ"];
                                    [context save:&error];
                                    
                                    // Remove observer
                                    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSManagedObjectContextDidSaveNotification object:context];
                                    
                                    // Dismiss the actionSheet
                                    [alert dismissViewControllerAnimated:YES completion:nil];
                                }];
        
        UIAlertAction *second = [UIAlertAction
                                 actionWithTitle:@"Date"
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * action)
                                 {
                                     NSError *error = nil;
                                     [object setValue:[NSNumber numberWithBool:false] forKey:@"sortedAtoZ"];
                                     [context save:&error];
                                     
                                     // Remove observer
                                     [[NSNotificationCenter defaultCenter] removeObserver:self name:NSManagedObjectContextDidSaveNotification object:context];
                                     
                                     // Dismiss the actionSheet
                                     [alert dismissViewControllerAnimated:YES completion:nil];
                                 }];
        
        UIAlertAction *cancel = [UIAlertAction
                                 actionWithTitle:@"Zrušit"
                                 style:UIAlertActionStyleCancel
                                 handler:^(UIAlertAction * action)
                                 {
                                     // Remove observer
                                     [[NSNotificationCenter defaultCenter] removeObserver:self name:NSManagedObjectContextDidSaveNotification object:context];
                                     
                                     // Dismiss the actionSheet
                                     [alert dismissViewControllerAnimated:YES completion:nil];
                                 }];
        
        [alert addAction:first];
        [alert addAction:second];
        [alert addAction:cancel];
    }
    
    // Unselect a cell
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (section == 0) {
        
        return [self.categoryNames count] + 1;
    }
    
    else {
        
        return 2;
    }
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 45;
}

// Section View
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    // Text
    UILabel *headerTitle = [[UILabel alloc] init];
    headerTitle.frame = CGRectMake(15, 7, 736, 39);
    headerTitle.font = [UIFont fontWithName:@"HelveticaNeue" size:12];
    headerTitle.textColor = [UIColor grayColor];
    
    if (section == 0) {
        
        headerTitle.text = @"CATEGORIES";
    }
    else {
        
        headerTitle.text = @"OTHERS";
    }
    
    UIView *separator  = [[UIView alloc] initWithFrame:CGRectMake(0, 39, 736, 1)];
    separator.backgroundColor = [UIColor separatorColor];
    
    UIView *headerView = [[UIView alloc] init];
    headerView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.95f]; // Cheap way to do a translucent effect (better add a blur class)
    [headerView addSubview:headerTitle];
    [headerView addSubview:separator];
    // Header background so the tableView can be dynamic and it will looks still great
    
    return headerView;
}

#pragma mark - Side methods

- (void)reloadTasksSortedByCell {
    
    // Reload cell
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:1]] withRowAnimation:UITableViewRowAnimationNone];
}

- (IBAction)switchChanged:(id)sender {
    
    // Core Data
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Settings"];
    
    NSError *error = nil;
    NSManagedObject *object = [[context executeFetchRequest:request error:&error] objectAtIndex:0];
    
    if ([sender isOn]) {
        
        [object setValue:[NSNumber numberWithBool:true] forKey:@"notifications"];
    }
    
    else {
        
        [object setValue:[NSNumber numberWithBool:false] forKey:@"notifications"];
    }
    
    // Save DB
    [context save:&error];
}

- (void)closeController
{
    // Vertical transition backwards
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)newCategoryPressed:(id)sender {
    
    // This is initialization with storyboard identification
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    CategoryViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"newCategory"];
    viewController.navigationItem.title = @"New Category";
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
    [self presentViewController:navigationController animated:true completion:nil];
}

@end
