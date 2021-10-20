//
//  AVPlayerViewController+AVPlayerViewController_Transition.h
//  Zype
//
//  Created by Александр on 22.09.17.
//  Copyright © 2017 Zype. All rights reserved.
//

#import <AVKit/AVKit.h>

@interface AVPlayerViewController (AVPlayerViewController_Transition)

- (void)goFullscreen;
- (void)exitFullscreen;
- (void)exitFullscreenWithCompletion:(void(^)(void))complete;


@end
