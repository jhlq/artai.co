using Mux
include("hexago.jl")
map=makemap(6,6,true)
place!(map,1,1,1)
place!(map,1,-1,2)
place!(map,-1,1,3)
function makequerystring(d::Dict)
	str=""
	for (key,val) in d
		str*=key*"="*val*"&"
	end
	return str[1:end-1]
end
function asciimap(map::Map,options)
	r=map.r
	amap=""
	cols=["#600","#060","#006"]
	for line in 1:r+r-1
		l=line
		rep=r-l
		lrep=r+l-1
		y=r-line
		xo=-r
		if line>r
			l-=r
			rep=l
			lrep=2r-l-1
			xo+=l
		end
		amap*=repeat(".",rep)
		for lx in 1:lrep
			loc=(lx+xo,y)
			col=map.locs[loc].col
			if col==0
				oc=deepcopy(options)
				oc["moves"]*="+"*oc["col"]*":$(loc[1]),$(loc[2])"
				np=parse(oc["col"])%parse(oc["players"])+1
				oc["col"]="$np"
				amap*="<a title='$loc' href='$(makequerystring(oc))'>0</a> "
			elseif col<0
				amap*="<span title='$loc'>x </span>"
			else
				d=" "
				if map.moves[end][1]==loc
					d="¤"
				end
				amap*="<span title='$loc' style='color:$(cols[col])'>$col$d</span>"
			end
		end
		amap*="\n<br>"
	end
	return amap
end
function asciimap(optstr::AbstractString)
	options=HttpParser.parsequerystring(optstr)
	v=Dict("r"=>"6","ir"=>"6","moves"=>"-1:0,0","players"=>"2","col"=>"1")
	for k in keys(v)
		if haskey(options,k)
			v[k]=options[k]
		end
	end
	map=makemap(v["moves"],parse(Int,v["r"]),parse(Int,v["ir"]),false)
	#println(v,map.locs[(1,0)])
	return asciimap(map,v)
end

@app test = (
	Mux.defaults,
	page(respond("<h1>Hello Hexago!</h1>\n")),
	page("/map/:options",req->asciimap(req[:params][:options])),
	page("/about",
			 probabilty(0.1, respond("<h1>Boo!</h1>")),
			 respond("<h1>About Me</h1>")),
	page("/user/:user", req -> "<h1>Hello, $(req[:params][:user])!</h1>"),
	page("/query/:string",req->"$(HttpParser.parsequerystring(req[:params][:string]))"),
	Mux.notfound())

serve(test)


