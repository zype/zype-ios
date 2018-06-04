//
//  PlayerControlsOverlay.m
//
//  Created by Andy Zheng on 5/29/18.
//

#import "PlayerControlsOverlay.h"
#import <MediaPlayer/MediaPlayer.h>

@implementation PlayerControlsOverlay

#pragma mark - Initialization
- (id)init {
    self = [super init];
    
    if (self) {
        [[NSBundle mainBundle] loadNibNamed:@"PlayerControlsOverlay" owner:self options:nil];
        
        UIImage *progressBarThumb = [UIImage imageNamed:@"ProgressBarThumb"];
        [self.progressBar setThumbImage:progressBarThumb forState:UIControlStateNormal];
        [self.progressBar setThumbImage:progressBarThumb forState:UIControlStateHighlighted];
        
        // Airplay button
        MPVolumeView *volumeView = [ [MPVolumeView alloc] init];
        [volumeView setShowsVolumeSlider:NO];
        [volumeView sizeToFit];
        volumeView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        self.mpVolumeViewContainer.backgroundColor = [UIColor clearColor];
        [self.mpVolumeViewContainer addSubview:volumeView];
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [[NSBundle mainBundle] loadNibNamed:@"PlayerControlsOverlay" owner:self options:nil];

        UIImage *progressBarThumb = [UIImage imageNamed:@"ProgressBarThumb"];
        [self.progressBar setThumbImage:progressBarThumb forState:UIControlStateNormal];
        [self.progressBar setThumbImage:progressBarThumb forState:UIControlStateHighlighted];
        
        
        // Airplay button
        MPVolumeView *volumeView = [ [MPVolumeView alloc] init];
        [volumeView setShowsVolumeSlider:NO];
        [volumeView sizeToFit];
        volumeView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        self.mpVolumeViewContainer.backgroundColor = [UIColor clearColor];
        [self.mpVolumeViewContainer addSubview:volumeView];
        
        self.bounds = frame;
        self.view.bounds = self.bounds;
        self.view.frame = self.frame;
        
        [self addSubview:self.view];
    }
    
    return self;
}

#pragma mark - Gestures
- (IBAction)viewPressed:(id)sender {
    NSLog(@"PlayerControlsOverlay viewPressed");
    [self showSelf];
}

- (IBAction)playPausePressed:(id)sender {
    NSLog(@"PlayerControlsOverlay playPausePressed");
    if (self.playing) {
        [self setAsPause];
    } else {
        [self setAsPlay];
    }
}

- (IBAction)backIconPressed:(id)sender {
    NSLog(@"PlayerControlsOverlay backIconPressed");
}

- (IBAction)nextIconPressed:(id)sender {
    NSLog(@"PlayerControlsOverlay nextIconPressed");
}

- (IBAction)fullScreenPressed:(id)sender {
    NSLog(@"PlayerControlsOverlay fullScreenPressed");
}

- (IBAction)progressBarValueChanged:(id)sender {
    NSLog(@"PlayerControlsOverlay progressBarValueChanged");
    [self updateCurrentTime:[NSNumber numberWithFloat:self.progressBar.value]];
}

- (IBAction)progressBarTouchUpInside:(id)sender {
    NSLog(@"PlayerControlsOverlay progressBarTouchUpInside");
    [self updateCurrentTime:[NSNumber numberWithFloat:self.progressBar.value]];
}

- (IBAction)progressBarTouchUpOutside:(id)sender {
    NSLog(@"PlayerControlsOverlay progressBarTouchUpOutside");
    [self updateCurrentTime:[NSNumber numberWithFloat:self.progressBar.value]];
}

#pragma mark - Update UI
- (void)updateState:(BOOL)playing withCurrentTime:(NSNumber *)currentTime withDuration:(NSNumber *)duration enableUserNavigation:(BOOL)userNavigation {
    [self updateNavigation:userNavigation];
    
    if (playing) {
        [self setAsPlay];
    } else {
        [self setAsPause];
    }
    
    [self updateDuration:duration];
    [self updateCurrentTime:currentTime];
}

