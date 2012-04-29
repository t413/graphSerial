//
//  toAppDelegate.h
//  graphSerial
//
//  Created by Tim O'Brien on 11/24/11.
//  Copyright (c) 2011 t413.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "qGraph.h"

@interface toAppDelegate : NSObject <NSApplicationDelegate,NSTextFieldDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet qGraph * qGraph;
@property (assign) IBOutlet NSLevelIndicator *statusIndicator;
@property (assign) IBOutlet NSTextField *statusLabel;
@property (assign) IBOutlet NSTextField *regexBox;
@property (assign) IBOutlet NSTextField *sampleSizeBox;

@end
