/*
 * CPString.j
 * Foundation
 *
 * Created by Francisco Tolmasky.
 * Copyright 2008, 280 North, Inc.
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 */

import "CPObject.j"
import "CPException.j"
import "CPSortDescriptor.j"

/*!
    A case insensitive search
    @global
    @class CPString
*/
CPCaseInsensitiveSearch = 1;
/*!
    Exact character match
    @global
    @class CPString
*/
CPLiteralSearch         = 2;
/*!
    Start searching from the end of the string
    @global
    @class CPString
*/
CPBackwardsSearch       = 4;
/*!
    @global
    @class CPString
*/
CPAnchoredSearch        = 8;
/*!
    Numbers in the string are compared as numbers instead of strings
    @global
    @class CPString
*/
CPNumericSearch         = 64;

var CPStringHashes      = new objj_dictionary();

/*! @class CPString
    CPString is an object that allows management of strings. Because CPString is
    based on the JavaScript <code>String</code> object, CPStrings are immutable, although the
    class does have methods that create new CPStrings generated from modifications to the
    receiving instance.</p>

    <p>A handy feature of CPString instances is that they can be used wherever a JavaScript is
    required, and vice versa.
*/
@implementation CPString : CPObject

/*
    @ignore
*/
+ (id)alloc
{
    return new String;
}

/*!
    Returns a new string
*/
+ (id)string
{
    return [[self alloc] init];
}

/*!
    Returns a CPString containing the specified hash.
    @param aHash the hash to represent as a string
*/
+ (id)stringWithHash:(unsigned)aHash
{
    var zeros = "000000",
        digits = aHash.toString(16);
    
    return zeros.substring(0, zeros.length - digits.length) + digits;
}

/*!
    Returns a copy of the specified string.
    @param aString a non-<code>nil</code> string to copy
    @throws CPInvalidArgumentException if <code>aString</code> is <code>nil</code>
    @return the new CPString
*/
+ (id)stringWithString:(CPString)aString
{
    if (!aString)
        [CPException raise:CPInvalidArgumentException
                    reason:"stringWithString: the string can't be 'nil'"];

    return [[self alloc] initWithString:aString];
}

/*!
    Initializes the string with data from the specified string.
    @param aString the string to copy data from
    @return the initialized CPString
*/
- (id)initWithString:(CPString)aString
{
    return String(aString);
}

/*!
    Initializes a string using C printf-style formatting. First argument should be a constant format string, like ' "float val = %f" ', remaining arguments should be the variables to print the values of, comma-separated.
    @param format the format to be used, printf-style
    @return the initialized CPString
*/
- (id)initWithFormat:(CPString)format, ...
{
    if (!format)
        [CPException raise:CPInvalidArgumentException
                    reason:"initWithFormat: the format can't be 'nil'"];

    self = sprintf.apply(this, Array.prototype.slice.call(arguments, 2));
    return self;
}

/*!
    Creates a new string using C printf-style formatting. First argument should be a constant format string, 
    like ' "float val = %f" ', remaining arguments should be the variables to print the values of, comma-separated.
    @param format the format to be used, printf-style
    @return the initialized CPString
*/
+ (id)stringWithFormat:(CPString)format, ...
{
    if (!format)
        [CPException raise:CPInvalidArgumentException
                    reason:"initWithFormat: the format can't be 'nil'"];

    return sprintf.apply(this, Array.prototype.slice.call(arguments, 2));
}

/*!
    Returns a description of this CPString object.
*/
- (CPString)description
{
    return "<" + self.isa.name + " 0x" + [CPString stringWithHash:[self hash]] + " \"" + self + "\">";
}

/*!
    Returns the number of UTF-8 characters in the string.
*/
- (int)length
{
    return length;
}

/*!
    Returns the character at the specified index.
    @param anIndex the index of the desired character
*/
- (CPString)characterAtIndex:(unsigned)anIndex
{
    return charAt(anIndex);
}

// Combining strings

/*!
    Returns a string made by appending to the reciever a string constructed from a given format
    string and the floowing arguments
    @param format the format string in printf-style.
    @return the initialized CPString
*/
- (CPString)stringByAppendingFormat:(CPString)format, ...
{
    if (!format)
        [CPException raise:CPInvalidArgumentException reason:"initWithFormat: the format can't be 'nil'"];

    return self + sprintf.apply(this, Array.prototype.slice.call(arguments, 2));
}

