//
//  SettingsViewController.h
//  ToDoApp
//
//  Created by Jakub Truhlar on 20.11.14.
//  Copyright (c) 2014 Jakub Truhlar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsViewController : UITableViewController

@property (nonatomic, strong) NSMutableArray *categoryColors;
@property (nonatomic, strong) NSMutableArray *categoryNames;

@property bool notification;
@property bool sortedAtoZ;

@end
