//
//  SFCircularBuffer.h
//  CameraViewer
//
//  Created by friendly on 6/10/11.
//  Copyright 2011 t413.com. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface SFCircularBuffer : NSObject {
    id * cArray;  //used for c array
}

- (id)        initWithSize: (int)size;
- (void)      add:           (id)item;
- (id)        getItem:     (int)index;
- (id)        objectAtIndex:(int)index;
- (id)        getLatest;
- (id)        getOldest;
- (int)       getBufferedCount;
- (int)       count;
- (int)       capacity;
- (NSString*) description;
- (void)      rebuildToSize:(int)newSize;
- (void)      dealloc;

@end
