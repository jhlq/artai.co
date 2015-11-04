#Preprintprocessor
function skipto(str,char)
	for ci in 1:length(str)
		#print(str[ci])
		try
			if str[ci]==char
				return ci
			end
		catch er
			#error("There was a problem reading this at index $ci: $(str[ci-1])")
		end	
	end
	return 0
end
function makelistarray(list)
	listarray=AbstractString[]
	n1=skipto(list,'\n')
	push!(listarray,list[1:n1])
	n2=skipto(list[n1+1:end],'\n')+n1
	while n2>n1
		push!(listarray,list[n1:n2])
		n1=n2
		n2=skipto(list[n1+1:end],'\n')+n1
	end
	return listarray
end

function process(fname,title)
	text=readall("$fname.txt")
	linkloc=search(text,"\nhttp")
	while !isempty(collect(linkloc))
#		println(text[linkloc])
		linkend=skipto(text[linkloc[end]:end],' ')
		lineend=skipto(text[linkloc[end]:end],'\n')
		#println("$(linkloc[1]),$linkend,$lineend")
		if linkend==0 #why does it become 0..?
			linkend=lineend
		end
		linkend=min(linkend,lineend)
		linkloc=linkloc[2]:linkloc[end]+linkend-2
		link=text[linkloc]
		#println(link)
		#println("ll: $linkloc,le: $lineend, linkend")
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
		linkloc=search(text[linkloc[1]+l:end],"\nhttp")+linkloc[1]+l-1
		#println(htmltext)
	end
	hloc=search(text,"*")
	while !isempty(collect(hloc))
		hloc1=hloc[1]
		hn=text[hloc1+1]=='*'?(text[hloc1+2]=='*'?1:2):3
		hstart=hloc1+4-hn
		lineend=skipto(text[hstart:end],'\n')
		htext=text[hstart:hstart+lineend-2]
		htmltext="<h$hn>$htext</h$hn>\n"
		text=text[1:hloc1-1]*htmltext*text[hstart+lineend-1:end]
		hloc=search(text,"*")
	end
	hloc=search(text,"\n#")
	while !isempty(collect(hloc))
		hloc1=hloc[1]+1
		hn=text[hloc1+1]=='#'?(text[hloc1+2]=='#'?1:2):3
		hstart=hloc1+4-hn
		lineend=skipto(text[hstart:end],'\n')
		htext=text[hstart:hstart+lineend-2]
		htmltext="<h$(hn+3)>$htext</h$(hn+3)>\n"
		text=text[1:hloc1-1]*htmltext*text[hstart+lineend-1:end]
		#print(text[hstart-15:hstart+100])
		hloc=search(text,"\n#")
	end
	imgloc=search(text,"\nimg: ")
	while !isempty(collect(imgloc))
		lineend=skipto(text[imgloc[end]:end],'\n')
		htmltext="""<img src="$(text[imgloc[end]+1:imgloc[end]+lineend-2])" alt="$(text[imgloc[end]+1:imgloc[end]+lineend-2])">"""
#		println(htmltext)
		text=text[1:imgloc[1]]*"\n"*htmltext*"\n"*"\n"*text[imgloc[end]+lineend-1:end]
		imgloc=search(text,"\nimg:")
		break
	end
	ulloc=search(text,"<ul>")
	while !isempty(collect(ulloc))
		#println(text[ulloc[1]:ulloc[end]+3])
		tulloc=search(text[ulloc[end]:end],"</ul>")+ulloc[end]-1
		list=text[ulloc[end]+2:tulloc[1]-2]
		listarray=makelistarray(list*"\n ")
		#show(list);println("\n\n\n")
		#show(listarray);println("\n\n\n")
		htmltext=""
		for li in listarray
			htmltext*="<li>$li</li>\n"
		end
		text=text[1:ulloc[end]]*htmltext*text[tulloc[1]:end]
		ulloc=search(text[tulloc[end]:end],"<ul>")+tulloc[end]-1
		#println(text[ulloc])
	end
	while contains(text,"\n\n\n")
		text=replace(text,"\n\n\n","\n\n")
	end
	nnloc=search(text,"\n\n")
	while !isempty(collect(nnloc))
		nnnloc=search(text[nnloc[end]:end],"\n\n")+nnloc[end]-1
		if isempty(collect(nnnloc))
			break
		end
		p=text[nnloc[end]+1:nnnloc[1]-1]
		htmltext="<p>$p</p>"
		text=text[1:nnloc[1]]*htmltext*text[nnnloc[1]:end]
		nnloc=search(text[nnloc[end]:end],"\n\n")+nnloc[end]-1
	end
	medloc=search(text,"\nyellow:")
	while !isempty(collect(medloc))
		nloc=search(text[medloc[end]:end],"\n")+medloc[end]-1
		p=text[medloc[end]+1:nloc[1]-1]
		htmltext="""<span class="yellow">$p</span>"""
		text=text[1:medloc[1]]*htmltext*text[nloc[1]:end]
		medloc=search(text[medloc[end]:end],"\nyellow:")+medloc[end]-1
	end
	while contains(text,"<easy>")
		text=replace(text,"<easy>","""<span class="easy">""")
	end
	while contains(text,"<green>")
		text=replace(text,"<green>","""<span class="easy">""")
	end
	while contains(text,"<yellow>")
		text=replace(text,"<yellow>","""<span class="medium">""")
	end
	while contains(text,"<red>")
		text=replace(text,"<red>","""<span class="hard">""")
	end
	nav=readall("nav.txt")
	dir=readall("title.txt")
	doc="""<!DOCTYPE html>
	<html lang="en">
	<head>
	  <meta charset="utf-8">
	  <title>ArtAI: $dir $title</title>
	<link rel="stylesheet" type="text/css" href="../style.css">
	</head>
	<body>
	$nav
	$text

	</body>
	</html>"""

	f=open("$fname.html","w")
	write(f,doc)
	close(f)
#	print(text)
end

pagestoprocess=readdlm("pages.txt",'/')
for pi in 1:size(pagestoprocess,1)
	process(pagestoprocess[pi,1],pagestoprocess[pi,2])
end