// Enable or disable back and next
- (void)updateNavigation:(BOOL)allowNavigation {
    self.allowUserNavigation = allowNavigation;
    
    if (allowNavigation) {
        self.backIcon.alpha = 1.0;
        self.nextIcon.alpha = 1.0;
        self.backIcon.userInteractionEnabled = YES;
        self.nextIcon.userInteractionEnabled = YES;
    } else {
        self.backIcon.alpha = 0.3;
        self.nextIcon.alpha = 0.3;
        self.backIcon.userInteractionEnabled = NO;
        self.nextIcon.userInteractionEnabled = NO;
    }
}

- (void)setAsPause {
    self.playing = NO;
    self.playPauseIcon.image = [UIImage imageNamed:@"IconPlayW"];
}

- (void)setAsPlay {
    self.playing = YES;
    self.playPauseIcon.image = [UIImage imageNamed:@"IconPauseW"];
}

- (void)updateCurrentTime:(NSNumber *)time {
    int timeInSeconds = [time intValue];
    
    int h = timeInSeconds / 3600;
    int m = (timeInSeconds / 60) % 60;
    int s = timeInSeconds % 60;
    
    self.currentTime = time;
    self.progressBar.value = [time floatValue];
    
    NSString *timeString;
    if (h > 0) {
        timeString = [NSString stringWithFormat:@"%02u:%02u:%02u", h, m, s];
    } else {
        timeString = [NSString stringWithFormat:@"%02u:%02u", m, s];
    }
    
    self.currentTimeLabel.text = timeString;
}

- (void)updateDuration:(NSNumber *)time {
    int timeInSeconds = [time intValue];
    
    int h = timeInSeconds / 3600;
    int m = (timeInSeconds / 60) % 60;
    int s = timeInSeconds % 60;
    
    self.duration = time;
    self.progressBar.maximumValue = [time floatValue];
    
    NSString *timeString;
    if (h > 0) {
        timeString = [NSString stringWithFormat:@"%02u:%02u:%02u", h, m, s];
    } else {
        timeString = [NSString stringWithFormat:@"%02u:%02u", m, s];
    }
    
    self.durationLabel.text = timeString;
}

- (void)updateIsCasting:(BOOL)isCasting {
    self.isCasting = isCasting;
}

- (BOOL)isVisible {
    if (self.alpha > 0.02){
        return YES;
    } else {
        return NO;
    }
}

- (void)disableControls {
    self.playPauseIcon.userInteractionEnabled = NO;
    self.backIcon.userInteractionEnabled = NO;
    self.nextIcon.userInteractionEnabled = NO;
    self.progressBar.userInteractionEnabled = NO;
    self.fullScreenIcon.userInteractionEnabled = NO;
    
    self.mpVolumeViewContainer.userInteractionEnabled = NO;
}

- (void)enableControls {
    self.playPauseIcon.userInteractionEnabled = YES;
    
    if (self.allowUserNavigation) {
        self.backIcon.userInteractionEnabled = YES;
        self.nextIcon.userInteractionEnabled = YES;
    }
    
    self.progressBar.userInteractionEnabled = YES;
    self.fullScreenIcon.userInteractionEnabled = YES;
    
    self.mpVolumeViewContainer.userInteractionEnabled = YES;
}

- (void)showSelf {
    [UIView animateWithDuration:0.5
                     animations:^(void){
                         self.view.alpha = 1.0;
                     }
                     completion:^(BOOL finished) {
                         if (finished) {
                             [self enableControls];
                             
                             [self performSelector:@selector(hideSelf) withObject:nil afterDelay:1.0];
                         }
                     }
     ];
}

- (void)hideSelf {
    if (self.playing && !self.isCasting) {
        [UIView animateWithDuration:0.5
                         animations:^{
                             // ios treats alpha lower than 0.02 as hidden. need invisible but still clickable
                             self.view.alpha = 0.03;
                         }
                         completion:^(BOOL finished) {
                             if (finished) [self disableControls];
                         }
         ];
    }
}

@end
