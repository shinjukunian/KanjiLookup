//
//  CanvasView.h
//  ZinniaSample
//
//  Created by Morten Bertz on 3/3/15.
//  Copyright (c) 2015 Morten Bertz. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CanvasViewDelegate;

@interface CanvasView : UIView

@property (weak) IBOutlet id<CanvasViewDelegate> delegate;

-(void)clearCanvas;

@end


@protocol CanvasViewDelegate <NSObject>

-(void)canvasDidRecognizeCharacters:(NSArray*)characters withScores:(NSArray*)scores;


@end