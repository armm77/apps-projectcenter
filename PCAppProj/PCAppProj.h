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

#ifndef _PCAPPPROJ_PCAPPPROJ_H
#define _PCAPPPROJ_PCAPPPROJ_H

#include <AppKit/AppKit.h>
#include <ProjectCenter/ProjectCenter.h>

@interface PCAppProj : NSObject <ProjectType>
{
}

//----------------------------------------------------------------------------
// ProjectType
//----------------------------------------------------------------------------

+ (id)sharedCreator;

- (Class)projectClass;

- (NSString *)projectTypeName;
- (NSDictionary *)typeTable;

- (PCProject *)createProjectAt:(NSString *)path;
- (PCProject *)openProjectAt:(NSString *)path;

@end

#endif