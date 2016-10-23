//
//  SignatureCaptureView.m
//  CloverGoSample
//
//  Created by Rajan Veeramani on 6/6/16.
//  Copyright © 2016 First Data Inc. All rights reserved.
//

#import "SignatureCaptureView.h"
#import <QuartzCore/QuartzCore.h>
#import <CloverGo/CloverGo.h>

static CGPoint midpoint(CGPoint p0, CGPoint p1) {
    return (CGPoint) {
        (p0.x + p1.x) / 2.0,
        (p0.y + p1.y) / 2.0
    };
}

@interface SignatureCaptureView () {
    UIBezierPath *path;
    CGPoint previousPoint;
    CGPoint currentPoint;
    NSMutableArray*		currentPath;
    
    
}
@end

@implementation SignatureCaptureView

static     NSMutableArray*		internalPaths = nil;

static      UIGestureRecognizer* gesture;

+ (SignatureCaptureView*)sharedInstance{
    static SignatureCaptureView *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[SignatureCaptureView alloc] init];
        [_sharedInstance commonInit];
    });
    return _sharedInstance;
}

- (void)commonInit {
    
    path = [UIBezierPath bezierPath];
    // Capture touches
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    pan.maximumNumberOfTouches = pan.minimumNumberOfTouches = 1;
    [self addGestureRecognizer:pan];
    
    gesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(erase)];
    
    internalPaths = [NSMutableArray new];
    
    self.accessibilityTraits = UIAccessibilityTraitAllowsDirectInteraction;
    self.isAccessibilityElement = YES;
    self.accessibilityLabel = @"Sign with your finger";
    
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) [self commonInit];
    return self;
}
- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) [self commonInit];
    return self;
}

- (void)enableEraseSignatureOnLongPress:(BOOL)enable{
    if (enable) {
        [self addGestureRecognizer:gesture];
    } else {
        [self removeGestureRecognizer:gesture];
    }
}

- (void)erase {
    if([internalPaths count]){
        path = [UIBezierPath bezierPath];
        [internalPaths removeAllObjects];
        [self setNeedsDisplay];
        if ([self.delegate respondsToSelector:@selector(isSignaturePresent:)]) {
            [self.delegate isSignaturePresent:NO];
        }
        if ([CloverGo debugModeEnabled]) {
            NSLog(@"Signature erased !");
        }
    }
}


- (void)pan:(UIPanGestureRecognizer *)pan {
    
    [self computeInternalPaths:self pan:pan];
}

- (void)computeInternalPaths:(UIView *)view pan:(UIPanGestureRecognizer *)pan
{
    currentPoint = [pan locationInView:view];
    
    CGPoint midPoint = midpoint(previousPoint, currentPoint);
    
    if (pan.state == UIGestureRecognizerStateBegan) {
        [path moveToPoint:currentPoint];
        currentPath = [NSMutableArray new];
        [currentPath addObject:[NSValue valueWithCGPoint:currentPoint]];
        
    } else if (pan.state == UIGestureRecognizerStateChanged) {
        [path addQuadCurveToPoint:midPoint controlPoint:previousPoint];
        [currentPath addObject:[NSValue valueWithCGPoint:currentPoint]];
        
    } else if (pan.state == UIGestureRecognizerStateEnded){
        CGPoint	dotPoint = currentPoint;	// give our dot a little more size so it will stroke
        dotPoint.x++; dotPoint.y++;
        [currentPath addObject:[NSValue valueWithCGPoint:dotPoint]];
        
    }
    
    previousPoint = currentPoint;
    [internalPaths addObject:currentPath];
    [view setNeedsDisplay];
    
    if ([internalPaths count]!=0) {
        if ([self.delegate respondsToSelector:@selector(isSignaturePresent:)]) {
            [self.delegate isSignaturePresent:YES];
        }
    }
}

- (NSDictionary*)getSignatureForCloverGo:(UIPanGestureRecognizer *)pan
                                  inView:(UIView*)view{
    
    [self computeInternalPaths:view pan:pan];
    
    if ([internalPaths count]!=0)
        return [SignatureCaptureView jsonDescription];
    else
        return @{};
}

+ (NSArray*)signaturePoints:(NSArray*)pointArray
{
    NSMutableArray*	points = [NSMutableArray new];
    for(NSValue*v in pointArray)
    {
        CGPoint	p = [v CGPointValue];
        [points addObject:@[[NSNumber numberWithInt:(int) p.x], [NSNumber numberWithInt:(int) p.y]]];
    }
    
    return points;
}

+(NSDictionary*)jsonDescription
{
    // multiple arrays of strokes
    NSMutableArray*		pointSets = [NSMutableArray new];
    
    for(NSArray* pathe in internalPaths)
    {
        NSArray*	points = [self signaturePoints:pathe];
        [pointSets addObject:@{@"points": points}];
    }
    
    NSDictionary*	pathDict = @{@"signature": @{@"strokes":pointSets}};
    
    if ([CloverGo debugModeEnabled]) {
        NSLog(@"Signature JSON (contains stokes-points info) ! : %@",pathDict);
    }
    
    return pathDict;
}

- (void)drawRect:(CGRect)rect
{
    [[UIColor blackColor] setStroke];
    [path stroke];
}

@end
