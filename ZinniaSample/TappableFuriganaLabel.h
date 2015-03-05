//
//  TappableFuriganaLabel.h
//  KanjiLookup
//
//  Created by Morten Bertz on 3/5/15.
//  Copyright (c) 2015 Morten Bertz. All rights reserved.
//

#import <UIKit/UIKit.h>
@import AVFoundation;
@interface TappableFuriganaLabel : UILabel

@property NSString *furiganaText;
@property NSArray *utterances;

-(void)speak:(id)sender;

-(BOOL)setUtterancesFromDescription:(NSString*)description;

@end
