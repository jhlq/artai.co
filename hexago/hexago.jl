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
function makemap(radius=6,ir=6,removecenter::Bool=true)
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
	if x==y==0
		return map #"pass"
	end
	if map.locs[x,y].col!=0
		error("($x,$y) is occupied.")
	end
	push!(map.moves,[(x,y),c])
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
function to_a(movestr,coldic=Dict("-1"=>-1, "1"=>1, "2"=>2, "3"=>3, "#909"=>-1, "#f00"=>1, "#0f0"=>2, "#00f"=>3))
println(movestr)
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
function makemap(movestr::AbstractString,r=6,ir=6,rc=true)
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
abstract AI
type FirstAI<:AI
	net
	bias
	col::Int
	wins
end
FirstAI(nn=5,col::Int=1)=AI(rand(nn,nn)-0.5,rand(nn)-0.5,col,0)
#AI()=AI(1)
type DerAI<:AI
	net
	bias
	wins
end
function getdata(ai::DerAI)
end
type NewAI<:AI
	net
	bias
	wins
	games #played	
end
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
function sanity(ai::NewAI)
	pos=sum(ask(ai,[0,1000]))
	neg=sum(ask(ai,[0,-1000]))
#	zer=(sum(ask(ai,[0.001,1000]))+sum(ask(ai,[-0.001,1000])))/2
	if pos>neg #zer>pos && zer>neg
		return true
	end
	false
end
function makesane(tai::Type{NewAI},nn=5,bias=0)
	ai=NewAI(rand(nn,nn)-0.5,bias,0,0)
	while !sanity(ai)
		ai=NewAI(rand(nn,nn)-0.5,bias,0,0)
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
		#data=getdata(ai,l,map)
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
			relinfmove=relinf(map.locs[mov[1]].inf,ai.col)
			for hex in ring(HC(mov[1]...),1)
				if haskey(map.locs,(hex.x,hex.y))
					l=map.locs[hex.x,hex.y]
					if l.col==0
						data=relinf(l.inf,ai.col)-relinfmove
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
function relscore!(map::Map,col::Int)
	s=score!(map)
	s[col]-s[(col+1)%3]-s[(col+2)%3]
end
function letAIplay!(map::Map,ai::NewAI,col::Int,scoreeveryround=true)
	move=(0,0)
	likest=-1000 #most liked
	ms=score!(map)[col]
	for li in 0:length(map.moves)
		if li==0 || map.moves[li][2]==col
			center=li==0?HC(0,0):HC(map.moves[li][1]...)
			ceinf=relinf(map.locs[center.x,center.y].inf,col)
			for dir in 1:6
				hex=neighbor(center,dir)
				if haskey(map.locs,(hex.x,hex.y))
					l=map.locs[hex.x,hex.y]
					if l.col!=0
						continue
					end
					data=[relinf(l.inf,col)-ceinf]
					if scoreeveryround
						push!(map.moves,[(hex.x,hex.y),col])
						ns=score!(map)[col]
#println(ms,ns)
						push!(data,(ns-ms)/100)
						pop!(map.moves)
						if ns<ms
							continue
						end
					else
						push!(data,0)
					end
#println(data)
					r=ask(ai,data)
#println(r)
					rt=sum(r)+r[end]
					if rt>likest
						likest=rt
						move=(hex.x,hex.y)
					end
				end
			end
		end
	end
	place!(map,move[1],move[2],col)
	return move
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
	#ai1.col=1
	#ai2.col=2
	for nm in 1:nmoves
		letAIplay!(map,ai1,1)
		letAIplay!(map,ai2,2)
	end
	return map
end
function makeAIs(nn::Int,nais::Int)
	ais=AI[]
	for n in 1:nais
		push!(ais,makesaneAI(nn))
	end
	return ais
end
function make(TAI::Type,nn::Int,nais::Int)
	ais=TAI[]
	for n in 1:nais
		push!(ais,makesane(TAI,nn))
	end
	return ais
end
function tournament!(ais,nmoves::Int)
	for ai1 in ais
		for ai2 in ais
			if ai1!=ai2
				m=match(ai1,ai2,nmoves)
				s=score!(m)
				#println(s[1]," ",s[2]," ",max(s)," ",to_s(m))
				for c in max(s)
					[ai1,ai2][c].wins+=1
				end
				ai1.games+=1
				ai2.games+=1
			end
		end
	end
	return ais
end
function tournament(ais,nmoves::Int)
	lai=length(ais)
	wins=zeros(lai)
	for aii in 1:lai
		#w=0
		ai1=ais[aii]
		for aii2 in 1:lai
			ai2=ais[aii2]
			if aii!=aii2
				m=match(ai1,ai2,nmoves)
				s=score!(m)
				#println(s[1]," ",s[2]," ",max(s)," ",to_s(m))
				for c in max(s)
					wins[[aii,aii2][c]]+=1
				end
			end
		end
		#wins[aii]=w
	end
	return wins
end
function tournaments(ntou::Int,nais::Int,nn::Int,nmoves::Int,TAI::Type=NewAI)
	winners=AI[]
	for tou in 1:ntou
		print(tou,' ')
		ais=make(TAI,nn,nais)
		tournament!(ais,nmoves)
		push!(winners,sort(ais)[end])
	end
	return winners
