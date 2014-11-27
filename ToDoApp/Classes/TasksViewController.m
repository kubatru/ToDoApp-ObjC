//
//  TasksViewController.m
//  ToDoApp
//
//  Created by Jakub Truhlar on 19.11.14.
//  Copyright (c) 2014 Jakub Truhlar. All rights reserved.
//

#import "TasksViewController.h"
#import "SettingsViewController.h"
#import "Macros.h"
#import "AppDelegate.h"
#import "NewTaskViewController.h"

@interface TasksViewController ()

@end

@implementation TasksViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    // Apply appearance
    [self applyAppearance];
    
    // Setting up the settings
    [self setupData];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:true];
    
    // Getting data from the database
    [self getData];
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:true];
    
    // Dont forget to remove the observer
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setupData {
    
    // Core Data
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    NSFetchRequest *settingsRequest = [[NSFetchRequest alloc] initWithEntityName:@"Settings"];
    
    NSError *error = nil;
    NSArray *settings = [context executeFetchRequest:settingsRequest error:&error];
    
    // First setup the settings
    if ([settings count] == 0) {
        
        // Create default settings
        NSManagedObject *defaultSettings = [NSEntityDescription insertNewObjectForEntityForName:@"Settings" inManagedObjectContext:context];
        [defaultSettings setValue:[NSNumber numberWithBool:true] forKey:@"notifications"];
        [defaultSettings setValue:[NSNumber numberWithBool:false] forKey:@"sortedAtoZ"];
        // Save databaze
        [context save:&error];
        
        // ivars
        notificationsEnabled = true;
        sortedAtoZ = false;
    }
    
    // First setup the categories
    NSFetchRequest *categoryRequest = [[NSFetchRequest alloc] initWithEntityName:@"Category"];
    NSArray *categories = [context executeFetchRequest:categoryRequest error:&error];
    
    if ([categories count] == 0) {
        
        // Create default categories
        NSManagedObject *defaultCategory = [NSEntityDescription insertNewObjectForEntityForName:@"Category" inManagedObjectContext:context];
        [defaultCategory setValue: @"Work" forKey:@"catName"];
        [defaultCategory setValue: @"Red" forKey:@"catColor"];
        // Save databaze
        [context save:&error];
        
        defaultCategory = [NSEntityDescription insertNewObjectForEntityForName:@"Category" inManagedObjectContext:context];
        [defaultCategory setValue: @"School" forKey:@"catName"];
        [defaultCategory setValue: @"Blue" forKey:@"catColor"];
        // Save databaze
        [context save:&error];
        
        defaultCategory = [NSEntityDescription insertNewObjectForEntityForName:@"Category" inManagedObjectContext:context];
        [defaultCategory setValue: @"Family" forKey:@"catName"];
        [defaultCategory setValue: @"Orange" forKey:@"catColor"];
        // Save databaze
        [context save:&error];
        
        defaultCategory = [NSEntityDescription insertNewObjectForEntityForName:@"Category" inManagedObjectContext:context];
        [defaultCategory setValue: @"Events" forKey:@"catName"];
        [defaultCategory setValue: @"Green" forKey:@"catColor"];
        // Save databaze
        [context save:&error];
    }
}

