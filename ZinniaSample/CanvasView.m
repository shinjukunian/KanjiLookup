//
//  CanvasView.m
//  ZinniaSample
//
//  Created by Morten Bertz on 3/3/15.
//  Copyright (c) 2015 Morten Bertz. All rights reserved.
//

#import "CanvasView.h"
@import ZinniaCocoaTouch;

@interface CanvasView()

@property CAShapeLayer *drawLayer;
@property Recognizer *recognizer;
@property UIBezierPath *path;
@property NSMutableArray *points;
@property CGPoint touchPoint;

@end

@implementation CanvasView

-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    self=[super initWithCoder:aDecoder];
    if (self) {
         self.path=[UIBezierPath bezierPath];
        self.drawLayer=[[CAShapeLayer alloc]init];
        self.drawLayer.strokeColor=[[UIColor blackColor]CGColor];
        self.drawLayer.fillColor=nil;
        self.drawLayer.backgroundColor=nil;
        self.drawLayer.lineWidth=3.5;
        self.drawLayer.lineCap=kCALineCapRound;
        self.drawLayer.lineJoin=kCALineJoinRound;
        self.drawLayer.path=self.path.CGPath;
        [self.layer addSublayer:self.drawLayer];
    }
    
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    self.drawLayer.frame=self.bounds;
    if (!self.recognizer) {
        self.recognizer=[[Recognizer alloc] initWithCanvas:self];
    }
}



- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (!self.recognizer) {
        self.recognizer=[[Recognizer alloc] initWithCanvas:self];
    }
    self.points = [NSMutableArray array];
    UITouch *touch = [touches anyObject];
    self.touchPoint = [touch locationInView:self];
    [self.points addObject:[NSValue valueWithCGPoint:self.touchPoint]];
    [self.path moveToPoint:self.touchPoint];
    
}


- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    
    UITouch *touch = [touches anyObject];
    CGPoint currentPoint = [touch locationInView:self];
    
    if ([self pointInside:currentPoint withEvent:event]) {
        [self.path addLineToPoint:currentPoint];
        self.drawLayer.path=self.path.CGPath;
        [self.drawLayer didChangeValueForKey:@"path"];
        [self.points addObject:[NSValue valueWithCGPoint:currentPoint]];
        self.touchPoint = currentPoint;
    }
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray *results = [self.recognizer classify:self.points];
      
        if (results.count>0) {
            NSArray *characters=[results valueForKeyPath:@"value"];
            NSArray *scores=[results valueForKeyPath:@"score"];
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([self.delegate respondsToSelector:@selector(canvasDidRecognizeCharacters:withScores:)]) {
                    [self.delegate canvasDidRecognizeCharacters:characters withScores:scores];
                }
            
            });
        }
    
    });
    
}




-(void)clearCanvas{
    [self.path removeAllPoints];
    self.drawLayer.path=self.path.CGPath;
    [self.drawLayer setNeedsDisplay];
    [self.recognizer clear];
}

@end
