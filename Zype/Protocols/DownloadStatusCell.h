//
//  DownloadStatusCell.h
//
//  Created by ZypeTech on 7/6/15.
//  Copyright (c) 2015 Zype. All rights reserved.
//

@protocol DownloadStatusCell <NSObject>

- (void)setNoDownload;
- (void)setDownloadStarted;
- (void)setDownloadProgress:(float)progress;
- (void)setDownloadSavingFile;
- (void)setDownloadFinishedWithMediaType:(NSString *)mediaType;
- (void)setPlaying;
- (void)setPlayed;

@end
