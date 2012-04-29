//
//  SFCircularBuffer.m
//  CameraViewer
//
//  Created by friendly on 6/10/11.
//  Copyright 2011 t413.com. All rights reserved.
//

#import "SFCircularBuffer.h"


@implementation SFCircularBuffer
int newest, numInBuff;
int arraySize;
#define OLDEST ((newest+numInBuff) % arraySize)

- (id)initWithSize:(int)size {
    self = [super init];
    if (self) {
        //if(cArray) delete cArray;
        cArray = new id[size];
        for (int i = 0; i < size; i++) { cArray[i] = nil; }
        newest = 0;
        numInBuff = 0;
        arraySize = size;
    }
    return self;
}

- (void)add:(id)item {
    [item retain]; //be sure to keep the added item when it's added.
    
    if (numInBuff < arraySize){
        cArray[newest++] = item;
        if (newest >= arraySize) newest = 0;
        numInBuff++; //just add things to the array, don't get rid of old things.
    }
    else { //the buffer is full, we add and delete as we go.
        //remove last element first
        [cArray[newest] release];
        cArray[newest++] = item;
        if (newest >= arraySize) newest = 0;
    }
}

- (id)getItem:(int)index {
    if ((index > arraySize) || (index < 0)) return nil;
    else {
        int myElem = (((newest-1-index) > 0)? (newest-1-index) : (newest-1-index + arraySize)) % arraySize;
        return cArray[myElem];
    }
}
- (id)objectAtIndex:(int)index {
    return [self getItem:index];
}

- (id)getLatest {
    return cArray[((newest-1) > 0)? (newest-1) : (newest-1 + arraySize)];
}

- (id)getOldest {
    return cArray[OLDEST];
}

- (int)getBufferedCount {
    return numInBuff;
}
- (int)count {
    return numInBuff;
}
- (int)capacity {
    return arraySize;
}


- (NSString*) description {
    NSMutableString * mutantStr = [[NSMutableString alloc] initWithString:[NSString stringWithFormat:@"array[%i] = [",arraySize]];
    for (int i = 0; i < arraySize; i++) {
        id thing = [self getItem:i];
        if (thing == nil) { [mutantStr appendString:@"_,"]; }
        else if ([thing respondsToSelector:@selector(description)]) {
            [mutantStr appendFormat:@"%@, ", [thing description]];
        }
    }
    [mutantStr appendString:@"]"];
    
    //[NSString stringWithFormat:@""]
    NSString * final = [NSString stringWithString: mutantStr];
    [mutantStr release];
    return final;
}

- (void)rebuildToSize:(int)newSize {
    if (newSize == arraySize) return;
    id * newArray = new id[newSize];
    NSLog(@"rebuilding %i -> %i",arraySize,newSize);
    
    for (int i = 0; i < MAX(newSize, arraySize); i++) {
        //if we're making a bigger array:
        if (i < newSize) { 
            newArray[newSize-1-i] = (i < arraySize)? [self getItem: i] : nil;
        }
        //otherwise we're shrinking.
        else {
            if (cArray[i]) { [cArray[i] release]; cArray[i] = nil; NSLog(@"rm[%i]",i); }
        }
    }
    numInBuff = (newSize > arraySize)? numInBuff : MIN(newSize, numInBuff);
    arraySize = newSize;
    delete cArray;
    cArray = newArray;
    newest = 0;
    NSLog(@"now cArray has [%i] items,",numInBuff);
}

- (void)dealloc {
    int j=0;
    for (int i = 0; i < arraySize; i++) {
        if (cArray[i]) { [cArray[i] release]; cArray[i] = nil; j++; }
    }
    NSLog(@"dealloc-ing, removed %i objects.",j);
    delete cArray;
    [super dealloc];
}


@end