/*!
    Creates a new CPString from the concatenation of the receiver and the specified string.
    @param aString the string to append to the receiver
    @return the new string
*/
- (CPString)stringByAppendingString:(CPString)aString
{
    return self + aString;
}

/*!
    Returns a new string formed by padding characters or removing them.
    If the padding length is shorter than the receiver's length, the
    new string will be trimmed down to the padding length size.
    If the padding length is longer than the receiver's length, then the
    new string is repeatedly padded with the characters from the
    specified string starting at the specified index.
    @param aLength the desired length of the new CPString
    @param aString the padding string to use (if necessary)
    @param anIndex the index of the padding string to start from (if necessary to use)
    @return the new padded string
*/
- (CPString)stringByPaddingToLength:(unsigned)aLength withString:(CPString)aString startingAtIndex:(unsigned)anIndex
{
    if (length == aLength)
        return self;

    if (aLength < length)
        return substr(0, aLength);

    var string = self,
        substring = aString.substr(anIndex),
        difference = aLength - length;

    while ((difference -= substring.length) > 0)
        string += substring;
    
    if (difference) string += substring.substr(difference + substring.length);
}

//Dividing Strings
/*!
    Tokenizes the receiver string using the specified
    delimiter. For example, if the receiver is:
    <pre>"arash.francisco.ross.tom"</pre>
    and the delimiter is:
    <pre>"."</pre>
    the returned array would contain:
    <pre>["arash", "francisco", "ross", "tom"]</pre>
    @param the delimiter
    @return the array of tokens
*/
- (CPArray)componentsSeparatedByString:(CPString)aString
{
    return split(aString);
}

/*!
    Returns a substring starting from the specified index to the end of the receiver.
    @param anIndex the starting string (inclusive)
    @return the substring
*/
- (CPString)substringFromIndex:(unsigned)anIndex
{
    return substr(anIndex);
}

/*!
    Returns a substring starting from the specified range <code>location</code> to the range <code>length</code>.
    @param the range of the substring
    @return the substring
*/
- (CPString)substringWithRange:(CPRange)aRange
{
    return substr(aRange.location, aRange.length);
}

/*!
    Creates a substring from the beginning of the receiver to the specified index.
    @param anIndex the last index of the receiver to use for the substring (inclusive)
    @return the substring
*/
- (CPString)substringToIndex:(unsigned)anIndex
{
    return substring(0, anIndex);
}

// Finding characters and substrings

/*!
    Finds the range of characters in the receiver where the specified string exists. If the string
    does not exist in the receiver, the range <code>length</code> will be 0.
    @param aString the string to search for in the receiver
    @return the range of charactrs in the receiver
*/
- (CPRange)rangeOfString:(CPString)aString
{
   return [self rangeOfString:aString options:0];
}

/*!
    Finds the range of characters in the receiver
    where the specified string exists. The search
    is subject to the options specified in the
    specified mask which can be a combination of:
    <pre>
    CPCaseInsensitiveSearch
    CPLiteralSearch
    CPBackwardsSearch
    CPAnchoredSearch
    CPNumericSearch
    </pre>
    @param aString the string to search for
    @param aMask the options to use in the search
    @return the range of characters in the receiver. If the string was not found,
    the <code>length</code> of the range will be 0.
*/
- (CPRange)rangeOfString:(CPString)aString options:(int)aMask
{
    return [self rangeOfString:aString options:aMask range:nil];
}

