//
//  NewTaskViewController.m
//  ToDoApp
//
//  Created by Jakub Truhlar on 22.11.14.
//  Copyright (c) 2014 Jakub Truhlar. All rights reserved.
//

#import "NewTaskViewController.h"
#import "AppDelegate.h"
#import "Macros.h"

@interface NewTaskViewController ()

@end

@implementation NewTaskViewController

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
    
    // Edit Task == user pressed a cell. Otherwise he pressed the newTask button
    if ([self.navigationItem.title isEqualToString:@"New Task"]) {
        
        // Default category name and color (This way because default category cannot be deleted)
        _taskCategorySelected = @"Work";
        _taskColorSelected = @"Red";
        
        // set up the bell ivar
        _notificationEnabled = true;
    }
    
    else {
        
        // Set the outlets
        _textField.text = _taskDescription;
        _datePicker.date = _date;
        
        if (_notificationEnabled == true) {
            
            [_bellBtn setImage:[UIImage imageNamed:@"bellOn.png"] forState:UIControlStateNormal];
        }
        
        else {
            
            [_bellBtn setImage:[UIImage imageNamed:@"bellOff.png"] forState:UIControlStateNormal];
        }
    }
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
    
    // Stop adding separators behind the last cell (Add footer for iOS7+ is this the best solution)
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    // Add the done button
    UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(addTask)];
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

- (void)addTask {
    
    // Display alert if the is no category name
    if ([_textField.text isEqualToString:@""]) {
        
        UIAlertController *alert = [UIAlertController
                                    alertControllerWithTitle:@"No task text"
                                    message:@"Describe your task"
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
    
    // Choose if the Done button should create or edit a row
    // Add data to database
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    NSError *error = nil;
    
    if ([self.navigationItem.title isEqualToString:@"New Task"]) {
        
        // Add data to database
        NSManagedObject *newTask = [NSEntityDescription insertNewObjectForEntityForName:@"Task" inManagedObjectContext:context];
        [newTask setValue: _textField.text forKey:@"taskDescription"]; // Text
        [newTask setValue: _taskCategorySelected forKey:@"taskCategory"]; // Category
        [newTask setValue: _taskColorSelected forKey:@"taskColor"]; // Color
        [newTask setValue: [self dateWithZeroSeconds:_datePicker.date] forKey:@"taskDate"]; // Date
        [newTask setValue: [NSNumber numberWithBool:false] forKey:@"taskCompleted"]; // Completed - 0
        [newTask setValue: [NSNumber numberWithBool:_notificationEnabled] forKey:@"taskNotify"]; // Text
        [newTask setValue: nil forKey:@"taskCompletedTime"]; // Time when the task was completed
    }
    
    else {
        
        // Edit data in database
        NSFetchRequest *taskRequest = [[NSFetchRequest alloc] initWithEntityName:@"Task"];
        NSArray *tasks = [context executeFetchRequest:taskRequest error:&error];
        NSManagedObject *editedTask = [tasks objectAtIndex:_taskID];
        
        [editedTask setValue: _textField.text forKey:@"taskDescription"]; // Text
        [editedTask setValue: _taskCategorySelected forKey:@"taskCategory"]; // Category
        [editedTask setValue: _taskColorSelected forKey:@"taskColor"]; // Color
        [editedTask setValue: [self dateWithZeroSeconds:_datePicker.date] forKey:@"taskDate"]; // Date
        [editedTask setValue: [NSNumber numberWithBool:false] forKey:@"taskCompleted"]; // Completed - 0
        [editedTask setValue: [NSNumber numberWithBool:_notificationEnabled] forKey:@"taskNotify"]; // Text
        [editedTask setValue: nil forKey:@"taskCompletedTime"]; // Time when the task was completed
    }
    
    // Save databaze
    [context save:&error];
    
    // Close the viewController (later could implement didSaveNotification to dismiss after save)
    [self closeController];
}

- (NSDate *)dateWithZeroSeconds:(NSDate *)date
{
    NSTimeInterval time = floor([date timeIntervalSinceReferenceDate] / 60.0) * 60.0;
    return  [NSDate dateWithTimeIntervalSinceReferenceDate:time];
}

- (void)closeController {
    
    // Vertical transition backwards
    [self dismissViewControllerAnimated:YES completion:nil];
    
    // Hide keyboard
    [_textField resignFirstResponder];
}

- (IBAction)bellBtnPressed:(id)sender {
    
    if ([[_bellBtn imageForState:UIControlStateNormal] isEqual:[UIImage imageNamed:@"bellOn.png"]]) {
        
        [_bellBtn setImage:[UIImage imageNamed:@"bellOff.png"] forState:UIControlStateNormal];
        _notificationEnabled = false;
    }
    
    else {
        
        [_bellBtn setImage:[UIImage imageNamed:@"bellOn.png"] forState:UIControlStateNormal];
        _notificationEnabled = true;
    }
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
    
    // Content
    cell.textLabel.text = [self.categoryNames objectAtIndex:indexPath.row];
    
    // Add color rectangle
    UIView *colorRectangle  = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 7, 40)];
    [cell addSubview:colorRectangle];
    
    if ([[self.categoryColors objectAtIndex:indexPath.row] isEqualToString:@"Red"]) {
        colorRectangle.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.8f];
    }
    
    else if ([[self.categoryColors objectAtIndex:indexPath.row] isEqualToString:@"Blue"]) {
        colorRectangle.backgroundColor = [[UIColor blueColor] colorWithAlphaComponent:0.8f];
    }
    
    else if ([[self.categoryColors objectAtIndex:indexPath.row] isEqualToString:@"Orange"]) {
        colorRectangle.backgroundColor = [[UIColor orangeColor] colorWithAlphaComponent:0.8f];
    }
    
    else if ([[self.categoryColors objectAtIndex:indexPath.row] isEqualToString:@"Green"]) {
        colorRectangle.backgroundColor = [[UIColor greenColor] colorWithAlphaComponent:0.8f];
    }
    
    else if ([[self.categoryColors objectAtIndex:indexPath.row] isEqualToString:@"Yellow"]) {
        colorRectangle.backgroundColor = [[UIColor yellowColor] colorWithAlphaComponent:0.8f];
    }
    
    else if ([[self.categoryColors objectAtIndex:indexPath.row] isEqualToString:@"Purple"]) {
        colorRectangle.backgroundColor = [[UIColor purpleColor] colorWithAlphaComponent:0.8f];
    }
    
    else if ([[self.categoryColors objectAtIndex:indexPath.row] isEqualToString:@"Brown"]) {
        colorRectangle.backgroundColor = [[UIColor brownColor] colorWithAlphaComponent:0.8f];
    }
    
    // Select the first cell by default
    if ([self.navigationItem.title isEqualToString:@"New Task"]) {
        
        if (indexPath.row == 0) {
            
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            [tableView selectRowAtIndexPath:indexPath animated:true scrollPosition:UITableViewScrollPositionNone];
        }
    }
    
    else {
        
        // Make a checkmark and select cell which should be selected (since category names are original its easy)
        if ([cell.textLabel.text isEqualToString:_taskCategorySelected]) {
            
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            [tableView selectRowAtIndexPath:indexPath animated:true scrollPosition:UITableViewScrollPositionNone];
        }
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
    _taskCategorySelected = [self.categoryNames objectAtIndex:indexPath.row];
    _taskColorSelected = [self.categoryColors objectAtIndex:indexPath.row];
    
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
    headerTitle.text = @"CATEGORY";
    
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
    
    return self.categoryNames.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    return 40;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 40;
}

@end
