/*
   GNUstep ProjectCenter - http://www.gnustep.org

   Copyright (C) 2001 Free Software Foundation

   Author: Philippe C.D. Robert <phr@3dkit.org>

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

   $Id$
*/

/*
 Description:

 This is the project type 'Application' for GNUstep. You never should create 
 it yourself but use PCAppProj for doing this. Otherwise needed files don't 
 get copied to the right place.
 */
 
#ifndef _PCAppProj_PCAppProject_h_
#define _PCAppProj_PCAppProject_h_

#include <AppKit/AppKit.h>
#include <ProjectCenter/PCProject.h>
#include <ProjectCenter/PCProjectInspector.h>

@interface PCAppProject : PCProject
{
  NSBox       *buildAttributesView;
  NSTextField *ccOptField;
  NSTextField *ldOptField;
  NSTextField *installPathField;
  NSTextField *toolField;
  NSTextField *headersField;
  NSTextField *libsField;

  NSBox       *projectAttributesView;
  NSTextField *projectTypeField;
  NSTextField *projectNameField;
  NSTextField *projectLanguageField;
  NSTextField *appClassField;
  NSTextField *appImageField;
  NSButton    *setAppIconButton;
  NSButton    *clearAppIconButton;
  NSImageView *appIconView;
  NSImage     *icon;

  NSBox       *fileAttributesView;
  NSImageView *fileIconView;
  NSTextField *fileNameField;
}

// ----------------------------------------------------------------------------
// --- Init and free
// ----------------------------------------------------------------------------

- (id)init;
- (void)dealloc;

// ----------------------------------------------------------------------------
// --- User Interfave
// ----------------------------------------------------------------------------

- (void)createInspectors;
- (NSView *)buildAttributesView;
- (NSView *)projectAttributesView;
- (NSView *)fileAttributesView;
- (void)updateInspectorValues:(NSNotification *)aNotif;
- (void)clearAppIcon:(id)sender;
- (void)setAppIcon:(id)sender;
- (BOOL)setAppIconWithImageAtPath:(NSString *)path;
- (void)setAppClass:(id)sender;

// ----------------------------------------------------------------------------
// --- Project
// ----------------------------------------------------------------------------

- (Class)builderClass;

- (BOOL)writeMakefile;

- (NSArray *)sourceFileKeys;
- (NSArray *)resourceFileKeys;
- (NSArray *)otherKeys;
- (NSArray *)buildTargets;
- (NSString *)projectDescription;

- (BOOL)isExecutable;

@end

#endif