/*!
    Finds the range of characters in the receiver
    where the specified string exists in the given range 
    of the receiver.The search is subject to the options specified in the
    specified mask which can be a combination of:
    <pre>
    CPCaseInsensitiveSearch
    CPLiteralSearch
    CPBackwardsSearch
    CPAnchoredSearch
    CPNumericSearch
    </pre>
    @param aString the string to search for
    @param aMask the options to use in the search
    @param aRange the range of the receiver in which to search for
    @return the range of characters in the receiver. If the string was not found,
    the <code>length</code> of the range will be 0.
*/
- (CPRange)rangeOfString:(CPString)aString options:(int)aMask range:(CPrange)aRange
{
    var string = (aRange == nil) ? self : [self substringWithRange:aRange],
        location = CPNotFound;

    if (aMask & CPCaseInsensitiveSearch)
    {
        string = string.toLowerCase();
        aString = aString.toLowerCase();
    }

    if (aMask & CPBackwardsSearch)
        location = string.lastIndexOf(aString, aMask & CPAnchoredSearch ? length - aString.length : 0);
    else if (aMask & CPAnchoredSearch)
        location = string.substr(0, aString.length).indexOf(aString) != CPNotFound ? 0 : CPNotFound;
    else
        location = string.indexOf(aString);

    return CPMakeRange(location, location == CPNotFound ? 0 : aString.length);
}

//Replacing Substrings

/*!
    Returns a new string in which all occurrences of a target string in the reciever are replaced by 
    another given string.
    @param target The string to replace.
    @param replacement the string with which to replace the <pre>target<pre>
*/

- (CPString)stringByReplacingOccurrencesOfString:(CPString)target withString:(CPString)replacement
{
    return self.replace(new RegExp(target, "g"), replacement);
}

/*
    Returns a new string in which all occurrences of a target string in a specified range of the receiver
    are replaced by another given string.
    @param target The string to replace
    @param replacement the string with which to replace the <pre>target<pre>
    @param options A mask of options to use when comparing <pre>target<pre> with the receiver. Pass 0 to specify no options
    @param searchRange The range in the receiver in which to search for <pre>target<pre>.
*/

- (CPString)stringByReplacingOccurrencesOfString:(CPString)target withString:(CPString)replacement options:(int)options range:(CPRange)searchRange
{
    var start = substring(0, searchRange.location),
        stringSegmentToSearch = substr(searchRange.location, searchRange.length),
        end = substring(searchRange.location + searchRange.length, self.length),
        regExp;

    if (options & CPCaseInsensitiveSearch)
        regExp = new RegExp(target, "gi"); 
    else
        regExp = new RegExp(target, "g");

    return start + '' + stringSegmentToSearch.replace(regExp, replacement) + '' + end;
}

/*
   Returns a new string in which the characters in a specified range of the receiver 
   are replaced by a given string.
   @param range A range of characters in the receiver.
   @param replacement The string with which to replace the characters in <pre>range</pre>.
*/

- (CPString)stringByReplacingCharactersInRange:(CPRange)range withString:(CPString)replacement
{
	return '' + substring(0, range.location) + replacement + substring(range.location + range.length, self.length);
}


// Identifying and comparing strings

/*!
    Compares the receiver to the specified string.
    @param aString the string with which to compare
    @return the result of the comparison
*/
- (CPComparisonResult)compare:(CPString)aString
{
    return [self compare:aString options:nil];
}


/*
    Compares the receiver to the specified string.
    @param aString the string with which to compare
    @return the result of the comparison
*/
- (CPComparisonResult)caseInsensitiveCompare:(CPString)aString
{
    return [self compare:aString options:CPCaseInsensitiveSearch];
}

/*!
    Compares the receiver to the specified string, using options.
    @param aString the string with which to compare
    @param aMask the options to use for the comparison
    @return the result of the comparison
*/
- (CPComparisonResult)compare:(CPString)aString options:(int)aMask
{
    var lhs = self,
        rhs = aString;
    
    if (aMask & CPCaseInsensitiveSearch)
    {
        lhs = lhs.toLowerCase();
        rhs = rhs.toLowerCase();
    }
    
    if (lhs < rhs)
        return CPOrderedAscending;
    else if (lhs > rhs)
        return CPOrderedDescending;
    
    return CPOrderedSame;
}

/*!
    Returns <code>YES</code> if the receiver starts
    with the specified string. If <code>aString</code>
    is empty, the method will return <code>NO</code>.
*/
- (BOOL)hasPrefix:(CPString)aString
{
    return aString && aString != "" && indexOf(aString) == 0;
}

/*!
    Returns <code>NO</code> if the receiver ends
    with the specified string. If <code>aString</code>
    is empty, the method will return <code>NO</code>.
*/
- (BOOL)hasSuffix:(CPString)aString
{
    return aString && aString != "" && lastIndexOf(aString) == (length - aString.length);
}

