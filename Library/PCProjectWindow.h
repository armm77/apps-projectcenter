/*
   GNUstep ProjectCenter - http://www.gnustep.org

   Copyright (C) 2000-2002 Free Software Foundation

   Author: Philippe C.D. Robert <probert@siggraph.org>

   This file is part of GNUstep.

   This application is free software; you can redistribute it and/or
   modify it under the terms of the GNU General Public
   License as published by the Free Software Foundation; either
   version 2 of the License, or (at your option) any later version.

   This application is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Library General Public License for more details.

   You should have received a copy of the GNU General Public
   License along with this library; if not, write to the Free
   Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111 USA.
*/

#ifndef _PCProjectWindow_h_
#define _PCProjectWindow_h_ 

#include "AppKit/AppKit.h"

@class PCProject;
@class PCProjectBrowser;
@class PCProjectHistory;
@class PCButton;
@class PCSplitView;

@interface PCProjectWindow : NSObject
{
  PCProject   *project;

  NSWindow    *projectWindow;
  PCButton    *buildButton;
  PCButton    *launchButton;
  PCButton    *editorButton;
  PCButton    *findButton;
  PCButton    *inspectorButton;

  NSImageView *fileIcon;
  NSTextField *fileIconTitle;

  PCSplitView *h_split;
  PCSplitView *v_split;

  NSBox       *customView;
  NSResponder *firstResponder;
}

// ============================================================================
// ==== Intialization & deallocation
// ============================================================================

// Will go into gorm file
- (void)_initUI;
- (id)initWithProject:(PCProject *)owner;
- (void)setFileIcon:(NSNotification *)notification;

// ============================================================================
// ==== Accessory methods
// ============================================================================
- (NSView *)customContentView;
- (void)setCustomContentView:(NSView *)subview;

- (NSImage *)fileIconImage;
- (void)setFileIconImage:(NSImage *)image;
- (NSString *)fileIconTitle;
- (void)setFileIconTitle:(NSString *)title;

// ============================================================================
// ==== Actions
// ============================================================================
- (void)showProjectHistory:(id)sender;
- (void)showProjectBuild:(id)sender;
- (void)showProjectLaunch:(id)sender;
- (void)showProjectEditor:(id)sender;

// ============================================================================
// ==== Notifications
// ============================================================================
- (void)projectDictDidChange:(NSNotification *)aNotif;
- (void)projectDictDidSave:(NSNotification *)aNotif;

// ============================================================================
// ==== Window delegate
// ============================================================================
- (NSString *)stringWithSavedFrame;
- (void)makeKeyAndOrderFront:(id)sender;
- (void)makeKeyWindow;
- (void)orderFront:(id)sender;
- (void)center;
- (void)close;
- (void)performClose:(id)sender;
- (BOOL)isDocumentEdited;
- (BOOL)isKeyWindow;
- (BOOL)makeFirstResponder:(NSResponder *)aResponder;

- (void)windowDidBecomeKey:(NSNotification *)aNotification;
- (void)windowDidResignKey:(NSNotification *)aNotification;
- (void)windowDidBecomeMain:(NSNotification *)aNotification;
- (void)windowWillClose:(NSNotification *)aNotification;

@end

#endif
