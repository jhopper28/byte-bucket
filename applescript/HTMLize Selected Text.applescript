(*
HTMLize Selected Text 1.3.2
Written by Eric Knibbe, 2008

This script will grab selected text from the frontmost window and convert non-standard characters to 
named or numeric HTML entities, and optionally apply the Markdown and SmartyPants filters before 
replacing the originally selected text with the processed version. It works best when associating it with 
a hotkey using a utility like Butler, as it requires the user to manually select their frontmost application 
when invoked from the Scripts menu under OS X 10.4 Tiger. 

Markdown and SmartyPants are available at http://daringfireball.net/projects/, and should be present 
in your Scripts folder, your path, or in one of the support folders for BBEdit, TextMate, or TextWrangler. 
Also, ensure that GUI Scripting is enabled (use AppleScript Utility, located in /Applications/AppleScript). 

Version history: see Description field
­*)

-- Preferences
property useMarkdown : true
property useSmartyPants : true
property useNamedEntities : true

tell application "Finder" to set homepath to POSIX path of (home as alias)

set pathAdditions to "export PATH=$PATH:" & ¬
	"/Applications/BBEdit.app/Contents/PlugIns/\"Language Modules\"/Markdown.bblm/Contents/Resources:" & ¬
	"/Applications/TextWrangler.app/Contents/PlugIns/\"Language Modules\"/Markdown.bblm/Contents/Resources:" & ¬
	"/Library/Scripts:" & ¬
	"/Library/Scripts/bin:" & ¬
	homepath & "Library/Scripts:" & ¬
	homepath & "Library/Scripts/bin:" & ¬
	homepath & "Library/\"Application Support\"/BBEdit/\"Unix Support\"/\"Unix Filters\":" & ¬
	homepath & "Library/\"Application Support\"/TextMate/Scripts:" & ¬
	homepath & "Library/\"Application Support\"/TextWrangler/\"Unix Support\"/\"Unix Filters\";"
set markdownCheck to do shell script pathAdditions & "Markdown.pl -shortversion; exit 0"
if markdownCheck = "" then
	set useMarkdown to false
end if
set smartypantsCheck to do shell script pathAdditions & "SmartyPants.pl -shortversion; exit 0"
if smartypantsCheck = "" then
	set useSmartyPants to false
end if

tell application "System Events"
	set frontApp to name of first application process whose frontmost is true
	-- if the script was invoked from the Script menu under OS X 10.4 or earlier
	if frontApp = "System Events" then
		set appList to (name of every application process whose visible is true)
		choose from list appList with prompt "Select your current application:"
		if result is not false then
			set frontApp to result as string
		else
			return
		end if
	end if
end tell

tell application frontApp to activate

tell application "System Events"
	tell application process frontApp
		tell (menu "Edit" of menu bar item "Edit" of menu bar 1)
			click menu item "Copy"
		end tell
	end tell
	-- pause to allow copy action to take effect
	delay 0.2
	-- remove formatting from the clipboard text
	set theText to «class ktxt» of ((the clipboard as string) as record)
	-- apply Markdown
	if useMarkdown then
		set theText to do shell script pathAdditions & ¬
			"echo " & quoted form of theText & " | Markdown.pl;"
	end if
	-- apply SmartyPants
	if useSmartyPants then
		-- straighten any existing smart quotes so SmartyPants will recognize them
		repeat with smartyChar in smartyChars
			set theText to my find_replace(item 1 of smartyChar, item 2 of smartyChar, theText)
		end repeat
		set theText to do shell script pathAdditions & ¬
			"echo " & quoted form of theText & " | SmartyPants.pl -2;"
	end if
	-- convert special characters
	repeat with specialChar in specialChars
		if useNamedEntities then
			set theText to my find_replace(item 1 of specialChar, item 2 of specialChar, theText)
		else
			set theText to my find_replace(item 1 of specialChar, item 3 of specialChar, theText)
		end if
	end repeat
	-- remove any styles applied by AppleScript from the text
	set the clipboard to (do shell script "echo " & quoted form of theText)
	-- replace the originally selected text
	tell application process frontApp
		tell (menu "Edit" of menu bar item "Edit" of menu bar 1)
			if (menu item "Paste and Match Style" exists) then
				click menu item "Paste and Match Style"
			else
				click menu item "Paste"
			end if
		end tell
	end tell