/*!
    Returns <code>YES</code> if the specified string contains the same characters as the receiver.
*/
- (BOOL)isEqualToString:(CPString)aString
{
    return self == aString;
}

/*!
    Returns a hash of the string instance.
*/
- (unsigned)hash
{
    var hash = dictionary_getValue(CPStringHashes, self);
    
    if (!hash) 
    {
        hash = _objj_generateObjectHash();
        dictionary_setValue(CPStringHashes, self, hash);
    }
    
    return hash;
}

/*!
    Returns a copy of the receiver with all the first letters of words capitalized.
*/
- (CPString)capitalizedString
{
    var parts = self.split(/\b/g); // split on word boundaries
    for (var i = 0; i < parts.length; i++)
    {
        if (i == 0 || (/\s$/).test(parts[i-1])) // only capitalize if previous token was whitespace
            parts[i] = parts[i].substring(0, 1).toUpperCase() + parts[i].substring(1).toLowerCase();
        else
            parts[i] = parts[i].toLowerCase();
    }
    return parts.join("");
}

/*!
    Returns a copy of the string with all its characters made lower case.
*/
- (CPString)lowercaseString
{
    return toLowerCase();
}

/*!
    Returns a copy of the string with all its characters made upper case.
*/
- (CPString)uppercaseString
{
    return toUpperCase();
}

/*!
    Returns the text as a floating point value.
*/
- (double)doubleValue
{
    return parseFloat(self, 10);
}
/*!
    Returns <code>YES</code> on encountering one of "Y", "y", "T", "t", or 
    a digit 1-9. Returns <code>NO</code> otherwise. This method skips the initial 
    whitespace characters, +,- followed by Zeroes.
*/

- (BOOL)boolValue
{
    var replaceRegExp = new RegExp("^\\s*[\\+,\\-]*0*");
    return RegExp("^[Y,y,t,T,1-9]").test(self.replace(replaceRegExp, ''));
}

/*!
    Returns the text as a float point value.
*/
- (float)floatValue
{
    return parseFloat(self, 10);
}

/*!
    Returns the text as an integer
*/
- (int)intValue
{
    return parseInt(self, 10);
}

/*!
    Returns an the path components of this string. This
    method assumes that the string's content is a '/'
    separated file system path.
*/
- (CPArray)pathComponents
{
    return split('/');
}

/*!
    Returns the extension of the file denoted by this string.
    The '.' is not a part of the extension. This method assumes
    that the string's contents is the path to a file or just a filename.
*/
- (CPString)pathExtension
{
    return substr(lastIndexOf('.') + 1);
}

/*!
    Returns the last component of this string.
    This method assumes that the string's content is a '/'
    separated file system path.
*/
- (CPString)lastPathComponent
{
    var components = [self pathComponents];
    return components[components.length -1];
}

/*!
    Until this is corrected
    @ignore
*/
- (CPString)stringByDeletingLastPathComponent
{
    // FIXME: this is wrong: a/a/ returns a/a/.
    return substr(0, lastIndexOf('/') + 1);
}

- (CPString)stringByStandardizingPath
{
    return objj_standardize_path(self);
}

- (CPString)copy
{
    return new String(self);
}

@end


String.prototype.isa = CPString;


// sprintf:

var sprintfFormatRegex = new RegExp("([^%]+|%[\\+\\-\\ \\#0]*[0-9\\*]*(.[0-9\\*]+)?[hlL]?[cdieEfgGosuxXpn%@])", "g");
var sprintfTagRegex = new RegExp("(%)([\\+\\-\\ \\#0]*)([0-9\\*]*)((.[0-9\\*]+)?)([hlL]?)([cdieEfgGosuxXpn%@])");

