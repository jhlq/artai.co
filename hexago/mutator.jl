include("ai.jl")
function rindmat(mat::Matrix)
	s=sum(mat)
	r=rand()*s
	ts=0
	d=size(mat)
	for i in 1:d[1]
		for j in 1:d[2]
			ts+=mat[i,j]
			if ts>=r
				return (i,j)
			end
		end
	end
end
function rindvec(vec::Vector)
	s=sum(vec)
	r=rand()*s
	ts=0
	d=length(vec)
	for i in 1:d
		ts+=vec[i]
		if ts>=r
			return i
		end
	end
end

#mutator rindmat nmutmat
#make 100 random nets, mutate one
type Mut
	rindmat
	nmutvec
end
Mut()=Mut(ones(3,3),ones(3))
function mutate(ai::AI,m::Mut,damp=1)
	dai=deepcopy(ai)
	s=onevsall(dai,sampleais,9)
	nmuts=rindvec(m.nmutvec)
	muts=Tuple[]
	for mut in 1:nmuts
		muti=rindmat(m.rindmat)
		push!(muts,muti)
		dai.net[muti...]+=(rand()-0.5)/damp
		
	end
	ns=onevsall(dai,sampleais,9)
	if ns>s
		m.nmutvec[nmuts]*=2
		for n in 1:nmuts
			m.rindmat[muts[n]...]*=2
		end
		return dai
	else
		m.nmutvec[nmuts]*=0.5
		for n in 1:nmuts
			m.rindmat[muts[n]...]*=0.5
		end
		return false
	end		
end
type MAI<:AI
	net
	bias
	wins
	games #played	
	points
	#rank
end
function letAIplay!(map::Map,ai::MAI,col::Int)
	move=(0,0)
	likest=-1000 #most liked
	for li in 0:length(map.moves)
		if li==0 || map.moves[li][2]==col
			center=li==0?HC(0,0):HC(map.moves[li][1]...)
			#ceinf=relinf(map.locs[center.x,center.y].inf,col)
			for dir in 1:6
				hex=neighbor(center,dir)
				if haskey(map.locs,(hex.x,hex.y))
					l=map.locs[hex.x,hex.y]
					if l.col!=0
						continue
					end
					data=[relinf(l.inf,col)]#-ceinf]
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
function makeais(nais,nn=3)
	ais=MAI[]
	for i in 1:nais
		push!(ais,MAI(rand(nn,nn)-0.5,0,0,0,0))
	end
	return ais
end
sampleais=makeais(99)

function onevsall(ai,ais,nmoves::Int)
	p=0
	for aia in ais
		m=match(ai,aia,nmoves)
		s=score!(m)
		p+=s[1]
		m=match(aia,ai,nmoves)
		s=score!(m)
		p+=s[2]
	end
	return p
end
