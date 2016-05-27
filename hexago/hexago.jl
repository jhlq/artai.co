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
function sprinfall!(map,ir=6)
	resetinf!(map)
	for mov in map.moves
		sprinf!(map,mov[1][1],mov[1][2],mov[2],ir)
	end
	return map
end
function place!(map,x,y,c)
	push!(map.moves,[(x,y),c])
	if x==y==0
		return "pass"
	end
	if map.locs[x,y].col!=0
		error("($x,$y) is occupied.")
	end
	map.locs[x,y].hex=HC(x,y)	
	map.locs[x,y].col=c
	#sprinf!(map,x,y,c,ir)
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
function score(map::Map,ir=6)
	sprinfall!(map,ir)
	s=Dict{Int,AbstractFloat}(1=>0,2=>0,3=>0)
	for (key,val) in map.locs
		for (c,p) in points(val)
			s[c]+=p
		end
	end
	for (key,val) in s
		s[key]-=countmoves(map,key)
	end
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
type AI
	net
	bias
	col::Int
	wins
end
AI(nn=5,col::Int=1)=AI(rand(nn,nn)-0.5,rand(nn)-0.5,col,0)
#AI()=AI(1)
ask(ai::AI,data::Number)=ask(ai::AI,[data])
function ask(ai::AI,data::Array)
	nn=size(ai.net)[1]
	exc=zeros(nn)
	for di in 1:length(data)
		exc[di]=data[di]
	end
	answer=AbstractFloat[]
	for n in 1:nn
		exc=tanh(ai.net*(exc+ai.bias))
		push!(answer,exc[end])
	end
	return answer
end
function sanity(ai::AI)
	pos=sum(ask(ai,[1000]))
	neg=sum(ask(ai,[-1000]))
	zer=sum(ask(ai,[0]))
	if zer>pos && zer>neg
		return true
	end
	false
end
function makesaneAI(nn=5,col=1)
	ai=AI(nn,col)
	while !sanity(ai)
		ai=AI(nn,col)
	end
	ai
end
function letAIplay(map::Map,ai::AI)
#opening evaluate whole board -> decide on segment
	cornerscores=Array[]
	move=(0,0)
	likest=-1000 #most liked
	for corneri in 1:6
		cr=round(Int,map.r/2)
		cornercenter=neighbor(HC(0,0),corneri,cr)
		l=map.locs[cornercenter.x,cornercenter.y]
		if l.col!=0
			continue
		end
		sprinfall!(map)
		data=relinf(l.inf,ai.col)
#println(data)
		r=ask(ai,data)
		push!(cornerscores,r)
		if sum(r)>likest
			likest=sum(r)
			move=(cornercenter.x,cornercenter.y)
		end
#		for hex in ring(cornercenter,cr)
#			l=map[hex.x,hex.y]
#			data=relinf(l.inf,ai.col)
#		end
	end
	for mov in map.moves
		if mov[2]==ai.col
			for hex in ring(HC(mov[1]...),1)
				if haskey(map.locs,(hex.x,hex.y))
					l=map.locs[hex.x,hex.y]
					if l.col==0
						data=relinf(l.inf,ai.col)
						r=ask(ai,data)
						if sum(r)>likest
							likest=sum(r)
							move=(hex.x,hex.y)
						end
					end
				end
			end
		end
	end
	place!(map,move[1],move[2],ai.col)
	return move,cornerscores
	#check relative influence
	#give value to each section, pick one by random from 1:v1:v2:v3...
	#r->AI->ring to put
#later evaluate move to expand from
	#determine expansion length
	#up or down?
#inspect connections

end

function match(ai1::AI,ai2::AI,nmoves::Int)
	map=makemap()
	ai1.col=1
	ai2.col=2
	for nm in 1:nmoves
		letAIplay(map,ai1)
		letAIplay(map,ai2)
	end
	return map
end
function makeAIs(nais::Int)
	ais=AI[]
	for n in 1:nais
		push!(ais,makesaneAI())
	end
	return ais
end
function tournament!(ais,nmoves::Int)
	for ai1 in ais
		for ai2 in ais
			if ai1!=ai2
				m=match(ai1,ai2,nmoves)
				s=score(m)
				#println(s[1]," ",s[2]," ",max(s)," ",to_s(m))
				for c in max(s)
					[ai1,ai2][c].wins+=1
				end
			end
		end
	end
	return ais
end
import Base.isless
isless(ai1::AI,ai2::AI)=isless(ai1.wins,ai2.wins)
function winners(ais)
	ws=AI[]
	mw=0
	for ai in ais
		if ai.wins>mw
			ws=[ai]
			mw=ai.wins
		elseif ai.wins==mw
			push!(ws,ai)
		end
	end
	return ws
end
