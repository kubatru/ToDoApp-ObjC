//
//  NewTaskViewController.h
//  ToDoApp
//
//  Created by Jakub Truhlar on 22.11.14.
//  Copyright (c) 2014 Jakub Truhlar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewTaskViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSMutableArray *categoryColors;
@property (nonatomic, strong) NSMutableArray *categoryNames;
@property (nonatomic, strong) NSString *taskCategorySelected;
@property (nonatomic, strong) NSString *taskColorSelected;
@property (nonatomic, assign) bool notificationEnabled;
@property (nonatomic, assign) NSUInteger taskID;
@property (strong, nonatomic) NSString *taskDescription;
@property (strong, nonatomic) NSDate *date;

@property (strong, nonatomic) IBOutlet UITextField *textField;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (strong, nonatomic) IBOutlet UIButton *bellBtn;

- (IBAction)bellBtnPressed:(id)sender;

@end
