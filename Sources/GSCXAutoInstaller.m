//
// Copyright 2018 Google Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import "GSCXAutoInstaller.h"

#import "GSCXInstaller.h"

NS_ASSUME_NONNULL_BEGIN

#pragma mark - GSCXAutoInstallerAppListener Interface

/**
 *  Listens to app notifications and installs scanner when app is launched.
 */
@interface GSCXAutoInstallerAppListener : NSObject
/**
 *  Begin listening for app notifications.
 */
+ (void)startListening;
@end

#pragma mark - GSCXAutoInstallerAppListener Implementation

@implementation GSCXAutoInstallerAppListener {
  UIWindow *_overlayWindow;
}

+ (instancetype)defaultListener {
  static dispatch_once_t onceToken;
  static GSCXAutoInstallerAppListener *defaultInstance;
  dispatch_once(&onceToken, ^{
    defaultInstance = [[GSCXAutoInstallerAppListener alloc] init];
  });
  return defaultInstance;
}

+ (void)startListening {
  [[NSNotificationCenter defaultCenter] addObserver:[GSCXAutoInstallerAppListener defaultListener]
                                           selector:@selector(applicationDidFinishLaunching:)
                                               name:UIApplicationDidFinishLaunchingNotification
                                             object:nil];
    
  [[NSNotificationCenter defaultCenter] addObserver:[GSCXAutoInstallerAppListener defaultListener]
                                           selector:@selector(toggleScanner)
                                               name:@"io.moia.debugMenu.gscxScannerToggle"
                                             object:nil];
    
  [[NSNotificationCenter defaultCenter] addObserver:[GSCXAutoInstallerAppListener defaultListener]
                                           selector:@selector(reinstallScanner)
                                               name:@"io.moia.debugMenu.gscxScannerInstall"
                                             object:nil];
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
  NSAssert(_overlayWindow == nil, @"iOS Scanner was already installed.");
  // TODO: Also check if scanner was installed using other APIs in GSCXInstaller.
  _overlayWindow = [GSCXInstaller installScanner];
  [self toggleScanner];
}

- (void)toggleScanner {
    BOOL gscxScannerDisabled = ![[NSUserDefaults standardUserDefaults] boolForKey:@"io.moia.debugMenu.gscxScannerToggle"];
    _overlayWindow.hidden = gscxScannerDisabled;
}

- (void)reinstallScanner {
  _overlayWindow = nil;
  _overlayWindow = [GSCXInstaller installScanner];
}

@end

#pragma mark - GSCXAutoInstaller Implementation

@implementation GSCXAutoInstaller

+ (void)load {
  if (![[NSProcessInfo processInfo].arguments containsObject:@"UITest"]) {
    [GSCXAutoInstallerAppListener startListening];
  }
}

@end

NS_ASSUME_NONNULL_END
