#import "Font.h"

// Simple fonts
#import "Type1Font.h"
#import "TrueTypeFont.h"
#import "MMType1Font.h"
#import "Type3Font.h"

// Composite fonts
#import "Type0Font.h"
#import "CIDType2Font.h"
#import "CIDType0Font.h"

const char *kType0Key = "Type0";
const char *kType1Key = "Type1";
const char *kMMType1Key = "MMType1";
const char *kType3Key = "Type3";
const char *kTrueTypeKey = "TrueType";
const char *kCidFontType0Key = "CIDFontType0";
const char *kCidFontType2Key = "CIDFontType2";

const char *kToUnicodeKey = "ToUnicode"; 
const char *kFontDescriptorKey = "FontDescriptor";
const char *kBaseFontKey = "BaseFont";
const char *kEncodingKey = "Encoding";
const char *kBaseEncodingKey = "BaseEncoding";
const char *kFontSubtypeKey = "Subtype";
const char *kFontKey = "Font";
const char *kTypeKey = "Type";


#pragma mark 


@implementation Font
@synthesize fontDescriptor, widths, toUnicode, widthsRange, baseFont, baseFontName, encoding, descendantFonts;


#pragma mark - Initialization

/* Factory method returns a Font object given a PDF font dictionary */
+ (Font *)fontWithDictionary:(CGPDFDictionaryRef)dictionary
{
	const char *type = nil;
	CGPDFDictionaryGetName(dictionary, kTypeKey, &type);
	if (!type || strcmp(type, kFontKey) != 0) return nil;
	const char *subtype = nil;
	CGPDFDictionaryGetName(dictionary, kFontSubtypeKey, &subtype);

	Font *font = nil;	
	if (!strcmp(subtype, kType0Key)) {
		font = [Type0Font alloc];
	}
	else if (!strcmp(subtype, kType1Key)) {
		font = [Type1Font alloc];
	}
	else if (!strcmp(subtype, kMMType1Key)) {
		font = [MMType1Font alloc];
	}
	else if (!strcmp(subtype, kType3Key)) {
		font = [Type3Font alloc];
	}
	else if (!strcmp(subtype, kTrueTypeKey)) {
		font = [TrueTypeFont alloc];
	}
	else if (!strcmp(subtype, kCidFontType0Key)) {
		font = [CIDType0Font alloc];
	}
	else if (!strcmp(subtype, kCidFontType2Key)) {
		font = [CIDType2Font alloc];
	}
	
	[[font initWithFontDictionary:dictionary] autorelease];
	return font;
}

/* Initialize with font dictionary */
- (id)initWithFontDictionary:(CGPDFDictionaryRef)dict
{
	if ((self = [super init]))
	{
		// Populate the glyph widths store
		[self setWidthsWithFontDictionary:dict];
		
		// Initialize the font descriptor
		[self setFontDescriptorWithFontDictionary:dict];
		
		// Parse ToUnicode map
		[self setToUnicodeWithFontDictionary:dict];
		
		// Set the font's base font
		const char *fontName = nil;
		if (CGPDFDictionaryGetName(dict, kBaseFontKey, &fontName))
		{
			self.baseFont = [NSString stringWithCString:fontName encoding:NSUTF8StringEncoding];
		}
		
		// NOTE: Any furhter initialization is performed by the appropriate subclass
	}
	return self;
}

#pragma mark Font Resources

- (void)setEncodingWithFontDictionary:(CGPDFDictionaryRef)fontDictionary
{
	const char *encodingName = nil;
	if (!CGPDFDictionaryGetName(fontDictionary, kEncodingKey, &encodingName))
	{
		CGPDFDictionaryRef encodingDict = nil;
		CGPDFDictionaryGetDictionary(fontDictionary, kEncodingKey, &encodingDict);
		CGPDFDictionaryGetName(encodingDict, kBaseEncodingKey, &encodingName);

		// TODO: Also get differences from font encoding dictionary
	}

	[self setEncodingNamed:[NSString stringWithCString:encodingName encoding:NSUTF8StringEncoding]];
}

- (void)setEncodingNamed:(NSString *)encodingName
{
	if ([@"MacRomanEncoding" isEqualToString:encodingName])
	{
		self.encoding = MacRomanEncoding;
	}
	else if ([@"WinAnsiEncoding" isEqualToString:encodingName])
	{
		self.encoding = WinAnsiEncoding;
	}
	else
	{
		self.encoding = UnknownEncoding;
	}
}

/* Import font descriptor */
- (void)setFontDescriptorWithFontDictionary:(CGPDFDictionaryRef)dict
{
	CGPDFDictionaryRef descriptor;
	if (!CGPDFDictionaryGetDictionary(dict, kFontDescriptorKey, &descriptor)) return;
	FontDescriptor *desc = [[FontDescriptor alloc] initWithPDFDictionary:descriptor];
	self.fontDescriptor = desc;
	[desc release];
}

/* Populate the widths array given font dictionary */
- (void)setWidthsWithFontDictionary:(CGPDFDictionaryRef)dict
{
	// Custom implementation in subclasses
}

/* Parse the ToUnicode map */
- (void)setToUnicodeWithFontDictionary:(CGPDFDictionaryRef)dict
{
	CGPDFStreamRef stream;
	if (!CGPDFDictionaryGetStream(dict, kToUnicodeKey, &stream)) return;
	CMap *map = [[CMap alloc] initWithPDFStream:stream];
	self.toUnicode = map;
	[map release];
}