- (void)getData {
    
    // CORE DATA
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    NSFetchRequest *taskRequest = [[NSFetchRequest alloc] initWithEntityName:@"Task"];
    
    // Add observer
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getData) name:NSManagedObjectContextDidSaveNotification object:context];
    
    NSError *error = nil;
    NSArray *tasks = [context executeFetchRequest:taskRequest error:&error];
    
    // Alloc/init arrays and fill it with data
    self.activeTaskCategories = [NSMutableArray new];
    self.activeTaskColors = [NSMutableArray new];
    self.activeTaskDates = [NSMutableArray new];
    self.activeTaskDescriptions = [NSMutableArray new];
    self.activeTaskID = [NSMutableArray new];
    self.activeTaskNotify = [NSMutableArray new];
    
    self.completedTaskColors = [NSMutableArray new];
    self.completedTaskDescriptions = [NSMutableArray new];
    self.completedTaskCompleteTimes = [NSMutableArray new];
    
    self.taskCompleted = [NSMutableArray new];
    
    // Add data to arrays
    for (int i = 0; i < [tasks count]; i++) {
        
        [self.taskCompleted addObject:[[tasks objectAtIndex:i] valueForKey:@"taskCompleted"]];
        
        if ([[self.taskCompleted objectAtIndex:i] boolValue] == 0) {
            
            [self.activeTaskDescriptions addObject:[[tasks objectAtIndex:i] valueForKey:@"taskDescription"]];
            [self.activeTaskDates addObject:[[tasks objectAtIndex:i] valueForKey:@"taskDate"]];
            [self.activeTaskColors addObject:[[tasks objectAtIndex:i] valueForKey:@"taskColor"]];
            [self.activeTaskCategories addObject:[[tasks objectAtIndex:i] valueForKey:@"taskCategory"]];
            [self.activeTaskNotify addObject:[[tasks objectAtIndex:i] valueForKey:@"taskNotify"]];
            
            // Get the unique value of cells representing its positions in database
            [self.activeTaskID addObject:[NSNumber numberWithInt:i]];
        }
        
        else {
            
            [self.completedTaskDescriptions addObject:[[tasks objectAtIndex:i] valueForKey:@"taskDescription"]];
            [self.completedTaskCompleteTimes addObject:[[tasks objectAtIndex:i] valueForKey:@"taskCompletedTime"]];
            [self.completedTaskColors addObject:[[tasks objectAtIndex:i] valueForKey:@"taskColor"]];
        }
    }
    
    // SORTING + NOTIFICATIONS
    // Core Data
    NSFetchRequest *settingsRequest = [[NSFetchRequest alloc] initWithEntityName:@"Settings"];
    NSArray *settings = [context executeFetchRequest:settingsRequest error:&error];
    
    // First setup the settings
    if ([settings count] != 0) {
        
        NSManagedObject *defaultSettings = [[context executeFetchRequest:settingsRequest error:&error] objectAtIndex:0];
        
        // ivars
        notificationsEnabled = [[defaultSettings valueForKey:@"notifications"] boolValue];
        sortedAtoZ = [[defaultSettings valueForKey:@"sortedAtoZ"] boolValue];
    }
    
    else {
        
        // ivars
        notificationsEnabled = true;
        sortedAtoZ = false;
    }
    
    // Sort active arrays by date of active tasks (This will trigger everytime, even when user set the alphabet sort. Reason: Need date sort to connect the notifications with right badge number - read next comments to understand)
    [self dateSortOfActiveTasks];
    
    // Reset the notifications badge number (will recount it - If so)
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber: 0];
    // Cancel all notifications before recreating them (If so)
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    
    // Schedule Local notifications (little MUST-DO trick where every notification get number for badge by its position in fireDate queue) so not typical actualBadge+1 but this trick = im able to show correct badge number even when multiple locations arrived at the same time!
    if (notificationsEnabled == true) {
        
        [self createLocalNotifications];
    }
    
    // If users set up alphabetical sorting, do it.
    if (sortedAtoZ == true) {
        
        [self alphabeticalSortOfActiveTasks];
    }
    
    // Feature: Sorting completed tasks by date when they were completed (top cell = the most recently completed task)
    [self dateSortOfCompletedTasks];
    
    // Reload tableView if data were loaded
    [self.tableView reloadData];
}

- (void)createLocalNotifications {
    
    int activeTasksNotifyEnabledCount = 0;
    
    for (int i = 0; i < [self.activeTaskNotify count]; i++) {
        
        if ([[self.activeTaskNotify objectAtIndex:i] boolValue] == true) {
            
            activeTasksNotifyEnabledCount += 1;
        }
    }
    
    for (int i = 0; i < activeTasksNotifyEnabledCount; i++) {
        
        // Schedule the notification
        UILocalNotification *localNotification = [UILocalNotification new];
        localNotification.fireDate = [self.activeTaskDates objectAtIndex:i];
        localNotification.alertBody = [self.activeTaskDescriptions objectAtIndex:i];
        localNotification.alertAction = @"Show the Task";
        localNotification.timeZone = [NSTimeZone defaultTimeZone];
        
        localNotification.applicationIconBadgeNumber = i + 1;
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)applyAppearance {
    
    // Nonconvence navigation bar buttons (next to each other)
    UIBarButtonItem *newTask = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(newTaskBtnPressed:)];
    UIBarButtonItem *settings = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Settings"] style:UIBarButtonItemStylePlain target:self action:@selector(settingsBtnPressed:)];
    [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:newTask, settings, nil]];
    
    // Stop adding separators behind the last cell (Add footer for iOS7+ is this the best solution)
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    // Footer Separator - Do to position stuck bug defined here :(
    UIView *footerSeparator = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 736, 1)]; // max width (iP6+) is 736p so its easiest to do set is fixed since we dont have a landscape mod in the app
    footerSeparator.backgroundColor = [UIColor separatorColor];
    self.tableView.tableFooterView = footerSeparator;
}

