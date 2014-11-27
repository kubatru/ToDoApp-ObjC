//
//  TaskCell.h
//  ToDoApp
//
//  Created by Jakub Truhlar on 19.11.14.
//  Copyright (c) 2014 Jakub Truhlar. All rights reserved.
//

#import "SWTableViewCell.h"

@interface TaskCell : SWTableViewCell

@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

@end