end
import Base.isless
isless(ai1::AI,ai2::AI)=isless(ai1.wins,ai2.wins)
max(ais::Array{AI})=sort(ais)[end]
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
function save(net,filename)
	if ispath(filename)
		error("File $filename exists.")
	end
	sn=open(filename,"w") 
	h,w=size(net)
	for hi in 1:h
		for wi in 1:w
			write(sn,"$(net[hi,wi])")
			if wi!=w
				write(sn,' ')
			end
		end
		if hi!=h
			write(sn,'\n')
		end
	end
	close(sn)
end
load(filename)=readdlm(filename,' ')

function addneuron(net)
	n=size(net,1)
	nnet=zeros(n+1,n+1)
	nnet[1,1]=net[1,1]
	nnet[1,3:end]=net[1,2:end]
	nnet[3:end,1]=net[2:end,1]
	nnet[3:end,3:end]=net[2:end,2:end]
	return nnet
end
function addneuron!(ai::AI)
	ai.net=addneuron(ai.net)
	return ai
end
function addneuron(ai::AI)
	nai=deepcopy(ai)
	return addneuron!(nai)
end
function mutateneuron!(net,tn=2,damp1=1,damp2=1)
	n=size(net,1)
	m1=(rand(n)-0.5).*damp1;m2=(rand(n)-0.5).*damp2
	net[tn,:]+=m1'
	net[:,tn]+=m2
	return net
end
type Mutator
	filter
	biasadder
end
function makemutatormutating(neuron::Int=2,nn::Int=5,biasadderdamp=0)
	f=zeros(nn,nn)
	for i in 1:nn
		f[neuron,i]=rand()
		f[i,neuron]=rand()
	end
	return Mutator(f,rand(nn)*biasadderdamp)
end
function mutate!(ai::AI,mut=0)
	if mut == 0
		mut=ai.mutator
	end
	nn=size(ai.net)[1]
	ai.net+=rand(nn,nn).*mut.filter
	ai.bias+=rand(nn).*mut.biasadder
	return ai
end
function clones(ai::AI,mut::Mutator,nc::Int)
	clo=AI[]
	for n in 1:nc
		c=deepcopy(ai)
		c.mutator=mut
		mutate!(c)
		push!(clo,c)
	end
	return clo
end
type MutAI<:AI
	net
	bias
	wins
	games
	mutator
end

function makesane(::Type{MutAI})
	orig=load("tournamentw3vsw5winner.ain")
	norig=addneuron(orig)
	nnorig=addneuron(norig)
	nnorig[3,3]=1
	nnorig[end,3]=1
	return MutAI(nnorig,0,0,0,0)
end
function wins(ais::Array)
	s=0
	for ai in ais
		s+=ai.wins
	end
	return s
end
function mutsetup(nclones::Int=33)
	ai=makesane(MutAI)
	mut1=makemutatormutating()
	mut2=makemutatormutating(2,5,0.3)
	mut3=makemutatormutating(2,5,0.5)
	muts=[mut1,mut2,mut3]
	ais=[ai]
	for mut in muts
		cs=clones(ai,mut1,nclones)
		for c in cs
			push!(ais,c)
		end
	end
	return ais
end
function mutinal(ais,nmoves)
	nais=deepcopy(ais)
	for nai in nais
		nai.wins=0
		nai.games=0
	end
	tournament!(nais,nmoves)
	sort!(nais)
	return nais
end
function pushall!(a1::Array,a2::Array)
	for a in a2
		push!(a1,a)
	end
	a1
end
function mutaments(nments::Int,nclones::Int=3,nmoves::Int=15)
	ws=AI[]
	ow=0
	b0w=0
	b3w=0
	b1w=0
	for n in 1:nments
		print(n,' ')
		ais=mutsetup(nclones)
		tournament!(ais,9)
		ow+=ais[1].wins
		b0w+=wins(ais[2:nclones+1])/nclones
		b3w+=wins(ais[nclones+2:2*nclones+1])/nclones
		b1w+=wins(ais[2*nclones+2:end])/nclones
		pushall!(ws,winners(ais))
	end
	return ws,[ow,b0w,b3w,b1w]
end
function letAIplay!(map::Map,ai::MutAI,col::Int,scoreeveryround=true)
	move=(0,0)
	likest=-1000 #most liked
	ms=score!(map)[col]
	for li in 0:length(map.moves)
		if li==0 || map.moves[li][2]==col
			center=li==0?HC(0,0):HC(map.moves[li][1]...)
			ceinf=relinf(map.locs[center.x,center.y].inf,col)
			for dir in 1:6
				hex=neighbor(center,dir)
				if haskey(map.locs,(hex.x,hex.y))
					l=map.locs[hex.x,hex.y]
					if l.col!=0
						continue
					end
					ri=relinf(l.inf,col)
					data=[ri,ri-ceinf]
					if scoreeveryround
						push!(map.moves,[(hex.x,hex.y),col])
						ns=score!(map)[col]
						push!(data,(ns-ms)/100)
						pop!(map.moves)
						if ns<ms
							continue
						end
					else
						push!(data,0)
					end
					r=ask(ai,data)
					rt=sum(r)+r[end]
					if rt>likest
						likest=rt
						move=(hex.x,hex.y)
					end
				end
			end
		end
	end
	place!(map,move[1],move[2],col)
	return move
end
