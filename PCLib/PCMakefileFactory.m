/* 
 * PCMakefileFactory.m created by probert on 2002-02-28 22:16:25 +0000
 *
 * Project ProjectCenter
 *
 * Created with ProjectCenter - http://www.gnustep.org
 *
 * $Id$
 */

#import "PCMakefileFactory.h"

#define COMMENT_HEADERS     @"\n\n#\n# Header files\n#\n\n"
#define COMMENT_RESOURCES   @"\n\n#\n# Resource files\n#\n\n"
#define COMMENT_CLASSES     @"\n\n#\n# Class files\n#\n\n"
#define COMMENT_CFILES      @"\n\n#\n# C files\n#\n\n"
#define COMMENT_SUBPROJECTS @"\n\n#\n# Subprojects\n#\n\n"
#define COMMENT_APP         @"\n\n#\n# Main application\n#\n\n"
#define COMMENT_LIBRARIES   @"\n\n#\n# Additional libraries\n#\n\n"

@implementation PCMakefileFactory

static PCMakefileFactory *_factory = nil;

+ (PCMakefileFactory *)sharedFactory
{
    static BOOL isInitialised = NO;

    if( isInitialised == NO )
    {
        _factory = [[PCMakefileFactory alloc] init];

        isInitialised = YES;
    }

    return _factory;
}

- (void)createMakefileForProject:(NSString *)prName
{
    NSAssert( prName, @"No project name given!");

    AUTORELEASE( mfile );
    mfile = [[NSMutableString alloc] init];

    AUTORELEASE( pnme );
    pnme = [prName copy];

    [mfile appendString:@"#\n"];
    [mfile appendString:@"# GNUmakefile - Generated by ProjectCenter\n"];
    [mfile appendString:@"# Written by Philippe C.D. Robert <phr@3dkit.org>\n"];
    [mfile appendString:@"#\n"];
    [mfile appendString:@"# NOTE: Do NOT change this file -- ProjectCenter maintains it!\n"];
    [mfile appendString:@"#\n"];
    [mfile appendString:@"# Put all of your customisations in GNUmakefile.preamble and\n"];
    [mfile appendString:@"# GNUmakefile.postamble\n"];
    [mfile appendString:@"#\n\n"];
}

- (void)appendString:(NSString *)aString
{
    NSAssert( mfile, @"No valid makefile available!");
    NSAssert( aString, @"No valid string!");

    [mfile appendString:aString];
}

- (void)appendApplication
{
    [self appendString:COMMENT_APP];

    [self appendString:[NSString stringWithFormat:@"PACKAGE_NAME=%@\n",pnme]];
    [self appendString:[NSString stringWithFormat:@"APP_NAME=%@\n",pnme]];
}

- (void)appendHeaders:(NSArray *)array
{
    [self appendString:COMMENT_HEADERS];
    [self appendString:[NSString stringWithFormat:@"%@_HEADERS= ",pnme]];

    if( array && [array count] )
    {
        NSString     *tmp;
        NSEnumerator *enumerator = [array objectEnumerator];

	while (tmp = [enumerator nextObject]) 
        {
	    [self appendString:[NSString stringWithFormat:@"\\\n%@ ",tmp]];
	}
    }
}

- (void)appendClasses:(NSArray *)array
{
    [self appendString:COMMENT_CLASSES];
    [self appendString:[NSString stringWithFormat:@"%@_OBJC_FILES= ",pnme]];

    if( array && [array count] )
    {
        NSString     *tmp;
        NSEnumerator *enumerator = [array objectEnumerator];

	while (tmp = [enumerator nextObject]) 
        {
	    [self appendString:[NSString stringWithFormat:@"\\\n%@ ",tmp]];
	}
    }
}

- (void)appendCFiles:(NSArray *)array
{
    [self appendString:COMMENT_CFILES];
    [self appendString:[NSString stringWithFormat:@"%@_C_FILES= ",pnme]];

    if( array && [array count] )
    {
        NSString     *tmp;
        NSEnumerator *enumerator = [array objectEnumerator];

	while (tmp = [enumerator nextObject]) 
        {
	    [self appendString:[NSString stringWithFormat:@"\\\n%@ ",tmp]];
	}
    }
}

- (void)appendResources
{
    [self appendString:COMMENT_RESOURCES];
    [self appendString:[NSString stringWithFormat:@"%@_RESOURCE_FILES= ",pnme]];
}

- (void)appendResourceItems:(NSArray *)array
{
    NSString     *tmp;
    NSEnumerator *enumerator = [array objectEnumerator];

    while (tmp = [enumerator nextObject]) {
	[self appendString:[NSString stringWithFormat:@"\\\n%@ ",tmp]];
    }
}

- (void)appendInstallDir:(NSString*)dir
{
    [self appendString:
             [NSString stringWithFormat:@"GNUSTEP_INSTALLATION_DIR=%@\n",dir]];
}

- (void)appendAppIcon:(NSString*)icn
{
    [self appendString:
             [NSString stringWithFormat:@"%@_APPLICATION_ICON=%@\n",pnme, icn]];
}

- (void)appendSubprojects:(NSArray*)array
{
    [self appendString:COMMENT_SUBPROJECTS];

    if (array && [array count]) 
    {
	NSString     *tmp;
        NSEnumerator *enumerator = [array objectEnumerator];

        while (tmp = [enumerator nextObject]) {
            [self appendString:[NSString stringWithFormat:@"\\\n%@ ",tmp]];
        }
    }

}

- (void)appendGuiLibraries:(NSArray*)array
{
    [self appendString:COMMENT_LIBRARIES];
    [self appendString:@"ADDITIONAL_GUI_LIBS += "];

    if( array && [array count] )
    {
        NSString     *tmp;
        NSEnumerator *enumerator = [array objectEnumerator];

        while (tmp = [enumerator nextObject]) 
        {
          if (![tmp isEqualToString:@"gnustep-base"] &&
              ![tmp isEqualToString:@"gnustep-gui"]) 
          {
            [self appendString:[NSString stringWithFormat:@"-l%@ ",tmp]];
          }
        }
    }
}

- (void)appendTailForApp
{
    [self appendString:@"\n\n"];

    [self appendString:@"-include GNUmakefile.preamble\n"];
    [self appendString:@"-include GNUmakefile.local\n"];
    [self appendString:@"include $(GNUSTEP_MAKEFILES)/aggregate.make\n"];
    [self appendString:@"include $(GNUSTEP_MAKEFILES)/application.make\n"];
    [self appendString:@"-include GNUmakefile.postamble\n"];
}

- (void)appendTailForLibrary
{
    [self appendString:@""];
}

- (void)appendTailForTool
{
    [self appendString:@""];
}

- (void)appendTailForBundle
{
    [self appendString:@""];
}

- (void)appendTailForGormApp
{
    [self appendString:@""];
}

- (NSData *)encodedMakefile
{
    NSAssert( mfile, @"No valid makefile available!");

    return [mfile dataUsingEncoding:[NSString defaultCStringEncoding]];
}

@end
