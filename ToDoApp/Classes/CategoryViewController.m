//
//  CategoryViewController.m
//  ToDoApp
//
//  Created by Jakub Truhlar on 20.11.14.
//  Copyright (c) 2014 Jakub Truhlar. All rights reserved.
//

#import "CategoryViewController.h"
#import "Macros.h"
#import "AppDelegate.h"

@interface CategoryViewController ()

@end

@implementation CategoryViewController


- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    // Create array of colors
    colorArray = @[@"Red", @"Blue", @"Orange", @"Green", @"Yellow", @"Purple", @"Brown"];
    
    // Apply appearance
    [self applyAppearance];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:true];
    
    // Set default color
    colorSelected = [colorArray objectAtIndex:0];
    
    [self getData];
}

- (void)getData {
    
    // Get all category names (there cannot be the same name for two and more categories) so we will compare them
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    NSFetchRequest *categoryRequest = [[NSFetchRequest alloc] initWithEntityName:@"Category"];
    
    NSError *error = nil;
    NSArray *categories = [context executeFetchRequest:categoryRequest error:&error];
    categoryArray = [NSMutableArray new];
    
    for (int i = 0; i < [categories count]; i++) {
        
        [categoryArray addObject:[[categories objectAtIndex:i] valueForKey:@"catName"]];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)applyAppearance {
    
    // Stop adding separators behind the last cell (Add footer for iOS7+ is this the best solution)
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    // Add the done button
    UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(addCategory)];
    [self.navigationItem setRightBarButtonItem:doneBtn];
    
    // Add the done button
    UIBarButtonItem *cancelBtn = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(closeController)];
    [self.navigationItem setLeftBarButtonItem:cancelBtn];
    
    // Footer Separator - Do to position stuck bug defined here :(
    UIView *footerSeparator = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 736, 1)]; // max width (iP6+) is 736p so its easiest to do set is fixed since we dont have a landscape mod in the app
    footerSeparator.backgroundColor = [UIColor separatorColor];
    self.tableView.tableFooterView = footerSeparator;
    
    // Keyboard
    [_textField becomeFirstResponder];
}

- (void)addCategory {
    
    // Display alert if there is no category name
    if ([_textField.text isEqualToString:@""]) {
        
        UIAlertController *alert = [UIAlertController
                                    alertControllerWithTitle:@"No category name"
                                    message:@"Type a name of the new category"
                                    preferredStyle:UIAlertControllerStyleAlert];
        
        [self presentViewController:alert animated:YES completion:nil];
        
        UIAlertAction *ok = [UIAlertAction
                                 actionWithTitle:@"Ok"
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction *action)
                                 {
                                     [alert dismissViewControllerAnimated:YES completion:nil];
                                 }];
        [alert addAction:ok];
    }
    
    // Display alert if the accepted category name already exists
    else if ([categoryArray containsObject:_textField.text]) {
        
        UIAlertController *alert = [UIAlertController
                                    alertControllerWithTitle:@"Category already exists"
                                    message:@"Type an original category name"
                                    preferredStyle:UIAlertControllerStyleAlert];
        
        [self presentViewController:alert animated:YES completion:nil];
        
        UIAlertAction *ok = [UIAlertAction
                             actionWithTitle:@"Ok"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction *action)
                             {
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                                 _textField.text = @"";
                             }];
        [alert addAction:ok];
    }
    
    else {
        
        // Add data to database
        AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        NSManagedObjectContext *context = [appDelegate managedObjectContext];
        NSManagedObject *newCategory = [NSEntityDescription insertNewObjectForEntityForName:@"Category" inManagedObjectContext:context];
        [newCategory setValue: _textField.text forKey:@"catName"];
        [newCategory setValue: colorSelected forKey:@"catColor"];
        
        // Save databaze
        NSError *error = nil;
        [context save:&error];
        
        // Close the viewController (later could implement didSaveNotification to dismiss after save)
        [self closeController];
    }
}

- (void)closeController {
    
    // Vertical transition backwards
    [self dismissViewControllerAnimated:YES completion:nil];
    
    // Hide keyboard
    [_textField resignFirstResponder];
}

#pragma mark - UITableView

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Values
    NSString *CellIdentifier = @"colorCell";
    
    // Custom cell
    UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Add color rectangle and specify its color in switch statement
    UIView *colorRectangle  = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 7, cell.frame.size.height)];
    [cell addSubview:colorRectangle];
    
    switch (indexPath.row) {
        case 0:
            cell.textLabel.text = [colorArray objectAtIndex:indexPath.row];
            colorRectangle.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.8f];
            break;
            
        case 1:
            cell.textLabel.text = [colorArray objectAtIndex:indexPath.row];
            colorRectangle.backgroundColor = [[UIColor blueColor] colorWithAlphaComponent:0.8f];
            break;
            
        case 2:
            cell.textLabel.text = [colorArray objectAtIndex:indexPath.row];
            colorRectangle.backgroundColor = [[UIColor orangeColor] colorWithAlphaComponent:0.8f];
            break;
            
        case 3:
            cell.textLabel.text = [colorArray objectAtIndex:indexPath.row];
            colorRectangle.backgroundColor = [[UIColor greenColor] colorWithAlphaComponent:0.8f];
            break;
            
        case 4:
            cell.textLabel.text = [colorArray objectAtIndex:indexPath.row];
            colorRectangle.backgroundColor = [[UIColor yellowColor] colorWithAlphaComponent:0.8f];
            break;
            
        case 5:
            cell.textLabel.text = [colorArray objectAtIndex:indexPath.row];
            colorRectangle.backgroundColor = [[UIColor purpleColor] colorWithAlphaComponent:0.8f];
            break;
            
        case 6:
            cell.textLabel.text = [colorArray objectAtIndex:indexPath.row];
            colorRectangle.backgroundColor = [[UIColor brownColor] colorWithAlphaComponent:0.8f];
            break;
            
        default:
            break;
    }
    
    // Select the first cell by default
    if (indexPath.row == 0 && [colorSelected isEqualToString:[colorArray objectAtIndex:0]]) {
        
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        [tableView selectRowAtIndexPath:indexPath animated:true scrollPosition:UITableViewScrollPositionNone];
    }
    
    // Cell selected color
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

// Tick
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
    
    // Set ivar to store selected color
    colorSelected = [colorArray objectAtIndex:indexPath.row];
    
    // Hide keyboard
    [_textField resignFirstResponder];
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryNone;
    
}

// Section View
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    // Text
    UILabel *headerTitle = [[UILabel alloc] init];
    headerTitle.frame = CGRectMake(15, 7, 736, 39);
    headerTitle.font = [UIFont fontWithName:@"HelveticaNeue" size:12];
    headerTitle.textColor = [UIColor grayColor];
    headerTitle.text = @"CATEGORY COLOR";
    
    UIView *separator  = [[UIView alloc] initWithFrame:CGRectMake(0, 39, 736, 1)];
    separator.backgroundColor = [UIColor separatorColor];
    
    UIView *headerView = [[UIView alloc] init];
    headerView.backgroundColor = [UIColor whiteColor];
    [headerView addSubview:headerTitle];
    [headerView addSubview:separator];
    // Header background so the tableView can be dynamic and it will looks still great
    
    return headerView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 7;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    return 40;
}

@end
