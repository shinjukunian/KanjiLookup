//
//  KeyboardViewController.h
//  HandwritingKeyboard
//
//  Created by Morten Bertz on 3/3/15.
//  Copyright (c) 2015 Morten Bertz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CanvasView.h"
@interface KeyboardViewController : UIInputViewController<CanvasViewDelegate>

@property IBOutlet UICollectionView *collectionView;
@property IBOutlet CanvasView *canvas;
@property IBOutlet UIButton *enterButton;

@end
