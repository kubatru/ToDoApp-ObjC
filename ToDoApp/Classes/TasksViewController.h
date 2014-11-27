//
//  TasksViewController.h
//  ToDoApp
//
//  Created by Jakub Truhlar on 19.11.14.
//  Copyright (c) 2014 Jakub Truhlar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TaskCell.h"
#import "CompletedTaskCell.h"

@interface TasksViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, SWTableViewCellDelegate>

// ivars
{
    bool notificationsEnabled;
    bool sortedAtoZ;
}

@property (nonatomic, strong) NSMutableArray *activeTaskColors;
@property (nonatomic, strong) NSMutableArray *activeTaskCategories;
@property (nonatomic, strong) NSMutableArray *activeTaskDescriptions;
@property (nonatomic, strong) NSMutableArray *activeTaskDates;
@property (nonatomic, strong) NSMutableArray *activeTaskNotify;
@property (nonatomic, strong) NSMutableArray *activeTaskID;

@property (nonatomic, strong) NSMutableArray *completedTaskColors;
@property (nonatomic, strong) NSMutableArray *completedTaskDescriptions;
@property (nonatomic, strong) NSMutableArray *completedTaskCompleteTimes;

@property (nonatomic, strong) NSMutableArray *taskCompleted;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