#pragma mark - Transitions

- (IBAction)newTaskBtnPressed:(id)sender {
    
    // This is initialization with storyboard identification
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    NewTaskViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"newTask"];
    viewController.navigationItem.title = @"New Task";
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
    [self presentViewController:navigationController animated:true completion:nil];
}

- (IBAction)settingsBtnPressed:(id)sender {
    
    // This is initialization with storyboard identification
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    SettingsViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"settings"];
    viewController.navigationItem.title = @"Settings";
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
    [self presentViewController:navigationController animated:true completion:nil];
}

- (void)cellPressedWithDescription:(NSString *)description Date:(NSDate*)date Color:(NSString*)color Category:(NSString*)category Notify:(bool)notify ID:(NSUInteger)_id {
    
    // This is initialization with storyboard identification
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    NewTaskViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"newTask"];
    viewController.navigationItem.title = @"Edit Task";
    viewController.taskDescription = description;
    viewController.date = date;
    viewController.taskCategorySelected = category;
    viewController.taskColorSelected = color;
    viewController.notificationEnabled = notify;
    viewController.taskID = _id;
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
    [self presentViewController:navigationController animated:true completion:nil];
}

#pragma mark - UITableView

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        
        // Custom cell
        TaskCell *cell = (TaskCell*)[tableView dequeueReusableCellWithIdentifier:nil];
        
        if (cell == nil) {
            
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"TaskCell" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        
        // SWTableView setup
        // Left and right buttons in a cell
        NSMutableArray *rightUtilityButtons = [NSMutableArray new];
        NSMutableArray *leftUtilityButtons = [NSMutableArray new];
        
        NSDictionary *buttonsAttributes = [NSDictionary dictionaryWithObjects:@[[UIFont fontWithName:@"HelveticaNeue-Bold" size:30], [UIColor whiteColor]] forKeys: @[NSFontAttributeName, NSForegroundColorAttributeName]];
        
        // Change text symbols a bit
        [rightUtilityButtons sw_addUtilityButtonWithColor:[UIColor orangeColor] attributedTitle:[[NSAttributedString alloc] initWithString:@"✕" attributes:buttonsAttributes]];
        [leftUtilityButtons sw_addUtilityButtonWithColor:[UIColor greenColor] attributedTitle:[[NSAttributedString alloc] initWithString:@"✓" attributes:buttonsAttributes]];
        
        cell.delegate = self;
        cell.rightUtilityButtons = rightUtilityButtons;
        cell.leftUtilityButtons = leftUtilityButtons;
        
        // Text
        cell.descriptionLabel.text = [self.activeTaskDescriptions objectAtIndex:indexPath.row];
        
        // Show or hide date
        if ([[self.activeTaskNotify objectAtIndex:indexPath.row] boolValue] == true) {
            
            // Formated date by the iOS language
            NSDateFormatter *dateFormatter = [NSDateFormatter new];
            [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:[[NSLocale preferredLanguages] firstObject]]];
            [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
            [dateFormatter setDateStyle:NSDateFormatterShortStyle];
            cell.dateLabel.text = [dateFormatter stringFromDate:[self.activeTaskDates objectAtIndex:indexPath.row]];
        }
        
        else {
            cell.dateLabel.hidden = true;
        }
            
        if ([[self.activeTaskColors objectAtIndex:indexPath.row] isEqualToString:@"Red"]) {
            cell.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.8f];
        }
            
        else if ([[self.activeTaskColors objectAtIndex:indexPath.row] isEqualToString:@"Blue"]) {
            cell.backgroundColor = [[UIColor blueColor] colorWithAlphaComponent:0.8f];
        }
        
        else if ([[self.activeTaskColors objectAtIndex:indexPath.row] isEqualToString:@"Orange"]) {
            cell.backgroundColor = [[UIColor orangeColor] colorWithAlphaComponent:0.8f];
        }
        
        else if ([[self.activeTaskColors objectAtIndex:indexPath.row] isEqualToString:@"Green"]) {
            cell.backgroundColor = [[UIColor greenColor] colorWithAlphaComponent:0.8f];
        }
        
        else if ([[self.activeTaskColors objectAtIndex:indexPath.row] isEqualToString:@"Yellow"]) {
            cell.backgroundColor = [[UIColor yellowColor] colorWithAlphaComponent:0.8f];
        }
        
        else if ([[self.activeTaskColors objectAtIndex:indexPath.row] isEqualToString:@"Purple"]) {
            cell.backgroundColor = [[UIColor purpleColor] colorWithAlphaComponent:0.8f];
        }
        
        else if ([[self.activeTaskColors objectAtIndex:indexPath.row] isEqualToString:@"Brown"]) {
            cell.backgroundColor = [[UIColor brownColor] colorWithAlphaComponent:0.8f];
        }
        
        return cell;
    }
    
    else {
        
        // Custom cell
        CompletedTaskCell *cell = (CompletedTaskCell*)[tableView dequeueReusableCellWithIdentifier:nil];
        
        if (cell == nil) {
            
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"CompletedTaskCell" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        
        // Strikethrough text programatically
        cell.descriptionLabel.attributedText = [[NSAttributedString alloc] initWithString:[self.completedTaskDescriptions objectAtIndex:indexPath.row] attributes:@{NSStrikethroughStyleAttributeName:@(NSUnderlineStyleSingle)}];
        
        if ([[self.completedTaskColors objectAtIndex:indexPath.row] isEqualToString:@"Red"]) {
            cell.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.1f];
        }
        
        else if ([[self.completedTaskColors objectAtIndex:indexPath.row] isEqualToString:@"Blue"]) {
            cell.backgroundColor = [[UIColor blueColor] colorWithAlphaComponent:0.1f];
        }
        
        else if ([[self.completedTaskColors objectAtIndex:indexPath.row] isEqualToString:@"Orange"]) {
            cell.backgroundColor = [[UIColor orangeColor] colorWithAlphaComponent:0.1f];
        }
        
        else if ([[self.completedTaskColors objectAtIndex:indexPath.row] isEqualToString:@"Green"]) {
            cell.backgroundColor = [[UIColor greenColor] colorWithAlphaComponent:0.1f];
        }
        
        else if ([[self.completedTaskColors objectAtIndex:indexPath.row] isEqualToString:@"Yellow"]) {
            cell.backgroundColor = [[UIColor yellowColor] colorWithAlphaComponent:0.1f];
        }
        
        else if ([[self.completedTaskColors objectAtIndex:indexPath.row] isEqualToString:@"Purple"]) {
            cell.backgroundColor = [[UIColor purpleColor] colorWithAlphaComponent:0.1f];
        }
        
        else if ([[self.completedTaskColors objectAtIndex:indexPath.row] isEqualToString:@"Brown"]) {
            cell.backgroundColor = [[UIColor brownColor] colorWithAlphaComponent:0.1f];
        }
        
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        
        // Show detail editable controller
        
        NSString *descriptionString = [NSString stringWithFormat:@"%@", [self.activeTaskDescriptions objectAtIndex:indexPath.row]];
        NSDate *date = [self.activeTaskDates objectAtIndex:indexPath.row];
        NSString *categoryString = [NSString stringWithFormat:@"%@", [self.activeTaskCategories objectAtIndex:indexPath.row]];
        NSString *colorString = [NSString stringWithFormat:@"%@", [self.activeTaskColors objectAtIndex:indexPath.row]];
        bool notifyBool = [[self.activeTaskNotify objectAtIndex:indexPath.row] boolValue];
        NSUInteger idInteger = [[self.activeTaskID objectAtIndex:indexPath.row] integerValue];
        
        [self cellPressedWithDescription:descriptionString Date:date Color:colorString Category:categoryString Notify:notifyBool ID:idInteger];
    }
    
    else {
        
        // Unselect a cell
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        
        return 65;
    }
    
    else {
        
        return 44;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (section == 0) {
        
        return [self.activeTaskDescriptions count];
    }
    
    else {
        
        return [self.completedTaskDescriptions count];
    }
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
        
        headerTitle.text = @"ACTIVE TASKS";
    }
    else {
        
        headerTitle.text = @"COMPLETED TASKS";
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

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    return 40;
}

