//
//  KeyboardViewController.m
//  HandwritingKeyboard
//
//  Created by Morten Bertz on 3/3/15.
//  Copyright (c) 2015 Morten Bertz. All rights reserved.
//

#import "KeyboardViewController.h"
#import "CharacterCollectionViewCell.h"

@interface KeyboardViewController ()<UICollectionViewDataSource,UICollectionViewDelegate>

@property NSArray *characters;


@end

@implementation KeyboardViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    UINib *nib=[UINib nibWithNibName:@"KeyboardView" bundle:nil];
    NSArray *objects=[nib instantiateWithOwner:self options:nil];
    UIView *keyboardView=[objects firstObject];
    self.view=keyboardView;
    
    UINib *cellNib = [UINib nibWithNibName:@"CharacterCell" bundle:nil];
    [self.collectionView registerNib:cellNib forCellWithReuseIdentifier:@"characterCell"];
    [self requestSupplementaryLexiconWithCompletion:^(UILexicon *lexicon){
        for (UILexiconEntry *entry in lexicon.entries) {
            NSLog(@"input:%@ entry:%@",entry.userInput,entry.documentText);
        }
    
    }];
    

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated
}

- (void)textWillChange:(id<UITextInput>)textInput {
    // The app is about to change the document's contents. Perform any preparation here.
}

- (void)textDidChange:(id<UITextInput>)textInput {
    // The app has just changed the document's contents, the document context has been updated.
    
    UIColor *textColor = nil;
    if (self.textDocumentProxy.keyboardAppearance == UIKeyboardAppearanceDark) {
        textColor = [UIColor whiteColor];
    } else {
        textColor = [UIColor blackColor];
    }
    
}


-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString *character=self.characters[indexPath.row];
    [self.textDocumentProxy insertText:character];
    [self clear:nil];
    
}

-(void)canvasDidRecognizeCharacters:(NSArray *)characters withScores:(NSArray *)scores{
    self.characters=characters;
    [self.collectionView reloadData];
}


-(IBAction)nextKeyboard:(id)sender{
    [self advanceToNextInputMode];
}

-(IBAction)clear:(id)sender{
    [self.canvas clearCanvas];
    self.characters=@[];
    [self.collectionView reloadData];
}


-(IBAction)delete:(id)sender{
    [self.textDocumentProxy deleteBackward];
    [self clear:nil];

}

-(IBAction)enter:(id)sender{
    [self.textDocumentProxy insertText:@"\n"];
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.characters.count;
}

-(UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    CharacterCollectionViewCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:@"characterCell" forIndexPath:indexPath];
    cell.characterLabel.text=self.characters[indexPath.row];
    return cell;
}

@end