#pragma mark Font Property Accessors

- (NSString *)unicodeStringUsingFontFile:(const unsigned char *)codes length:(size_t)length
{
	FontFile *fontFile = self.fontDescriptor.fontFile;
	NSMutableString *unicodeString = [NSMutableString string];
	for (int i = 0; i < length; i++)
	{
		NSString *string = [fontFile stringWithCode:codes[i]];
		[unicodeString appendString:string];
	}
	return unicodeString;
}

- (NSString *)unicodeStringUsingToUnicode:(const unsigned char *)codes length:(size_t)length
{
	NSMutableString *unicodeString = [NSMutableString string];
	for (int i = 0; i < length; i++)
	{
		unichar value = [self.toUnicode unicodeCharacter:codes[i]];
		[unicodeString appendFormat:@"%C", value];
	}
	return unicodeString;
}

- (NSString *)unicodeStringWithStandardEncoding:(const unsigned char *)codes length:(size_t)length
{
	NSStringEncoding stringEncoding = nativeEncoding(self.encoding);
	
	NSString *unicodeString = [[NSString alloc] initWithBytes:codes length:length encoding:stringEncoding];
	return [unicodeString autorelease];
}

/*!
 Returns a unicode string equivalent to the argument string of character codes.
 This method relies on either:
	- the font having a known encoding (such as Mac OS Roman),
	- a specified standard mapping,
	- an embedded Unicode mapping, or
	- a mapping embedded inside a font file
 
 If neither of these produces a Unicode value, the text content can not be extracted.
 */
- (NSString *)stringWithPDFString:(CGPDFStringRef)pdfString
{
	// Character codes
	const unsigned char *characterCodes = CGPDFStringGetBytePtr(pdfString);
	size_t length = CGPDFStringGetLength(pdfString);
	if (self.toUnicode)
	{
        //Unicode转NSString
		return [self unicodeStringUsingToUnicode:characterCodes length:length];
	}
	else if (self.fontDescriptor.fontFile)
	{
		return [self unicodeStringUsingFontFile:characterCodes length:length];
	}
	else if (knownEncoding(self.encoding))
	{
		return [self unicodeStringWithStandardEncoding:characterCodes length:length];
	}
	
	return @"";
}

- (NSString *)cidWithPDFString:(CGPDFStringRef)pdfString {
    // Copy PDFString to NSString
    NSString *string = (NSString *) CGPDFStringCopyTextString(pdfString);
	return [string autorelease];
}

/* Lowest point of any character */
- (CGFloat)minY
{
	return [self.fontDescriptor descent];
}

/* Highest point of any character */
- (CGFloat)maxY
{
	return [self.fontDescriptor ascent];
}

/* Width of the given character (CID) scaled to fontsize */
- (CGFloat)widthOfCharacter:(unichar)character withFontSize:(CGFloat)fontSize
{
	NSNumber *key = [NSNumber numberWithInt:character];
	NSNumber *width = [self.widths objectForKey:key];
	return [width floatValue] * fontSize;
}

/* Ligatures available in the current font encoding */
- (NSDictionary *)ligatures
{
	if (!ligatures)
	{
		// Mapping ligature Unicode character values to strings
		ligatures = [NSDictionary dictionaryWithObjectsAndKeys:
					 @"ff", [NSString stringWithFormat:@"%C", (unichar) 0xfb00],
					 @"fi", [NSString stringWithFormat:@"%C", (unichar) 0xfb01],
					 @"fl", [NSString stringWithFormat:@"%C", (unichar) 0xfb02],
					 @"ae", [NSString stringWithFormat:@"%C", (unichar) 0x00e6],
					 @"oe", [NSString stringWithFormat:@"%C", (unichar) 0x0153], nil];
	}

	return ligatures;
}

/* Width of space chacacter in glyph space */
- (CGFloat)widthOfSpace
{
    //0x20 为空格字符
	return [self widthOfCharacter:0x20 withFontSize:1.0];
}

- (NSString *)description
{
	NSMutableString *string = [NSMutableString string];
	[string appendFormat:@"fontName = %@ {\n", self.baseFont];
	[string appendFormat:@"\ttype = %@\n", [self classForKeyedArchiver]];
	[string appendFormat:@"\tcharacter widths 个数= %d个\n ", [self.widths count]];
	[string appendFormat:@"\ttoUnicode = %d\n", (self.toUnicode != nil)];
    [string appendFormat:@"\tencoding = %d\n", self.encoding ];
	if (self.descendantFonts) {
		[string appendFormat:@"\tdescendant fonts = %d个\n ", [self.descendantFonts count]];
        
        NSInteger count;
        for (Font* font in self.descendantFonts) {
           count= [font.widths count];
        }
        [string appendFormat:@"\tdescendant widths 个数= %d个\n ", count];
	}
	[string appendFormat:@"}\n"];
	return string;
}

/* Replace defined ligatures with separate characters */
- (NSString *)stringByExpandingLigatures:(NSString *)string
{
	NSString *replacement = nil;
	for (NSString *ligature in self.ligatures)
	{
		replacement = [self.ligatures objectForKey:ligature];
		if (!replacement) continue;
		string = [string stringByReplacingOccurrencesOfString:ligature withString:replacement];
	}
	return string;
}

#pragma mark Memory Management

- (void)dealloc
{
	[toUnicode release];
	[widths release];
	[fontDescriptor release];
	[baseFont release];
	[super dealloc];
}

@end