/*!
  Creates a new string using C printf-style formatting. First argument should be a constant format string, like ' "float val = %f" ', remaining arguments should be the variables to print the values of, comma-separated.
  @param format the format to be used, printf-style
  @return the initialized CPString
*/
function sprintf(format)
{
    var format = arguments[0],
        tokens = format.match(sprintfFormatRegex),
        index = 0,
        result = "",
        arg = 1;

    for (var i = 0; i < tokens.length; i++)
    {
        var t = tokens[i];
        if (format.substring(index, index + t.length) != t)
        {
            return result;
        }
        index += t.length;

        if (t.charAt(0) != "%")
        {
            result += t;
        }
        else
        {
            var subtokens = t.match(sprintfTagRegex);
            if (subtokens.length != 8 || subtokens[0] != t)
            {
                return result;
            }

            var percentSign     = subtokens[1],
                flags           = subtokens[2],
                widthString     = subtokens[3],
                precisionString = subtokens[4],
                length          = subtokens[6],
                specifier       = subtokens[7];

            var width = null;
            if (widthString == "*")
                width = arguments[arg++];
            else if (widthString != "")
                width = Number(widthString);

            var precision = null;
            if (precisionString == ".*")
                precision = arguments[arg++];
            else if (precisionString != "")
                precision = Number(precisionString.substring(1));

            var leftJustify = (flags.indexOf("-") >= 0);
            var padZeros    = (flags.indexOf("0") >= 0);

            var subresult = "";

            if (RegExp("[diufeExXo]").test(specifier))
            {
                var num = Number(arguments[arg++]);

                var sign = "";
                if (num < 0)
                {
                    sign = "-";
                }
                else
                {
                    if (flags.indexOf("+") >= 0)
                        sign = "+";
                    else if (flags.indexOf(" ") >= 0)
                        sign = " ";
                }

                if (specifier == "d" || specifier == "i" || specifier == "u")
                {
                    var number = String(Math.abs(Math.floor(num)));

                    subresult = sprintf_justify(sign, "", number, "", width, leftJustify, padZeros)
                }

                if (specifier == "f")
                {
                    var number = String((precision != null) ? Math.abs(num).toFixed(precision) : Math.abs(num));
                    var suffix = (flags.indexOf("#") >= 0 && number.indexOf(".") < 0) ? "." : "";

                    subresult = sprintf_justify(sign, "", number, suffix, width, leftJustify, padZeros);
                }

                if (specifier == "e" || specifier == "E")
                {
                    var number = String(Math.abs(num).toExponential(precision != null ? precision : 21));
                    var suffix = (flags.indexOf("#") >= 0 && number.indexOf(".") < 0) ? "." : "";

                    subresult = sprintf_justify(sign, "", number, suffix, width, leftJustify, padZeros);
                }

                if (specifier == "x" || specifier == "X")
                {
                    var number = String(Math.abs(num).toString(16));
                    var prefix = (flags.indexOf("#") >= 0 && num != 0) ? "0x" : "";

                    subresult = sprintf_justify(sign, prefix, number, "", width, leftJustify, padZeros);
                }

                if (specifier == "o")
                {
                    var number = String(Math.abs(num).toString(8));
                    var prefix = (flags.indexOf("#") >= 0 && num != 0) ? "0" : "";

                    subresult = sprintf_justify(sign, prefix, number, "", width, leftJustify, padZeros);
                }

                if (RegExp("[A-Z]").test(specifier))
                    subresult = subresult.toUpperCase();
                else
                    subresult = subresult.toLowerCase();
            }
            else
            {
                var subresult = "";

                if (specifier == "%")
                    subresult = "%";
                else if (specifier == "c")
                    subresult = String(arguments[arg++]).charAt(0);
                else if (specifier == "s" || specifier == "@")
                    subresult = String(arguments[arg++]);
                else if (specifier == "p" || specifier == "n")
                {
                    arg++;
                    subresult = "";
                }

                subresult = sprintf_justify("", "", subresult, "", width, leftJustify, false);
            }

            result += subresult;
        }
    }
    return result;
}

var sprintf_justify = function(sign, prefix, string, suffix, width, leftJustify, padZeros)
{
    var length = (sign.length + prefix.length + string.length + suffix.length);
    if (leftJustify)
    {
        return sign + prefix + string + suffix + sprintf_pad(width - length, " ");
    }
    else
    {
        if (padZeros)
            return sign + prefix + sprintf_pad(width - length, "0") + string + suffix;
        else
            return sprintf_pad(width - length, " ") + sign + prefix + string + suffix;
    }
}

var sprintf_pad = function(n, ch)
{
    var result = "";
    for (var i = 0; i < n; i++)
        result += ch;
    return result;
}
