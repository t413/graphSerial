//
//  qGraph.h
//  graphSerial
//
//  Created by Tim O'Brien on 11/24/11.
//  Copyright (c) 2011 t413.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef struct TXPoint {
    NSInteger points[4];
} TXPoint;

@interface qGraph : NSView { }

- (void)resetGraph;
- (void)addSample:(NSArray*) sample;
- (void) setSampleSize:(int) size;

@end
