//
//  Macros.h
//  ToDoApp
//
//  Created by Jakub Truhlar on 20.11.14.
//  Copyright (c) 2014 Jakub Truhlar. All rights reserved.
//

#define RGBA_R(c) ((((c)>>16) & 0xff) * 1.f/255.f)
#define RGBA_G(c) ((((c)>> 8) & 0xff) * 1.f/255.f)
#define RGBA_B(c) ((((c)>> 0) & 0xff) * 1.f/255.f)

#define UIColorWithRGB(c) [UIColor colorWithRed:RGBA_R(c) green:RGBA_G(c) blue:RGBA_B(c) alpha:1.0]
#define separatorColor colorWithRed:RGBA_R(0xE3E3E5) green:RGBA_G(0xE3E3E5) blue:RGBA_B(0xE3E3E5) alpha:1.0
