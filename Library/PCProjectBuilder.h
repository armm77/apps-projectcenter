/*
   GNUstep ProjectCenter - http://www.gnustep.org

   Copyright (C) 2000-2002 Free Software Foundation

   Authors: Philippe C.D. Robert
            Serg Stoyan

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

#ifndef _PCPROJECTBUILDER_H
#define _PCPROJECTBUILDER_H

#include <AppKit/AppKit.h>

#ifndef GNUSTEP_BASE_VERSION
@protocol ProjectComponent;
#else
#include <ProjectCenter/ProjectComponent.h>
#endif

@class PCProject;
@class PCButton;

@interface PCProjectBuilder : NSObject <ProjectComponent>
{
  NSBox           *componentView;
  PCButton        *buildButton;
  PCButton        *cleanButton;
  PCButton        *installButton;
  PCButton        *optionsButton;
  id              buildStatusField;
  id              targetField;
  NSTextView      *logOutput;
  NSTextView      *errorOutput;

  NSPopUpButton   *popup;
  
  NSPanel         *optionsPanel;
  NSTextField     *buildTargetHostField;
  NSTextField     *buildTargetArgsField;

  NSString        *makePath;

  PCProject       *currentProject;
  NSDictionary    *currentOptions;

  NSString        *statusString;
  NSMutableString *buildTarget;
  NSMutableArray  *buildArgs;
  SEL             postProcess;
  NSTask          *makeTask;

  NSFileHandle    *readHandle;
  NSFileHandle    *errorReadHandle;

  BOOL            _isBuilding;
  BOOL            _isCleaning;
}

- (id)initWithProject:(PCProject *)aProject;
- (void)dealloc;

- (NSView *)componentView;
- (void)setTooltips;

// --- Accessory
- (BOOL)isBuilding;
- (BOOL)isCleaning;
- (void)performStartBuild;
- (void)performStartClean;
- (void)performStopBuild;

// --- Actions
- (void)startBuild:(id)sender;
- (BOOL)stopBuild:(id)sender;
- (void)startClean:(id)sender;
- (void)build:(id)sender;
//- (void)buildDidTerminate;

- (void)popupChanged:(id)sender;

- (void)logStdOut:(NSNotification *)aNotif;
- (void)logErrOut:(NSNotification *)aNotif;

- (void)copyPackageTo:(NSString *)path;

@end

@interface PCProjectBuilder (UserInterface)

- (void) _createComponentView;
- (void) _createOptionsPanel;

@end

@interface PCProjectBuilder (BuildLogging)

- (void)logString:(NSString *)string error:(BOOL)yn;
- (void)logString:(NSString *)string error:(BOOL)yn newLine:(BOOL)newLine;
- (void)logData:(NSData *)data error:(BOOL)yn;

@end

#endif