using Hexagons
using Gadfly
import Gadfly.plot
HC(x,y)=HexagonCubic(x,y,-x-y)
function distance(h1::HexagonCubic,h2::HexagonCubic)
	return (abs(h1.x - h2.x) + abs(h1.y1 - h2.y) + abs(h1.z - h2.z)) / 2
end

#Gadfly.set_default_plot_size(14cm, 8cm)
#X = rand(MultivariateNormal([0.0, 0.0], [1.0 0.5; 0.5 1.0]), 10);
#plot(x=X[1,:], y=X[2,:], Geom.hexbin(xbincount=10, ybincount=10))

#plot(x=[0,1,2], y=[0,0,1], color=repeat([0,2,3], outer=[1]),Scale.color_discrete())
function plot(map)
	x=AbstractFloat[]
	y=AbstractFloat[]
	cols=Int[]
	for (key,val) in map.locs
		c=center(val.hex)
		push!(x,c[1])
		push!(y,c[2])
		push!(cols,val.col)
	end
	plot(x=x,y=y,color=cols,Scale.color_discrete())
end

type Map
	locs
	r
	moves
end
type Loc
	hex
	col
	inf
end
function makemap(radius=6)
	map=Map(Dict{Tuple{Int,Int},Loc}(),radius,Any[])
	for r in 1:radius-1
		for h in ring(r)
			map.locs[h.x,h.y]=Loc(h,0,Dict{Int,AbstractFloat}(1=>0,2=>0,3=>0))
		end
	end
	return map		
end
function sprinf!(map,x,y,c,ir) #spread influence
	visited=[(x,y)]
	fringe=[(x,y)]
	for i in 1:ir
		if i==1 && haskey(map.locs,fringe[1])
			map.locs[fringe[1]].inf[c]+=1.0
		else
			nfringe=[]
			for k in 1:length(fringe)
				for adj in neighbors(map.locs[fringe[k]].hex) 
					ladj=(adj.x,adj.y)
					if !in(ladj,visited) && haskey(map.locs,ladj)
						map.locs[ladj].inf[c]+=1.0/i
						if map.locs[ladj].col==0 || map.locs[ladj].col==c 
							push!(nfringe,ladj)
						end
						push!(visited,ladj)
					end 
				end
			end
			if length(nfringe)==0
				break
			end
			fringe=nfringe
		end
	end
	return map
end
function place!(map,x,y,c,ir=6)
	if map.locs[x,y].col!=0
		error("($x,$y) is occupied.")
	end
	map.locs[x,y].hex=HC(x,y)	
	map.locs[x,y].col=c
	push!(map.moves,[(x,y),c])
	sprinf!(map,x,y,c,ir)
end
#place!(map,xy,c)=place!(map,xy[1],xy[2],c)
function place!(map,xysc::Array,ir)
	for xyc in xysc
		place!(map,xyc[1][1],xyc[1][2],xyc[2],ir)
	end
	return map
end
function to_l(mstr)
	ms=split(mstr,',')
	return (parse(Int,ms[1]),parse(Int,ms[2]))
end
function to_a(movestr)
	a=Any[]
	coldic=Dict("#f00"=>1,"#0f0"=>2,"#00f"=>3)
	stra=split(movestr,'+')
	for str in stra
		sa=split(str,':')
		if in(sa[1],keys(coldic))
			push!(a,[to_l(sa[2]),coldic[sa[1]]])
		end
	end
	return a
end
function to_s(map::Map)
	s="#909:0,0"
	diccol=Dict(1=>"#f00",2=>"#0f0",3=>"#00f")
	for move in map.moves
		s*="+$(diccol[move[2]]):$(move[1][1]),$(move[1][2])"
	end
	return s
end
function makemap(movestr::AbstractString,ir=6,r=6)
	map=makemap(r)
	place!(map,to_a(movestr),ir)
end
function max(d::Dict)
	k=Int[]
	m=-Inf
	for (key,val) in d
		if val==m
			push!(k,key)
		elseif val>=m
			m=val
			k=Int[key]
		end
	end
	return k
end
function points(l::Loc)
	maxinf=max(l.inf)
	p=1
	if !in(l.col,maxinf)
		p+=1
	end
	c=Dict{Int,AbstractFloat}()
	for col in maxinf
		c[col]=p/length(maxinf)
	end
	return c
end
function score(map::Map)
	s=Dict{Int,AbstractFloat}(1=>0,2=>0,3=>0)
	for (key,val) in map.locs
		for (c,p) in points(val)
			s[c]+=p
		end
	end
	return s
end

function relinf(inf::Dict,col) #relative influense
	cinf=inf[col]
	minf=0
	for (k,v) in inf
		if k!=col && v>minf
			minf=v
		end
	end
	return cinf-minf
end
type AI
	col
end
function letAIplay(map::Map,ai::AI)
#opening evaluate whole board -> decide on segment
	cornerscores=ones(6)
	for corneri in 1:6
		cr=floor(map.r/2)
		cornercenter=neighbor(HC(0,0),corneri,cr+1)
		for hex in ring(cornercenter,cr)
			l=map[hex.x,hex.y]
			data=relinf(l.inf,ai.col
		end
	end
		
	#check relative influence
	#give value to each section, pick one by random from 1:v1:v2:v3...
	#r->AI->ring to put
#later evaluate move to expand from
	#determine expansion length
	#up or down?
#inspect connections

end
