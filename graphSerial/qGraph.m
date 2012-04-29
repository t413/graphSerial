//
//  qGraph.m
//  graphSerial
//
//  Created by Tim O'Brien on 11/24/11.
//  Copyright (c) 2011 t413.com. All rights reserved.
//

#import "qGraph.h"
#import "SFCircularBuffer.h"

void ConvertHSLToRGB (const CGFloat *hslComponents, CGFloat *rgbComponents);

@implementation qGraph

SFCircularBuffer*points;
int minNumOfPoins = 0;
NSPoint valuesRange = {0};
bool isInited = 0;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    points = [[SFCircularBuffer alloc] initWithSize:100];
    return self;
}

- (void)addSample:(NSArray*) sample {
    //[points add:[NSValue value:&p withObjCType:@encode(TXPoint)]];
    [points add:sample];
    if (([sample count] < minNumOfPoins)||(!isInited)) { minNumOfPoins = (int)[sample count]; }
    
    //scale graph's y ranges to fit the incoming data.
    for (int i = 0; i<[sample count]; i++) {
        double val = [[sample objectAtIndex:i] doubleValue];
        if (!isInited) { valuesRange.x = valuesRange.x = val; isInited = 1; }
        else if (valuesRange.x > val) {
            valuesRange.x = val;
        } else if (valuesRange.y < val) {
            valuesRange.y = val;
        }
    }
    [self setNeedsDisplay:YES];  //calls drawRect:
}

- (void)drawRect:(NSRect)dirtyRect
{
    //[[NSColor whiteColor] set];
    //NSRectFill ( [self bounds] );
    CGContextRef ctx = [[NSGraphicsContext currentContext] graphicsPort];
    CGContextSetLineWidth(ctx, 2.0);
    
    int maxGraphHeight = [self bounds].size.height;
    double dx = [self bounds].size.width / [points capacity];
    double min = valuesRange.x, scale = (maxGraphHeight / (valuesRange.y - min));
    
    for (int n = 0; n < minNumOfPoins; n++) {
        CGContextBeginPath(ctx);
        double yave = 0;
        for (int i = 0; i < [points count]; i++) {
            double val = [(NSNumber*)[(NSArray*)[points objectAtIndex:i] objectAtIndex:n] doubleValue];
            if (i==0)   CGContextMoveToPoint(ctx, 0, (val - min+1)*scale);
            else        CGContextAddLineToPoint(ctx, i * dx, (val - min+1)*scale);
            if (i<10) { yave += (val - min)*scale/10; }
        }
        CGFloat rgb[3], hsl[] = {360.00 * n/minNumOfPoins, 1.0,0.4};
        ConvertHSLToRGB(hsl, rgb);
        CGContextSetStrokeColorWithColor(ctx, CGColorCreateGenericRGB( rgb[0],rgb[1],rgb[2], 1.0));
        CGContextDrawPath(ctx, kCGPathStroke);
        CGContextStrokePath(ctx);
        CGContextSelectFont(ctx, "Helvetica Neue Bold" , 14, kCGEncodingMacRoman);
        CGContextSetFillColorWithColor(ctx, CGColorCreateGenericRGB( rgb[0],rgb[1],rgb[2], 1.0));
        CGContextSetTextMatrix(ctx, CGAffineTransformMakeScale(1, 1)); 
        double val = [(NSNumber*)[(NSArray*)[points objectAtIndex:0] objectAtIndex:n] doubleValue];
        NSString *str = [NSString stringWithFormat:@"s%i = %0.1f",n,val];
        CGContextShowTextAtPoint(ctx, 10, yave + 5*n, [str UTF8String], [str length]);
    }
}

- (void)resetGraph {
    [points release];
    points = [[SFCircularBuffer alloc] initWithSize:100];
    minNumOfPoins = valuesRange.x = valuesRange.y = 0;
    isInited = 0;
}
- (void) setSampleSize:(int) size {
    if ((size != points.capacity) && (size > 0))
        [points rebuildToSize: size];
}

@end

// Based on Foley and van Dam algorithm.
// from http://borkware.com/quickies/one?topic=Graphics
void ConvertHSLToRGB (const CGFloat *hslComponents, CGFloat *rgbComponents) {
    CGFloat hue = hslComponents[0];
    CGFloat saturation = hslComponents[1];
    CGFloat lightness = hslComponents[2];
    
    CGFloat temp1, temp2;
    CGFloat rgb[3];  // "temp3"
    
    if (saturation == 0) {
        // Like totally gray man.
        rgb[0] = rgb[1] = rgb[2] = lightness;
        
    } else {
        if (lightness < 0.5) temp2 = lightness * (1.0 + saturation);
        else                 temp2 = (lightness + saturation) - (lightness * saturation);
        
        temp1 = (lightness * 2.0) - temp2;
        
        // Convert hue to 0..1
        hue /= 360.0;
        
        // Use the rgb array as workspace for our "temp3"s
        rgb[0] = hue + (1.0 / 3.0);
        rgb[1] = hue;
        rgb[2] = hue - (1.0 / 3.0);
        
        // Magic
        for (int i = 0; i < 3; i++) {
            if (rgb[i] < 0.0)        rgb[i] += 1.0;
            else if (rgb[i] > 1.0)   rgb[i] -= 1.0;
            
            if (6.0 * rgb[i] < 1.0)      rgb[i] = temp1 + ((temp2 - temp1)
                                                           * 6.0 * rgb[i]);
            else if (2.0 * rgb[i] < 1.0) rgb[i] = temp2;
            else if (3.0 * rgb[i] < 2.0) rgb[i] = temp1 + ((temp2 - temp1)
                                                           * ((2.0 / 3.0) - rgb[i]) * 6.0);
            else                         rgb[i] = temp1;
        }
    }
    
    // Clamp to 0..1 and put into the return pile.
    for (int i = 0; i < 3; i++) {
        rgbComponents[i] = MAX (0.0, MIN (1.0, rgb[i]));
    }
    
} // ConvertHSLToRGB
