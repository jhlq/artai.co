using Hexagons
using Gadfly
import Gadfly.plot
HC(x,y)=HexagonCubic(x,y,-x-y)
function distance(h1::HexagonCubic,h2::HexagonCubic)
	return (abs(h1.x - h2.x) + abs(h1.y1 - h2.y) + abs(h1.z - h2.z)) / 2
end
nhexs(r)=r==1?7:nhexs(r-1)+r*6

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
	ir
	score
end
type Loc
	hex
	col
	inf
end
function makemap(radius=6,ir=6,removecenter::Bool=false)
	map=Map(Dict{Tuple{Int,Int},Loc}(),radius,Any[],ir,Dict{Int,AbstractFloat}(1=>0,2=>0,3=>0))
	if removecenter
		map.locs[0,0]=Loc(HC(0,0),-1,Dict{Int,AbstractFloat}(1=>0,2=>0,3=>0))
	else
		map.locs[0,0]=Loc(HC(0,0),0,Dict{Int,AbstractFloat}(1=>0,2=>0,3=>0))
	end
	for r in 1:radius-1
		for h in ring(r)
			map.locs[h.x,h.y]=Loc(h,0,Dict{Int,AbstractFloat}(1=>0,2=>0,3=>0))
		end
	end
	return map		
end
function resetinf!(map)
	for (k,v) in map.locs
		map.locs[k].inf=Dict{Int,AbstractFloat}(1=>0,2=>0,3=>0)
	end
	return map
end
function sprinf!(map,x,y,c,ir=6) #spread influence
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
#if (x,y)==(0,-1) && i==2;println(map.locs[ladj],' ',c);end
						if map.locs[ladj].col==0 || map.locs[ladj].col==c 
							push!(nfringe,ladj)
						end
						push!(visited,ladj)
					end 
				end
			end
#if (x,y)==(0,-1) && i==2;println(nfringe);end
			if length(nfringe)==0
				break
			end
			fringe=nfringe
		end
	end
	return map
end
function sprinfall!(map)
	resetinf!(map)
	for mov in map.moves
		sprinf!(map,mov[1][1],mov[1][2],mov[2],map.ir)
	end
	return map
end
function place!(map,x,y,c)
	if x==y==0 && map.locs[(0,0)].col!=0
		return map #"pass"
	end
	if map.locs[x,y].col!=0
		error("($x,$y) is occupied.")
	end
	push!(map.moves,[(x,y),c])
	map.locs[x,y].hex=HC(x,y)	
	map.locs[x,y].col=c
	#sprinf!(map,x,y,c,ir)
	sprinfall!(map)
	return map
end
#place!(map,xy,c)=place!(map,xy[1],xy[2],c)
function place!(map,xysc::Array)
	for xyc in xysc
		place!(map,xyc[1][1],xyc[1][2],xyc[2])
	end
	return map
end
function to_l(mstr)
	ms=split(mstr,',')
	return (parse(Int,ms[1]),parse(Int,ms[2]))
end
function to_a(movestr,coldic=Dict("-1"=>-1, "1"=>1, "2"=>2, "3"=>3, "#909"=>-1, "#f00"=>1, "#0f0"=>2, "#00f"=>3))
	a=Any[]
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
function makemap(movestr::AbstractString,r=6,ir=6,rc=false)
	map=makemap(r,ir,rc)
	place!(map,to_a(movestr))
	return map
end
import Base.max
function max(d::Dict)
	k=Int[]
	m=-Inf
	for (key,val) in d
		if val==m && val!=0
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
	if l.col!=0 && !in(l.col,maxinf)
		p+=1
	end
	c=Dict{Int,AbstractFloat}()
	for col in maxinf
		c[col]=p/length(maxinf)
	end
	return c
end
function countmoves(map,col)
	n=0
	for m in map.moves
		if m[2]==col
			n+=1
		end
	end
	return n
end
function score!(map::Map)
	sprinfall!(map)
	s=Dict{Int,AbstractFloat}(1=>0,2=>0,3=>0)
	if isempty(map.moves)
		return s
	end
	for (key,val) in map.locs
		for (c,p) in points(val)
			s[c]+=p
		end
	end
	for (key,val) in s
		s[key]-=countmoves(map,key)
	end
	map.score=s
	return s
end

function relinf(inf::Dict,col) #relative influence
	cinf=inf[col]
	minf=0
	for (k,v) in inf
		if k!=col && v>minf
			minf=v
		end
	end
	return cinf-minf
end

