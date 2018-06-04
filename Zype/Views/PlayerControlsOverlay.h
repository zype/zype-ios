//
//  PlayerControlsOverlay.h
//
//  Created by Andy Zheng on 5/29/18.
//

#import <UIKit/UIKit.h>

@interface PlayerControlsOverlay : UIView

#pragma mark - IBOutlets
@property (strong, nonatomic) IBOutlet UIView *view;

@property (weak, nonatomic) IBOutlet UIView *mpVolumeViewContainer;


@property (weak, nonatomic) IBOutlet UIImageView *backIcon;
@property (weak, nonatomic) IBOutlet UIImageView *nextIcon;
@property (weak, nonatomic) IBOutlet UIImageView *playPauseIcon;

@property (weak, nonatomic) IBOutlet UILabel *currentTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *durationLabel;
@property (weak, nonatomic) IBOutlet UISlider *progressBar;

@property (weak, nonatomic) IBOutlet UIImageView *fullScreenIcon;

#pragma mark - Gesture recognizers

// Presses
- (IBAction)viewPressed:(id)sender;
- (IBAction)playPausePressed:(id)sender;
- (IBAction)backIconPressed:(id)sender;
- (IBAction)nextIconPressed:(id)sender;
- (IBAction)fullScreenPressed:(id)sender;

// Drags
- (IBAction)progressBarValueChanged:(id)sender;

// Release touch
- (IBAction)progressBarTouchUpInside:(id)sender;
- (IBAction)progressBarTouchUpOutside:(id)sender;


#pragma mark - Attributes
@property (strong, nonatomic) NSNumber *currentTime;
@property (strong, nonatomic) NSNumber *duration;
@property (nonatomic) BOOL playing;

@property (nonatomic) BOOL allowUserNavigation;
@property (nonatomic) BOOL isCasting;

#pragma mark - Update UI methods
- (void)updateState:(BOOL)playing withCurrentTime:(NSNumber *)currentTime withDuration:(NSNumber *)duration enableUserNavigation:(BOOL)userNavigation;
- (void)updateNavigation:(BOOL)allowNavigation;
- (void)setAsPause;
- (void)setAsPlay;
- (void)updateCurrentTime:(NSNumber *)currentTime;
- (void)updateDuration:(NSNumber *)time;
- (void)updateIsCasting:(BOOL)isCasting;

- (void)showSelf;
- (void)hideSelf;

@end
