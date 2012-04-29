//
//  toAppDelegate.m
//  graphSerial
//
//  Created by Tim O'Brien on 11/24/11.
//  Copyright (c) 2011 t413.com. All rights reserved.
//

#import "toAppDelegate.h"
#import <dispatch/dispatch.h>
#include "rawhid.h"

dispatch_queue_t backgroundQueue;

@implementation toAppDelegate
@synthesize sampleSizeBox;
@synthesize window = _window;
@synthesize regexBox, statusIndicator,statusLabel,qGraph;

NSRegularExpression * regex;

- (void)dealloc
{
    dispatch_release(backgroundQueue);
    [super dealloc];
}

- (void)newText:(NSString*) txt {
    NSTextCheckingResult *match = [regex firstMatchInString:txt options:0 range:NSMakeRange(0, [txt length])];
    if (match) {
        NSMutableArray* sample = [[NSMutableArray alloc] initWithCapacity:[regex numberOfCaptureGroups]];
        for (int i=1; i<[match numberOfRanges]; i++) {
            [sample addObject:
             [NSNumber numberWithDouble: 
              [[txt substringWithRange: [match rangeAtIndex:i]] doubleValue]]];
        }
        NSArray * final_sample = [[NSArray alloc] initWithArray:sample]; //make non-mutable copy to store.
        [self.qGraph addSample:final_sample];
        [sample release]; //releace mutable copy
        [final_sample release]; //this is retained in qGraph, we can releace it.
    }
    else {
        NSLog(@"%@",txt);
        return;
    }
}

- (void)runHIDinput {
    printf("hello from inside GCD!!");
	char buf[64], *in, *out;
	rawhid_t *hid;
	long num, count;
    
	printf("Waiting for device:");
	fflush(stdout);
	while (1) {
        [statusIndicator setDoubleValue:0];
        statusLabel.stringValue = @"disconnected";
		hid = rawhid_open_only1(0, 0, 0xFF31, 0x0074);
		if (hid == NULL) {
			//printf(".");
			//fflush(stdout);
			Delay(10, NULL);
			continue;
		}
		[statusIndicator setDoubleValue: statusIndicator.maxValue];
        statusLabel.stringValue = @"connedted to HID";
		while (1) {
			num = rawhid_read(hid, buf, sizeof(buf), 200);
			if (num < 0) break;
			if (num == 0) continue;
			in = out = buf;
			for (count=0; count<num; count++) {
				if (*in) {
					*out++ = *in;
				}
				in++;
			}
			count = out - buf;
			//printf("read %d bytes, %d actual\n", num, count);
			if (count) {
				//num = fwrite(buf, 1, count, stdout);
                NSString* txt = [[NSString alloc] initWithBytes:buf length:count encoding: NSASCIIStringEncoding];
                [self newText:txt];
                [txt release];
				//fflush(stdout);
			}
		}
		rawhid_close(hid);
		//printf("\nDevice disconnected.\nWaiting for new device:");
	}
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    NSString * initialString = @"([0-9]+),([0-9]+),([0-9]+),([0-9]+),";
    NSError* error = nil;
    regex = [[NSRegularExpression alloc] initWithPattern: initialString options:NSRegularExpressionCaseInsensitive error:&error];
    if (error) { NSLog(@"regex error:%@",error); }
    [statusIndicator setDoubleValue:0];
    regexBox.stringValue = initialString;
    regexBox.delegate = self;
    sampleSizeBox.delegate = self;
        
    backgroundQueue = dispatch_queue_create("com.timo.graphSerial", NULL);        
    
    dispatch_async(backgroundQueue, ^(void) {
        [self runHIDinput];
    }); 
}
-(void) controlTextDidBeginEditing:(NSNotification *)obj {
    NSLog(@" %@",[obj.object description] );
    if (regexBox.backgroundColor == [NSColor redColor]){
        regexBox.backgroundColor = [NSColor whiteColor];
    }
}

-(void) controlTextDidEndEditing:(NSNotification *)obj {
    
    if (obj.object == sampleSizeBox) {
        [self.qGraph setSampleSize: sampleSizeBox.intValue];
    }
    else if (obj.object == regexBox) {
        NSError* error = nil;
        NSRegularExpression* reg = [[NSRegularExpression alloc] initWithPattern: regexBox.stringValue options:NSRegularExpressionCaseInsensitive error:&error];
        if (!error) {
            [regex release];
            regex = reg;
            [self.qGraph resetGraph];
        }
        else { 
            NSLog(@"REGEX ERROR: %@",error);
            [reg release];
            regexBox.backgroundColor = [NSColor redColor];
        }
    }
}



@end
