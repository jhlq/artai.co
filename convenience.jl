function makelink(str)
	"<a href=\""*str*"\">"*str*"</a>"
end
function makelist(liststr::String)
	list=readdlm(IOBuffer(liststr),' ')
	str=""
	for l in list
		if length(l)>4 && l[1:4]=="http"
			l=makelink(l)
		end
		str*="<li> $l </li>\n"
	end
	return str
end