#pragma mark - SWTableViewCellDelegate

- (BOOL)swipeableTableViewCellShouldHideUtilityButtonsOnSwipe:(SWTableViewCell *)cell;
{
    return true;
}

// Delete button
- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index {
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    // We remove the row from database directly but numberOfRowsInSection take the number of rows by activeTaskDescriptions array so remove one entry to prevent an error on deleteRowsAtIndexPaths.
    [self.activeTaskDescriptions removeObjectAtIndex:index];
    
    // Animate
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
    
    // Core Data
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    NSFetchRequest *taskRequest = [[NSFetchRequest alloc] initWithEntityName:@"Task"];
    
    NSError *error = nil;
    NSArray *tasks = [context executeFetchRequest:taskRequest error:&error];
    
    NSUInteger taskID = [[self.activeTaskID objectAtIndex:indexPath.row] integerValue];
    NSManagedObject *object = [tasks objectAtIndex:taskID];
    [context deleteObject:object];
    [context save:&error];
}

// Complete button
- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerLeftUtilityButtonWithIndex:(NSInteger)index {
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    // We remove the row from database directly but numberOfRowsInSection take the number of rows by activeTaskDescriptions array so remove one entry to prevent an error on deleteRowsAtIndexPaths.
    [self.activeTaskDescriptions removeObjectAtIndex:index];
    
    // Animate
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationBottom];
    
    // Core Data
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    NSFetchRequest *taskRequest = [[NSFetchRequest alloc] initWithEntityName:@"Task"];
    
    NSError *error = nil;
    NSArray *tasks = [context executeFetchRequest:taskRequest error:&error];
    
    NSUInteger taskID = [[self.activeTaskID objectAtIndex:indexPath.row] integerValue];
    NSManagedObject *object = [tasks objectAtIndex:taskID];
    [object setValue:[NSNumber numberWithBool:true] forKey:@"taskCompleted"];
    [object setValue:[NSDate date] forKey:@"taskCompletedTime"];
    [context save:&error];
}

