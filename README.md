# KanjiLookup
Japanese handwriting recognition under iOS based on Zinnia

This is a sample application demostrating how to use https://github.com/shinjukunian/iOS-Zinnia-Japanese-Handwriting-Input to recognize handwritten Japanese characters under iOS. 
The main application is a simple Kanji dictionary based on KanjiDic (http://www.csse.monash.edu.au/~jwb/kanjidic.html). 
 
<img src="https://github.com/shinjukunian/KanjiLookup/blob/gh-pages/images/image3.png" width="200" />

<img src="https://github.com/shinjukunian/KanjiLookup/blob/gh-pages/images/lookup_animation.gif" width="200" />

This  small application turned out to be so useful for myself (as an intermediate to advanved student of Japanese) that I decided to publish it on the App Store as well.

##Keyboard Extension
The second example is an iOS keyboard extension for a Japanese handwriting keyboard. 'Autocompletion' is very crude and has only a quite limited, static dictionary. Since recognition works best on a quadratic canvas, using this keyboard on an iPad has only limited use. The overall layout is still quite unrefined and doesn't handle rotation very gracefully.

<img src="https://github.com/shinjukunian/KanjiLookup/blob/gh-pages/images/keyboard_1.PNG" width="200" /> 

<img src="https://github.com/shinjukunian/KanjiLookup/blob/gh-pages/images/keyboard_small.gif" width="200" /> 

As a general keyboard, this extension is quite limited because Kana input is rather painful and the dictionary is unaware of context or inflections.

# Acknowledgements
This project uses the EDICT (http://www.csse.monash.edu.au/~jwb/edict.html) and KANJIDIC dictionary files. These files are the property of the Electronic Dictionary Research and Development Group (http://www.edrdg.org/), and are used in conformance with the Group's licence (http://www.edrdg.org/edrdg/licence.html).
The autocompletion suggestions are based on http://www.manythings.org/q/n-about.htm.



 
