#import "CMap.h"

static NSSet *sharedOperators = nil;
static NSCharacterSet *sharedTagSet = nil;
static NSCharacterSet *sharedTokenDelimimerSet = nil;
static NSString *kOperatorKey = @"CurrentOperator";

NSValue *rangeValue(unsigned int from, unsigned int to)
{
	return [NSValue valueWithRange:NSMakeRange(from, to-from)];
}

@implementation Operator
@synthesize start, end, handler;

+ (Operator *)operatorWithStart:(NSString *)start end:(NSString *)end handler:(SEL)handler
{
	Operator *op = [[[Operator alloc] init] autorelease];
	op.start = start;
	op.end = end;
	op.handler = handler;
	return op;
}


@end







@interface CMap ()


- (void)handleCodeSpaceRange:(NSString *)string;
- (void)handleCharacter:(NSString *)string;
- (void)handleCharacterRange:(NSString *)string;
- (void)parse:(NSString *)cMapString;


@property (readonly) NSCharacterSet *tokenDelimiterSet;
@property (nonatomic, retain) NSMutableDictionary *context;
@property (nonatomic, readonly) NSCharacterSet *tagSet;
@property (nonatomic, readonly) NSSet *operators;

@end

@implementation CMap
@synthesize operators, context;
@synthesize codeSpaceRanges, characterMappings, characterRangeMappings;



- (id)initWithString:(NSString *)string
{
	if ((self = [super init]))
	{
		[self parse:string];
	}
	return self;
}

- (id)initWithPDFStream:(CGPDFStreamRef)stream
{
	NSData *data = (NSData *) CGPDFStreamCopyData(stream, nil);
	NSString *text = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    id obj = [self initWithString:text];
    [text release];
    [data release];
    return obj;
}

- (BOOL)isInCodeSpaceRange:(unichar)cid
{
   // NSLog(@"codeSpaceRanges:%@",self.codeSpaceRanges);
	for (NSValue *rangeValue in self.codeSpaceRanges)
	{
		NSRange range = [rangeValue rangeValue];
		if (cid >= range.location && cid <= NSMaxRange(range))
		{
			return YES;
		}
	}
	return NO;
}

/**!
 * Returns the unicode value mapped by the given character ID
 */
- (unichar)unicodeCharacter:(unichar)cid
{
	if (![self isInCodeSpaceRange:cid])
               return 0;

	NSArray	*mappedRanges = [self.characterRangeMappings allKeys];
	for (NSValue *rangeValue in mappedRanges)
	{
        @autoreleasepool {
            NSRange range = [rangeValue rangeValue];
        
            
            /*
             //ADOBE 官方PDF文档原文：
             beginbfrange
             
             srcCode1 srcCode2 [ dstString1 dstString2 ... dstString(m) ]
             endbfrange
             Consecutive codes starting with srcCode1 and ending with srcCode2 shall be mapped to the destination strings in the array starting with dstString1 and ending with dstStringm. The value of dstString can be a string of up to 512 bytes. The value of m represents the number of continuous character codes in the source character code range.
             
             m = srcCode2 - srcCode1 + 1
             
             */
            

        if (cid >= range.location && cid <= NSMaxRange(range))
		{
            NSNumber *offsetValue = [self.characterRangeMappings objectForKey:rangeValue];
			return [offsetValue intValue] + cid - range.location;
		}
        
            }
		

		}
        

	
	NSArray *mappedValues = [self.characterMappings allKeys];
	for (NSNumber *from in mappedValues)
	{
        @autoreleasepool {
            if ([from intValue] == cid)
            {
                return [[self.characterMappings objectForKey:from] intValue];
            }
        }
		
	}
    
   	
	return (unichar) NSNotFound;
}