end tell

property smartyChars : {¬
	{"“", "\""}, ¬
	{"”", "\""}, ¬
	{"‘", "'"}, ¬
	{"’", "'"}, ¬
	{"–", "--"}, ¬
	{"—", "---"}, ¬
	{"…", "..."}}
-- since AppleScript supports only the MacRoman character set, only HTML entities within that set are listed
-- entity list from https://evolt.org/entities
property specialChars : {¬
	{" ", "&nbsp;", "&#160;", "non-breaking space"}, ¬
	{"¡", "&iexcl;", "&#161;", "inverted exclamation mark"}, ¬
	{"¢", "&cent;", "&#162;", "cent sign"}, ¬
	{"£", "&pound;", "&#163;", "pound sign"}, ¬
	{"¥", "&yen;", "&#165;", "yen sign"}, ¬
	{"§", "&sect;", "&#167;", "section sign"}, ¬
	{"¨", "&uml;", "&#168;", "diaeresis"}, ¬
	{"©", "&copy;", "&#169;", "copyright sign"}, ¬
	{"ª", "&ordf;", "&#170;", "feminine ordinal indicator"}, ¬
	{"«", "&laquo;", "&#171;", "left-pointing double angle quotation mark"}, ¬
	{"¬", "&not;", "&#172;", "not sign"}, ¬
	{"®", "&reg;", "&#174;", "registered sign"}, ¬
	{"¯", "&macr;", "&#175;", "macron"}, ¬
	{"°", "&deg;", "&#176;", "degree sign"}, ¬
	{"±", "&plusmn;", "&#177;", "plus-minus sign"}, ¬
	{"´", "&acute;", "&#180;", "acute accent"}, ¬
	{"µ", "&micro;", "&#181;", "micro sign"}, ¬
	{"¶", "&para;", "&#182;", "pilcrow sign"}, ¬
	{"·", "&middot;", "&#183;", "middle dot"}, ¬
	{"¸", "&cedil;", "&#184;", "cedilla"}, ¬
	{"º", "&ordm;", "&#186;", "masculine ordinal indicator"}, ¬
	{"»", "&raquo;", "&#187;", "right-pointing double angle quotation mark"}, ¬
	{"1⁄4", "&frac14;", "&#188;", "vulgar fraction one quarter"}, ¬
	{"1⁄2", "&frac12;", "&#189;", "vulgar fraction one half"}, ¬
	{"3⁄4", "&frac34;", "&#190;", "vulgar fraction three quarters"}, ¬
	{"¿", "&iquest;", "&#191;", "inverted question mark"}, ¬
	{"À", "&Agrave;", "&#192;", "latin capital letter A with grave"}, ¬
	{"Á", "&Aacute;", "&#193;", "latin capital letter A with acute"}, ¬
	{"Â", "&Acirc;", "&#194;", "latin capital letter A with circumflex"}, ¬
	{"Ã", "&Atilde;", "&#195;", "latin capital letter A with tilde"}, ¬
	{"Ä", "&Auml;", "&#196;", "latin capital letter A with diaeresis"}, ¬
	{"Å", "&Aring;", "&#197;", "latin capital letter A with ring above"}, ¬
	{"Æ", "&AElig;", "&#198;", "latin capital letter AE"}, ¬
	{"Ç", "&Ccedil;", "&#199;", "latin capital letter C with cedilla"}, ¬
	{"È", "&Egrave;", "&#200;", "latin capital letter E with grave"}, ¬
	{"É", "&Eacute;", "&#201;", "latin capital letter E with acute"}, ¬
	{"Ê", "&Ecirc;", "&#202;", "latin capital letter E with circumflex"}, ¬
	{"Ë", "&Euml;", "&#203;", "latin capital letter E with diaeresis"}, ¬
	{"Ì", "&Igrave;", "&#204;", "latin capital letter I with grave"}, ¬
	{"Í", "&Iacute;", "&#205;", "latin capital letter I with acute"}, ¬
	{"Î", "&Icirc;", "&#206;", "latin capital letter I with circumflex"}, ¬
	{"Ï", "&Iuml;", "&#207;", "latin capital letter I with diaeresis"}, ¬
	{"Ñ", "&Ntilde;", "&#209;", "latin capital letter N with tilde"}, ¬
	{"Ò", "&Ograve;", "&#210;", "latin capital letter O with grave"}, ¬
	{"Ó", "&Oacute;", "&#211;", "latin capital letter O with acute"}, ¬
	{"Ô", "&Ocirc;", "&#212;", "latin capital letter O with circumflex"}, ¬
	{"Õ", "&Otilde;", "&#213;", "latin capital letter O with tilde"}, ¬
	{"Ö", "&Ouml;", "&#214;", "latin capital letter O with diaeresis"}, ¬
	{"Ø", "&Oslash;", "&#216;", "latin capital letter O with stroke"}, ¬
	{"Ù", "&Ugrave;", "&#217;", "latin capital letter U with grave"}, ¬
	{"Ú", "&Uacute;", "&#218;", "latin capital letter U with acute"}, ¬
	{"Û", "&Ucirc;", "&#219;", "latin capital letter U with circumflex"}, ¬
	{"Ü", "&Uuml;", "&#220;", "latin capital letter U with diaeresis"}, ¬
	{"ß", "&szlig;", "&#223;", "latin small letter sharp s"}, ¬
	{"à", "&agrave;", "&#224;", "latin small letter a with grave"}, ¬
	{"á", "&aacute;", "&#225;", "latin small letter a with acute"}, ¬
	{"â", "&acirc;", "&#226;", "latin small letter a with circumflex"}, ¬
	{"ã", "&atilde;", "&#227;", "latin small letter a with tilde"}, ¬
	{"ä", "&auml;", "&#228;", "latin small letter a with diaeresis"}, ¬
	{"å", "&aring;", "&#229;", "latin small letter a with ring above"}, ¬
	{"æ", "&aelig;", "&#230;", "latin small letter ae"}, ¬
	{"ç", "&ccedil;", "&#231;", "latin small letter c with cedilla"}, ¬
	{"è", "&egrave;", "&#232;", "latin small letter e with grave"}, ¬
	{"é", "&eacute;", "&#233;", "latin small letter e with acute"}, ¬
	{"ê", "&ecirc;", "&#234;", "latin small letter e with circumflex"}, ¬
	{"ë", "&euml;", "&#235;", "latin small letter e with diaeresis"}, ¬
	{"ì", "&igrave;", "&#236;", "latin small letter i with grave"}, ¬
	{"í", "&iacute;", "&#237;", "latin small letter i with acute"}, ¬
	{"î", "&icirc;", "&#238;", "latin small letter i with circumflex"}, ¬
	{"ï", "&iuml;", "&#239;", "latin small letter i with diaeresis"}, ¬
	{"ñ", "&ntilde;", "&#241;", "latin small letter n with tilde"}, ¬
	{"ò", "&ograve;", "&#242;", "latin small letter o with grave"}, ¬
	{"ó", "&oacute;", "&#243;", "latin small letter o with acute"}, ¬
	{"ô", "&ocirc;", "&#244;", "latin small letter o with circumflex"}, ¬
	{"õ", "&otilde;", "&#245;", "latin small letter o with tilde"}, ¬
	{"ö", "&ouml;", "&#246;", "latin small letter o with diaeresis"}, ¬
	{"÷", "&divide;", "&#247;", "division sign"}, ¬
	{"ø", "&oslash;", "&#248;", "latin small letter o with stroke"}, ¬
	{"ù", "&ugrave;", "&#249;", "latin small letter u with grave"}, ¬
	{"ú", "&uacute;", "&#250;", "latin small letter u with acute"}, ¬
	{"û", "&ucirc;", "&#251;", "latin small letter u with circumflex"}, ¬
	{"ü", "&uuml;", "&#252;", "latin small letter u with diaeresis"}, ¬
	{"ÿ", "&yuml;", "&#255;", "latin small letter y with diaeresis"}, ¬
	{"ƒ", "&fnof;", "&#402;", "latin small f with hook"}, ¬
	{"Ω", "&Omega;", "&#937;", "greek capital letter omega"}, ¬
	{"π", "&pi;", "&#960;", "greek small letter pi"}, ¬
	{"•", "&bull;", "&#8226;", "bullet"}, ¬
	{"…", "&hellip;", "&#8230;", "horizontal ellipsis"}, ¬
	{"⁄", "&frasl;", "&#8260;", "fraction slash"}, ¬
	{"™", "&trade;", "&#8482;", "trade mark sign"}, ¬
	{"∂", "&part;", "&#8706;", "partial differential"}, ¬
	{"∏", "&prod;", "&#8719;", "n-ary product"}, ¬
	{"∑", "&sum;", "&#8721;", "n-ary sumation"}, ¬
	{"√", "&radic;", "&#8730;", "square root"}, ¬
	{"∞", "&infin;", "&#8734;", "infinity"}, ¬
	{"∫", "&int;", "&#8747;", "integral"}, ¬
	{"≈", "&asymp;", "&#8776;", "almost equal to"}, ¬
	{"≠", "&ne;", "&#8800;", "not equal to"}, ¬
	{"≤", "&le;", "&#8804;", "less-than or equal to"}, ¬
	{"≥", "&ge;", "&#8805;", "greater-than or equal to"}, ¬
	{"◊", "&loz;", "&#9674;", "lozenge"}, ¬
	{"Œ", "&OElig;", "&#338;", "latin capital ligature OE"}, ¬
	{"œ", "&oelig;", "&#339;", "latin small ligature oe"}, ¬
	{"Ÿ", "&Yuml;", "&#376;", "latin capital letter Y with diaeresis"}, ¬
	{"ˆ", "&circ;", "&#710;", "modifier letter circumflex accent"}, ¬
	{"˜", "&tilde;", "&#732;", "small tilde"}, ¬
	{"–", "&ndash;", "&#8211;", "en dash"}, ¬
	{"—", "&mdash;", "&#8212;", "em dash"}, ¬
	{"‘", "&lsquo;", "&#8216;", "left single quotation mark"}, ¬
	{"’", "&rsquo;", "&#8217;", "right single quotation mark"}, ¬
	{"‚", "&sbquo;", "&#8218;", "single low-9 quotation mark"}, ¬
	{"“", "&ldquo;", "&#8220;", "left double quotation mark"}, ¬
	{"”", "&rdquo;", "&#8221;", "right double quotation mark"}, ¬
	{"„", "&bdquo;", "&#8222;", "double low-9 quotation mark"}, ¬
	{"†", "&dagger;", "&#8224;", "dagger"}, ¬
	{"‡", "&Dagger;", "&#8225;", "double dagger"}, ¬
	{"‰", "&permil;", "&#8240;", "per mille sign"}, ¬
	{"‹", "&lsaquo;", "&#8249;", "single left-pointing angle quotation mark"}, ¬
	{"›", "&rsaquo;", "&#8250;", "single right-pointing angle quotation mark"}, ¬
	{"€", "&euro;", "&#8364;", "euro sign"}, ¬
	{"∆", "&#8710;", "&#8710;", "increment"}, ¬
	{"ﬁ", "&#64257;", "&#64257;", "latin small ligature fi"}, ¬
	{"ﬂ", "&#64258;", "&#64258;", "latin small ligature fl"}, ¬
	{"", "&#63743;", "&#63743;", "Apple logo"}, ¬
	{"ı", "&#305;", "&#305;", "latin small letter dotless i"}, ¬
	{"˘", "&#728;", "&#728;", "breve"}, ¬
	{"˙", "&#729;", "&#729;", "dot above"}, ¬
	{"˚", "&#730;", "&#730;", "ring above"}, ¬
	{"˝", "&#733;", "&#733;", "double acute accent"}, ¬
	{"˛", "&#731;", "&#731;", "ogonek"}, ¬
	{"ˇ", "&#711;", "&#711;", "caron"}}

on find_replace(findText, replaceText, sourceText)
	set ASTID to AppleScript's text item delimiters
	set AppleScript's text item delimiters to findText
	set sourceText to text items of sourceText
	set AppleScript's text item delimiters to replaceText
	set sourceText to "" & sourceText
	set AppleScript's text item delimiters to ASTID
	return sourceText
end find_replace
