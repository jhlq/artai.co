#Preprintprocessor

files=["index.txt","week1.txt"]

file=files[1]
title="Science of Happiness"
text=readall(file)

function skipto(ext,char)
	for ci in 1:length(ext)
		if ext[ci]==char
			return ci
		end
	end
	return 0
end
linkloc=search(text,"http")
while !isempty(collect(linkloc))
	println(linkloc)
	linkend=skipto(text[linkloc[end]:end],' ')
	lineend=skipto(text[linkloc[end]:end],'\n')
	linkend=min(linkend,lineend)
	linkloc=linkloc[1]:linkloc[end]+linkend-2
	link=text[linkloc]
	if text[linkloc[1]-1]=='\n' && lineend>linkend
		linktextloc=linkloc[end]+1:linkloc[4]+lineend-2
		linktext=text[linktextloc]
		htmltext="""<a href="$link">$linktext</a>"""
		text=text[1:linkloc[1]-1]*htmltext*text[linktextloc[end]+1:end]
	else
		htmltext="""<a href="$link">$link</a>"""
		text=text[1:linkloc[1]-1]*htmltext*text[linkloc[end]+1:end]
	end
	linkloc=search(text[linkloc[end]:end],"http")+linkloc[end]
	println(linkloc)
end

#while contains(text,"\n\n")
#	text=replace(text,"\n\n","<br>\n")
#end

doc="""<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <title>$title</title>
</head>
<body>


</body>
</html>"""