- (BOOL)swipeableTableViewCell:(SWTableViewCell *)cell canSwipeToState:(SWCellState)state;
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    // Do NOT let users delete or complete the cells in completed section
    if (indexPath.section == 0) {
        return UITableViewCellEditingStyleDelete;
    }
    
    else {
        return UITableViewCellEditingStyleNone;
    }
}

#pragma mark - Sorting

- (void)alphabeticalSortOfActiveTasks {
    
    // Create one array with connected data on indexes
    NSMutableArray *combinedArrayOfActiveTasks = [NSMutableArray new];
    for (int i = 0; i < [self.activeTaskDescriptions count]; i++) {
        
        [combinedArrayOfActiveTasks addObject: @{@"description" : [self.activeTaskDescriptions objectAtIndex:i], @"date" : [self.activeTaskDates objectAtIndex:i], @"color": [self.activeTaskColors objectAtIndex:i], @"category" : [self.activeTaskCategories objectAtIndex:i], @"id" : [self.activeTaskID objectAtIndex:i], @"notify" : [self.activeTaskNotify objectAtIndex:i]}];
    }
    
    // Sort by description
    [combinedArrayOfActiveTasks sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"description" ascending:true selector:@selector(caseInsensitiveCompare:)]]];
    
    // Refill the arrays with the same data on new positions
    for (int i = 0; i < [combinedArrayOfActiveTasks count]; i++) {
        
        [self.activeTaskDescriptions replaceObjectAtIndex:i withObject:[[combinedArrayOfActiveTasks objectAtIndex:i] valueForKey:@"description"]];
        [self.activeTaskDates replaceObjectAtIndex:i withObject:[[combinedArrayOfActiveTasks objectAtIndex:i] valueForKey:@"date"]];
        [self.activeTaskColors replaceObjectAtIndex:i withObject:[[combinedArrayOfActiveTasks objectAtIndex:i] valueForKey:@"color"]];
        [self.activeTaskCategories replaceObjectAtIndex:i withObject:[[combinedArrayOfActiveTasks objectAtIndex:i] valueForKey:@"category"]];
        [self.activeTaskID replaceObjectAtIndex:i withObject:[[combinedArrayOfActiveTasks objectAtIndex:i] valueForKey:@"id"]];
        [self.activeTaskNotify replaceObjectAtIndex:i withObject:[[combinedArrayOfActiveTasks objectAtIndex:i] valueForKey:@"notify"]];
    }
}

