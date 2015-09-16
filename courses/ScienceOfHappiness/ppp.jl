#Preprintprocessor
function skipto(str,char)
	for ci in 1:length(str)
		#print(str[ci])
		if str[ci]==char
			return ci
		end
	end
	return 0
end
files=["index.txt","week1.txt"]

function process(fname,title)
	text=readall("$fname.txt")
	linkloc=search(text,"http")
	while !isempty(collect(linkloc))
#		println(text[linkloc])
		linkend=skipto(text[linkloc[end]:end],' ')
		lineend=skipto(text[linkloc[end]:end],'\n')
		linkend=min(linkend,lineend)
		linkloc=linkloc[1]:linkloc[end]+linkend-2
		link=text[linkloc]
		if text[linkloc[1]-1]=='\n' && lineend>linkend
			linktextloc=linkloc[end]+1:linkloc[4]+lineend-2
			linktext=text[linktextloc]
			htmltext="""<a href="$link">$linktext</a>"""
			l=length(htmltext)
			text=text[1:linkloc[1]-1]*htmltext*text[linktextloc[end]+1:end]
		else
			htmltext="""<a href="$link">$link</a>"""
			l=length(htmltext)
			text=text[1:linkloc[1]-1]*htmltext*text[linkloc[end]+1:end]
		end
		linkloc=search(text[linkloc[1]+l:end],"http")+linkloc[1]+l-1
		#println(text)
	end
	hloc=search(text,"*")
	while !isempty(collect(hloc))
		hn=text[hloc[1]+1]=='*'?(text[hloc[1]+2]=='*'?1:2):3
		hstart=hloc[1]+4-hn
		lineend=skipto(text[hstart:end],'\n')
		htext=text[hstart:hstart+lineend-2]
		htmltext="<h$hn>$htext</h$hn>"
		text=text[1:hloc[1]-1]*htmltext*text[hstart+lineend-1:end]
		hloc=search(text,"*")
	end
	ulloc=search(text,"<ul>")
	while !isempty(collect(ulloc))
		tulloc=search(text[ulloc[end]:end],"</ul>")+ulloc[end]-1
		list=text[ulloc[end]+2:tulloc[1]-2]
		listarray=readdlm(IOBuffer(list),'\n')
		htmltext=""
		for li in listarray
			htmltext*="<li>$li</li>\n"
		end
		text=text[1:ulloc[end]]*htmltext*text[tulloc[1]:end]
		ulloc=search(text[tulloc[end]:end],"<ul>")+tulloc[end]-1
		#println(text[ulloc])
	end
	while contains(text,"\n\n")
		text=replace(text,"\n\n","<br>\n")
	end
	while contains(text,"<easy>")
	text=replace(text,"<easy>","""<span class="easy">""")
	end
	while contains(text,"<yellow>")
		text=replace(text,"<yellow>","""<span class="medium">""")
	end
	while contains(text,"<red>")
		text=replace(text,"<red>","""<span class="hard">""")
	end

	doc="""<!DOCTYPE html>
	<html>
	<head>
	  <meta charset="utf-8">
	  <title>ArtAI, Happiness, $title</title>
	<link rel="stylesheet" type="text/css" href="../style.css">
	</head>
	<body>
	<nav>
	<a href="index.html">Index.</a>
	<a href="week1.html">Week 1.</a>
	<a href="week2.html">Week 2.</a>
	</nav>
	$text

	</body>
	</html>"""

	f=open("$fname.html","w")
	write(f,doc)
	close(f)
#	print(text)
end

process("index","Science of Happiness")
process("week1","Week 1")