- (NSSet *)operators
{
	@synchronized (self)
	{
		if (!sharedOperators)
		{
			sharedOperators = [[NSMutableSet alloc] initWithObjects:
							   [Operator operatorWithStart:@"begincodespacerange" 
														end:@"endcodespacerange"
													handler:@selector(handleCodeSpaceRange:)],
							   [Operator operatorWithStart:@"beginbfchar" 
													   end:@"endbfchar" 
												   handler:@selector(handleCharacter:)],
							   [Operator operatorWithStart:@"beginbfrange" 
													   end:@"endbfrange" 
												   handler:@selector(handleCharacterRange:)],
			nil];
		}
		return sharedOperators;
	}
}

#pragma mark -
#pragma mark Scanner

- (Operator *)operatorWithStartingToken:(NSString *)token
{
	for (Operator *op in self.operators)
	{
		if ([op.start isEqualToString:token]) return op;
	}
	return nil;
}

/**!
 * Returns the next token that is not a comment. Only remainder-of-line comments are supported.
 * The scanner is advanced to past the returned token.
 *
 * @param scanner a scanner
 * @return next non-comment token
 */
- (NSString *)tokenByTrimmingComments:(NSScanner *)scanner
{
	NSString *token = nil;
	[scanner scanUpToCharactersFromSet:self.tokenDelimiterSet intoString:&token];

	static NSString *commentMarker = @"%%";
	NSRange commentMarkerRange = [token rangeOfString:commentMarker];
	if (commentMarkerRange.location != NSNotFound)
	{
		[scanner scanUpToCharactersFromSet:[NSCharacterSet newlineCharacterSet] intoString:nil];
		token = [token substringToIndex:commentMarkerRange.location];
		if (token.length == 0)
		{
			return [self tokenByTrimmingComments:scanner];
		}
	}
	
	return token;
}

/**!
 * Parse a CMap.
 *
 * @param cMapString string representation of a CMap
 */
- (void)parse:(NSString *)cMapString
{
    
	NSScanner *scanner = [NSScanner scannerWithString:cMapString];
	NSString *token = nil;
	while (![scanner isAtEnd])
	{
		token = [self tokenByTrimmingComments:scanner];

		Operator *operator = [self operatorWithStartingToken:token];
		if (operator)
		{
			// Start a new context
			self.context = [NSMutableDictionary dictionaryWithObject:operator forKey:kOperatorKey];
		}
		else if (self.context)
		{
			operator = [self.context valueForKey:kOperatorKey];
			if ([token isEqualToString:operator.end])
			{
				// End the current context
				self.context = nil;
			}
			else
			{
				// Send input to the current context
				[self performSelector:operator.handler withObject:token];
			}
		}
	}
}


#pragma mark -
#pragma mark Parsing handlers

/**!
 * Trims tag characters from the argument string, and returns the parsed integer value of the string.
 *
 * @param tagString string representing a hexadecimal number, possibly within tags
 */
- (unsigned int)valueOfTag:(NSString *)tagString
{
	unsigned int numericValue = 0;

	tagString = [tagString stringByTrimmingCharactersInSet:self.tagSet];
	[[NSScanner scannerWithString:tagString] scanHexInt:&numericValue];
	return numericValue;
}

/**!
 * Code space ranges are pairs of hex numbers:
 *	<from> <to>
 */
- (void)handleCodeSpaceRange:(NSString *)string
{
    //string 是由 <from> <to> 以空格符或换行符分开取得的，但有可能出现<from><to> ，即没有空格的情形。需分类讨论。
    
    //有空格的情况
    if (string.length <= 6) {
        static NSString *rangeLowerBound = @"MIN";
        NSNumber *value = [NSNumber numberWithInt:[self valueOfTag:string]];
        NSNumber *low = [self.context valueForKey:rangeLowerBound];
        
        if (!low)
        {
            [self.context setValue:value forKey:rangeLowerBound];
            return;
        }
        
        [self.codeSpaceRanges addObject:rangeValue([low intValue], [value intValue])];
        [self.context removeObjectForKey:rangeLowerBound];
    }
    
    //没空格的情况
    else {
        unsigned int lowValue = 0;
        unsigned int maxValue = 0;
        NSString *low =  [string substringWithRange:NSMakeRange(1, 4)];
        [[NSScanner scannerWithString:low] scanHexInt:&lowValue];
        NSString *max = [string substringWithRange:NSMakeRange(7, 4)];
        [[NSScanner scannerWithString:max] scanHexInt:&maxValue];
        [self.codeSpaceRanges addObject:rangeValue(lowValue, maxValue)];
    }
}