- (void)dateSortOfActiveTasks {
    
    // Create one array with connected data on indexes
    NSMutableArray *combinedArrayOfActiveTasks = [NSMutableArray new];
    for (int i = 0; i < [self.activeTaskDescriptions count]; i++) {
        
        [combinedArrayOfActiveTasks addObject: @{@"description" : [self.activeTaskDescriptions objectAtIndex:i], @"date" : [self.activeTaskDates objectAtIndex:i], @"color": [self.activeTaskColors objectAtIndex:i], @"category" : [self.activeTaskCategories objectAtIndex:i], @"id" : [self.activeTaskID objectAtIndex:i], @"notify" : [self.activeTaskNotify objectAtIndex:i]}];
    }
    
    // Sort by description
    [combinedArrayOfActiveTasks sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:true]]];
    
    // Refill the arrays with the same data on new positions
    for (int i = 0; i < [combinedArrayOfActiveTasks count]; i++) {
        
        [self.activeTaskDescriptions replaceObjectAtIndex:i withObject:[[combinedArrayOfActiveTasks objectAtIndex:i] valueForKey:@"description"]];
        [self.activeTaskDates replaceObjectAtIndex:i withObject:[[combinedArrayOfActiveTasks objectAtIndex:i] valueForKey:@"date"]];
        [self.activeTaskColors replaceObjectAtIndex:i withObject:[[combinedArrayOfActiveTasks objectAtIndex:i] valueForKey:@"color"]];
        [self.activeTaskCategories replaceObjectAtIndex:i withObject:[[combinedArrayOfActiveTasks objectAtIndex:i] valueForKey:@"category"]];
        [self.activeTaskID replaceObjectAtIndex:i withObject:[[combinedArrayOfActiveTasks objectAtIndex:i] valueForKey:@"id"]];
        [self.activeTaskNotify replaceObjectAtIndex:i withObject:[[combinedArrayOfActiveTasks objectAtIndex:i] valueForKey:@"notify"]];
    }
}

- (void)dateSortOfCompletedTasks {
    
    // Create one array with connected data on indexes
    NSMutableArray *combinedArrayOfCompletedTasks = [NSMutableArray new];
    for (int i = 0; i < [self.completedTaskDescriptions count]; i++) {
        
        [combinedArrayOfCompletedTasks addObject: @{@"description" : [self.completedTaskDescriptions objectAtIndex:i], @"completedTime" : [self.completedTaskCompleteTimes objectAtIndex:i], @"color": [self.completedTaskColors objectAtIndex:i]}];
    }
    
    // Sort by description
    [combinedArrayOfCompletedTasks sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"completedTime" ascending:true]]];
    
    // Refill the arrays with the same data on new positions
    for (int i = 0; i < [combinedArrayOfCompletedTasks count]; i++) {
        
        [self.completedTaskDescriptions replaceObjectAtIndex:i withObject:[[combinedArrayOfCompletedTasks objectAtIndex:i] valueForKey:@"description"]];
        [self.completedTaskColors replaceObjectAtIndex:i withObject:[[combinedArrayOfCompletedTasks objectAtIndex:i] valueForKey:@"color"]];
        [self.completedTaskCompleteTimes replaceObjectAtIndex:i withObject:[[combinedArrayOfCompletedTasks objectAtIndex:i] valueForKey:@"completedTime"]];
    }
}

@end
