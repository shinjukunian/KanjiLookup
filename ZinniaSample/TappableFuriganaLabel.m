//
//  TappableFuriganaLabel.m
//  ZinniaSample
//
//  Created by Morten Bertz on 3/5/15.
//  Copyright (c) 2015 Morten Bertz. All rights reserved.
//

#import "TappableFuriganaLabel.h"


@interface TappableFuriganaLabel ()

@property UITapGestureRecognizer *tap;
@property AVSpeechSynthesizer *synthesizer;
@property NSSet *charactersToTrim;
@end

@implementation TappableFuriganaLabel


-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    self=[super initWithCoder:aDecoder];
    if (self) {
        
        self.tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapped:)];
        [self addGestureRecognizer:self.tap];
        self.charactersToTrim=[[NSSet alloc]initWithArray:@[@"【",@"】"]];
        
        }
    return self;
}

-(BOOL)canBecomeFirstResponder{
    return YES;
}


- (BOOL)canPerformAction:(SEL)action
              withSender:(id)sender
{
    if (action==@selector(copy:)) {
        return YES;
    }
    if (action==@selector(speak:)) {
        return YES;
    }
    
    return NO;
    
}



-(void)speak:(id)sender{
    if (!self.synthesizer) {
        _synthesizer=[[AVSpeechSynthesizer alloc]init];
    }
    if (!self.synthesizer.isSpeaking) {
        for (AVSpeechUtterance *utterance in self.utterances) {
            [self.synthesizer speakUtterance:utterance];

        }
    }
    
}


-(void)tapped:(UITapGestureRecognizer*)sender{
    
    [self becomeFirstResponder];
    CGRect rect=self.frame;
    UIMenuItem *speakItem=[[UIMenuItem alloc]initWithTitle:NSLocalizedString(@"Speak", nil) action:@selector(speak:)];
    UIMenuController *menu=[UIMenuController sharedMenuController];
    menu.menuItems=@[speakItem];
    [menu setTargetRect:rect inView:self.superview];
    [menu setMenuVisible:YES animated:YES];

    
    
}


- (void)copy:(id)sender {
    NSString *cleanText=self.text;
    
    for (NSString *character in self.charactersToTrim) {
        cleanText=[cleanText stringByReplacingOccurrencesOfString:character withString:@""];
    }
    [[UIPasteboard generalPasteboard] setString:cleanText];
}


-(void)setUtteranceForString:(NSString*)string{
    
    AVSpeechUtterance *utterance=[AVSpeechUtterance speechUtteranceWithString:string];
    utterance.voice=[AVSpeechSynthesisVoice voiceWithLanguage:@"ja-JP"];;
    utterance.rate=AVSpeechUtteranceMinimumSpeechRate;
    utterance.postUtteranceDelay=0.2;
    self.utterances=@[utterance];

    
}


-(BOOL)setUtterancesFromDescription:(NSString *)description{
    NSArray *components=[description componentsSeparatedByString:@" "];
    NSMutableArray *utterancesMutable=[NSMutableArray array];
    if (components.count>1) {
        NSString *yomis=components.firstObject;
        NSArray *yomiComponents=[yomis componentsSeparatedByString:@"/"];
        for (NSString *yomi in yomiComponents) {
            NSMutableString *yomiMutable=yomi.mutableCopy;
            [yomiMutable replaceOccurrencesOfString:@"∙" withString:@"" options:NSLiteralSearch range:NSMakeRange(0, yomi.length)];
            AVSpeechUtterance *utterance=[AVSpeechUtterance speechUtteranceWithString:yomiMutable.copy];
            utterance.voice=[AVSpeechSynthesisVoice voiceWithLanguage:@"ja-JP"];;
            utterance.rate=AVSpeechUtteranceMinimumSpeechRate;
            utterance.postUtteranceDelay=0.2;
            [utterancesMutable addObject:utterance];

        }
    }
    if (utterancesMutable.count>0) {
        self.utterances=utterancesMutable.copy;
        return YES;
    }
    return NO;
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