/**!
 * Character mappings appear in pairs:
 *	<from> <to>
 */
- (void)handleCharacter:(NSString *)character
{
	NSNumber *value = [NSNumber numberWithInt:[self valueOfTag:character]];
	static NSString *origin = @"Origin";
	NSNumber *from = [self.context valueForKey:origin];
	if (!from)
	{
		[self.context setValue:value forKey:origin];
		return;
	}
	[self.characterMappings setObject:value forKey:from];
	[self.context removeObjectForKey:origin];
}

/**!
 * Ranges appear on the triplet form:
 *	<from> <to> <offset>
 */
- (void)handleCharacterRange:(NSString *)token
{
    //token 是由 <from> <to> <offset> 以空格符或换行符分开取得的，但有可能出现<from><to><offset> ，即没有空格的情形。需分类讨论。
    
    //有空格的情况
    if (token.length <= 12) {
        NSNumber *value = [NSNumber numberWithInt:[self valueOfTag:token]];
        static NSString *from = @"From";
        static NSString *to = @"To";
        NSNumber *fromValue = [self.context valueForKey:from];
        NSNumber *toValue = [self.context valueForKey:to];
        if (!fromValue)
        {
            [self.context setValue:value forKey:from];
            return;
        }
        else if (!toValue)
        {
            [self.context setValue:value forKey:to];
            return;
        }
        NSValue *range = rangeValue([fromValue intValue], [toValue intValue]);
        [self.characterRangeMappings setObject:value forKey:range];
        [self.context removeObjectForKey:from];
        [self.context removeObjectForKey:to];
    }

    // 没空格的情况
    else {
        unsigned int fromValue = 0;
        unsigned int toValue = 0;
        unsigned int offsetValue = 0;
        NSString *from =  [token substringWithRange:NSMakeRange(1, 4)];
        [[NSScanner scannerWithString:from] scanHexInt:&fromValue];
        NSString *to = [token substringWithRange:NSMakeRange(7, 4)];
        [[NSScanner scannerWithString:to] scanHexInt:&toValue];
        NSString *offset = [token substringWithRange:NSMakeRange(13, 4)];
        [[NSScanner scannerWithString:offset] scanHexInt:&offsetValue];
        NSValue *range = rangeValue(fromValue, toValue);
        [self.characterRangeMappings setObject:[NSNumber numberWithInt: offsetValue] forKey:range];

    }
}

#pragma mark -
#pragma mark Accessor methods

- (NSCharacterSet *)tagSet {
	if (!sharedTagSet) {
		sharedTagSet = [[NSCharacterSet characterSetWithCharactersInString:@"<>"] retain];
	}
	return sharedTagSet;
}

- (NSCharacterSet *)tokenDelimiterSet {
	if (!sharedTokenDelimimerSet) {
		sharedTokenDelimimerSet = [[NSCharacterSet whitespaceAndNewlineCharacterSet] retain];
	}
	return sharedTokenDelimimerSet;
}


- (NSMutableArray *)codeSpaceRanges {
	if (!codeSpaceRanges) {
		codeSpaceRanges = [[NSMutableArray alloc] init];
	}
	return codeSpaceRanges;
}


- (NSMutableDictionary *)characterMappings {
	if (!characterMappings) {
		characterMappings = [[NSMutableDictionary alloc] init];
	}
	return characterMappings;
}

- (NSMutableDictionary *)characterRangeMappings {
	if (!characterRangeMappings) {
		self.characterRangeMappings = [NSMutableDictionary dictionary];
	}
	return characterRangeMappings;
}

- (void)dealloc
{
	[offsets release];
	[codeSpaceRanges release];
    [characterMappings release];
    [characterRangeMappings release];
    [context release];
    [operators release];
	[super dealloc];
}


@end
