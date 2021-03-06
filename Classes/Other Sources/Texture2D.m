#import <OpenGLES/ES1/glext.h>

#import "Texture2D.h"


//CONSTANTS:

#define kMaxTextureSize	 1024

//CLASS IMPLEMENTATIONS:

@implementation Texture2D


@synthesize frameCount=_frameCount;

@synthesize contentSize=_size, pixelFormat=_format, pixelsWide=_width, pixelsHigh=_height, name=_name;

- (id) initWithData:(const void*)data pixelFormat:(Texture2DPixelFormat)pixelFormat pixelsWide:(NSUInteger)width pixelsHigh:(NSUInteger)height contentSize:(CGSize)size
{
	GLint					saveName;
	if((self = [super init])) {
		glGenTextures(1, &_name);
		glGetIntegerv(GL_TEXTURE_BINDING_2D, &saveName);
		glBindTexture(GL_TEXTURE_2D, _name);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
		switch(pixelFormat) {
			
			case kTexture2DPixelFormat_RGBA8888:
				glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, data);
				break;
			case kTexture2DPixelFormat_RGB565:
				glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, width, height, 0, GL_RGB, GL_UNSIGNED_SHORT_5_6_5, data);
				break;
			case kTexture2DPixelFormat_A8:
				glTexImage2D(GL_TEXTURE_2D, 0, GL_ALPHA, width, height, 0, GL_ALPHA, GL_UNSIGNED_BYTE, data);
				break;
			default:
				[NSException raise:NSInternalInconsistencyException format:@""];
			
		}
		glBindTexture(GL_TEXTURE_2D, saveName);
	
		_size = size;
		_width = width;
		_height = height;
		_format = pixelFormat;

    _maxS = size.width / (float)width;
    _maxT = size.height / (float)height;
    
    _frameRect.s1 = 0.0f;
    _frameRect.s1 = 0.0f;
    _frameRect.s2 = _maxS;
    _frameRect.t2 = _maxT;
    
    _frameCount = CGPointMake(1,1);
    _currentFrame = 0;
	}					
	return self;
}


+ (Texture2D *)textureNamed:(NSString*)name
{
  UIImage *img = [UIImage imageNamed:name];
  if(!img) return nil;
  Texture2D *tex = [[[Texture2D alloc] initWithImage:img] autorelease];
  
  return tex;
}

-(FrameRect)rectForFrame:(GLuint)frame
{
  FrameRect r;
  int fx = frame % (int)_frameCount.x;
  int fy = frame / (int)_frameCount.x;
  r.s1 = _frameRect.s2 * fx;
  r.t1 = _frameRect.t2 * fy;
  r.s2 = r.s1 + _frameRect.s2;
  r.t2 = r.t1 + _frameRect.t2;
  return r;
}

-(void)setFrameWidth:(GLfloat)width height:(GLfloat)height
{
  int countX = (int)(_size.width  / width);
  int countY = (int)(_size.height / height);
  _frameCount.x = countX;
  _frameCount.y = countY;
  _frameRect.s2 = _maxS / countX;
  _frameRect.t2 = _maxT / countY;
  
  NSLog(@"count = %d. maxS = %f. s2 = %f", countX, _maxS, _frameRect.s2);
}

-(void)setFrame:(int)newframe
{
  _currentFrame = newframe%((int)_frameCount.x*(int)_frameCount.y);
}

-(GLuint)frame
{
  return _currentFrame;
}

-(GLuint)frameRow
{
  return _currentFrame / (int)_frameCount.x;
}

-(GLuint)frameCol
{
  return _currentFrame % (int)_frameCount.x;
}

-(void)setFrameRow:(int)row col:(int)col
{
  [self setFrame:(row*_frameCount.x + col)];
}

- (void) dealloc
{
	if(_name)
	 glDeleteTextures(1, &_name);
	
	[super dealloc];
}

- (NSString*) description
{
	return [NSString stringWithFormat:@"<%@ = %p | Name = %i | Dimensions = %ix%i | Coordinates = (%.2d, %.2d)>", [self class], self, _name, _width, _height, 0, 0];
}

@end

@implementation Texture2D (Image)
	
- (id) initWithImage:(UIImage *)uiImage
{
	NSUInteger				width,
							height,
							i;
	CGContextRef			context = nil;
	void*					data = nil;;
	CGColorSpaceRef			colorSpace;
	void*					tempData;
	unsigned int*			inPixel32;
	unsigned short*			outPixel16;
	BOOL					hasAlpha;
	CGImageAlphaInfo		info;
	CGAffineTransform		transform;
	CGSize					imageSize;
	Texture2DPixelFormat    pixelFormat;
	CGImageRef				image;
	UIImageOrientation		orientation;
	BOOL					sizeToFit = NO;
	
	
	image = [uiImage CGImage];
	orientation = [uiImage imageOrientation]; 
	
	if(image == NULL) {
		[self release];
		NSLog(@"Image is Null");
		return nil;
	}
	

	info = CGImageGetAlphaInfo(image);
	hasAlpha = ((info == kCGImageAlphaPremultipliedLast) || (info == kCGImageAlphaPremultipliedFirst) || (info == kCGImageAlphaLast) || (info == kCGImageAlphaFirst) ? YES : NO);
	if(CGImageGetColorSpace(image)) {
		if(hasAlpha)
			pixelFormat = kTexture2DPixelFormat_RGBA8888;
		else
			pixelFormat = kTexture2DPixelFormat_RGB565;
	} else  //NOTE: No colorspace means a mask image
		pixelFormat = kTexture2DPixelFormat_A8;
	
	
	imageSize = CGSizeMake(CGImageGetWidth(image), CGImageGetHeight(image));
	transform = CGAffineTransformIdentity;

	width = imageSize.width;
	
	if((width != 1) && (width & (width - 1))) {
		i = 1;
		while((sizeToFit ? 2 * i : i) < width)
			i *= 2;
		width = i;
	}
	height = imageSize.height;
	if((height != 1) && (height & (height - 1))) {
		i = 1;
		while((sizeToFit ? 2 * i : i) < height)
			i *= 2;
		height = i;
	}
	while((width > kMaxTextureSize) || (height > kMaxTextureSize)) {
		width /= 2;
		height /= 2;
		transform = CGAffineTransformScale(transform, 0.5, 0.5);
		imageSize.width *= 0.5;
		imageSize.height *= 0.5;
	}
	
	switch(pixelFormat) {		
		case kTexture2DPixelFormat_RGBA8888:
			colorSpace = CGColorSpaceCreateDeviceRGB();
			data = malloc(height * width * 4);
			context = CGBitmapContextCreate(data, width, height, 8, 4 * width, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
			CGColorSpaceRelease(colorSpace);
			break;
		case kTexture2DPixelFormat_RGB565:
			colorSpace = CGColorSpaceCreateDeviceRGB();
			data = malloc(height * width * 4);
			context = CGBitmapContextCreate(data, width, height, 8, 4 * width, colorSpace, kCGImageAlphaNoneSkipLast | kCGBitmapByteOrder32Big);
			CGColorSpaceRelease(colorSpace);
			break;
			
		case kTexture2DPixelFormat_A8:
			data = malloc(height * width);
			context = CGBitmapContextCreate(data, width, height, 8, width, NULL, kCGImageAlphaOnly);
			break;				
		default:
			[NSException raise:NSInternalInconsistencyException format:@"Invalid pixel format"];
	}
 

	CGContextClearRect(context, CGRectMake(0, 0, width, height));
	CGContextTranslateCTM(context, 0, height - imageSize.height);
	
	if(!CGAffineTransformIsIdentity(transform))
		CGContextConcatCTM(context, transform);
	CGContextDrawImage(context, CGRectMake(0, 0, CGImageGetWidth(image), CGImageGetHeight(image)), image);
	//Convert "RRRRRRRRRGGGGGGGGBBBBBBBBAAAAAAAA" to "RRRRRGGGGGGBBBBB"
	if(pixelFormat == kTexture2DPixelFormat_RGB565) {
		tempData = malloc(height * width * 2);
		inPixel32 = (unsigned int*)data;
		outPixel16 = (unsigned short*)tempData;
		for(i = 0; i < width * height; ++i, ++inPixel32)
			*outPixel16++ = ((((*inPixel32 >> 0) & 0xFF) >> 3) << 11) | ((((*inPixel32 >> 8) & 0xFF) >> 2) << 5) | ((((*inPixel32 >> 16) & 0xFF) >> 3) << 0);
		free(data);
		data = tempData;
		
	}
	self = [self initWithData:data pixelFormat:pixelFormat pixelsWide:width pixelsHigh:height contentSize:imageSize];
	
	CGContextRelease(context);
	free(data);
	
	return self;
}

@end

@implementation Texture2D (Text)

- (id) initWithString:(NSString*)string dimensions:(CGSize)dimensions alignment:(UITextAlignment)alignment fontName:(NSString*)name fontSize:(CGFloat)size
{
	NSUInteger				width,
							height,
							i;
	CGContextRef			context;
	void*					data;
	CGColorSpaceRef			colorSpace;
	UIFont *				font;
	
	font = [UIFont fontWithName:name size:size];
	
	width = dimensions.width;
	if((width != 1) && (width & (width - 1))) {
		i = 1;
		while(i < width)
		i *= 2;
		width = i;
	}
	height = dimensions.height;
	if((height != 1) && (height & (height - 1))) {
		i = 1;
		while(i < height)
		i *= 2;
		height = i;
	}
	
	colorSpace = CGColorSpaceCreateDeviceGray();
	data = calloc(height, width);
	context = CGBitmapContextCreate(data, width, height, 8, width, colorSpace, kCGImageAlphaNone);
	CGColorSpaceRelease(colorSpace);
	
	
	CGContextSetGrayFillColor(context, 1.0, 1.0);
	CGContextTranslateCTM(context, 0.0, height);
	CGContextScaleCTM(context, 1.0, -1.0); //NOTE: NSString draws in UIKit referential i.e. renders upside-down compared to CGBitmapContext referential
	UIGraphicsPushContext(context);
		[string drawInRect:CGRectMake(0, 0, dimensions.width, dimensions.height) withFont:font lineBreakMode:UILineBreakModeWordWrap alignment:alignment];
	UIGraphicsPopContext();
	
	self = [self initWithData:data pixelFormat:kTexture2DPixelFormat_A8 pixelsWide:width pixelsHigh:height contentSize:dimensions];
	
	CGContextRelease(context);
	free(data);
	
	return self;
}

@end

@implementation Texture2D (Drawing)



- (void) drawAtPoint:(CGPoint)point 
{
  FrameRect r = [self rectForFrame:_currentFrame];
	GLfloat		coordinates[] = {
    r.s1, r.t2,
    r.s2, r.t2,
    r.s1, r.t1,
    r.s2, r.t1  
  };
	GLfloat		width  = (GLfloat)_width  * (_frameRect.s2 - _frameRect.s1),
            height = (GLfloat)_height * (_frameRect.t2 - _frameRect.t1);
	GLfloat		vertices[] = {	
    -width / 2 + point.x,	-height / 2 + point.y,	0.0,
		 width / 2 + point.x,	-height / 2 + point.y,	0.0,
		-width / 2 + point.x,  height / 2 + point.y,	0.0,
		 width / 2 + point.x,	 height / 2 + point.y,	0.0 
  };
	
	glBindTexture(GL_TEXTURE_2D, _name);
	glVertexPointer(3, GL_FLOAT, 0, vertices);
	glTexCoordPointer(2, GL_FLOAT, 0, coordinates);
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}


- (void) drawInRect:(CGRect)rect
{
  FrameRect r = [self rectForFrame:_currentFrame];
	GLfloat	 coordinates[] = {
    r.s1, r.t2,
    r.s2, r.t2,
    r.s1, r.t1,
    r.s2, r.t1  
  };
	GLfloat	vertices[] = {	
    rect.origin.x,                      rect.origin.y,                      0.0,
    rect.origin.x + rect.size.width,		rect.origin.y,                      0.0,
		rect.origin.x,                      rect.origin.y + rect.size.height,		0.0,
		rect.origin.x + rect.size.width,		rect.origin.y + rect.size.height,		0.0 
  };
	
	glBindTexture(GL_TEXTURE_2D, _name);
	glVertexPointer(3, GL_FLOAT, 0, vertices);
	glTexCoordPointer(2, GL_FLOAT, 0, coordinates);
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}

@end
