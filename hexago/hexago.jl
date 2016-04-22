using Hexagons
HC=HexagonCubic
HexagonCubic(x,y)=HC(x,y,-x-y)
+(h1::HC,h2::HC)=HC(h1.x+h2.x,h1.y+h2.y,h1.z+h2.z)
function .+(hca::Array{Hexagons.HexagonCubic,1}, h::Hexagons.HexagonCubic)
	na=HC[]
	for a in hca
		push!(na,a+h)
	end
	return na
end

type Spot
	loc::HC
	has
end
N=2
field=[]
map=Dict{Tuple{Int64,Int64},Spot}()
for dx in -N:N
	for dy in max(-N,-dx-N):min(N,-dx+N)
			dz=-dx-dy
			push!(field,HexagonCubic(dx,dy,dz))
			map[(dx,dy)]=Spot(HC(dx,dy,dz),[])
	end
end

placed=Dict(1=>HC[],2=>HC[],3=>HC[])

function coordify(hca)
	xs=Float64[]
	ys=Float64[]
	for hex in hca
		cor=center(hex)
		push!(xs,cor[1])
		push!(ys,cor[2])
	end
	return xs,ys
end

function place(x::Integer,y::Integer,p=1)
	s=p==1?"*":p==2?"+":"x"
	h=HC(x,y,-x-y)
	loc=center(h)
	scatter([loc[1]],[loc[2]],s)
end
function place(hca::Array{HC},pa::Array)
	for i in 1:length(hca)-1
		place(hca[i].x,hca[i].y,pa[i])
	end
	place(hca[end].x,hca[end].y,pa[end])
end
function place(cora::Array{Tuple{Int64,Int64},1},pa::Array)
	for i in 1:length(cora)-1
		place(cora[i][1],cora[i][2],pa[i])
	end
	place(cora[end][1],cora[end][2],pa[end])
end
function oddtocubic(plays)
	plarr=split(plays,';')[1:end-1]
	hca=HC[]
	pa=Int64[]
	for pl in plarr
		p=split(pl,':')
		player=parse(Int,p[1])
		loc=split(p[2],',')
		col=parse(Int,loc[1])-10
		row=parse(Int,loc[2])-10
		#println(col,row)
		x = col
		z = row - (col - (col&1)) / 2
		y = -x-z
		push!(hca,HC(x,y,z))
		push!(pa,player)
	end
	hca,pa
end
function clear()
	hold(false)
	scatter(coordify(field)...)
	hold(true)
end
directions = [
   HC(+1, -1,  0), HC(+1,  0, -1), HC( 0, +1, -1),
   HC(-1, +1,  0), HC(-1,  0, +1), HC( 0, -1, +1)
]
function painter(map,origin)
	paint=HC[]
	fringe=HC[origin]
	visited=HC[]
	newfringe=HC[]
	while !isempty(fringe)
		for h in fringe
			if !in(h,visited) && haskey(map,(h.x,h.y)) && isempty(map[(h.x,h.y)].has)
				adj=directions.+h
				for a in adj
					if !in(a,newfringe) && !in(a,visited)
						push!(newfringe,a)
					end
				end
				push!(paint,h)
			end
			push!(visited,h)
		end
		fringe=newfringe
		newfringe=HC[]
		#println(paint)
	end	
	return paint
end
#=
xs,ys=coordify(field)
scatter(xs,ys)
using Winston;scatter(coordify(field)...);hold()

plays="0:10,10;1:11,9;0:12,9;"
plarr=split(plays,';')[1:end-1]
p1=split(plarr[1],':')
player=parse(Int,p1[1])
loc=split(p1[2],',')
x1=parse(Int,loc[1])
y1=parse(Int,loc[2])

plays="0:9,9;1:8,9;0:8,8;"
hca,pa=oddtocubic(plays)
place(hca,pa)

line=[(2,-1),(1,-1),(0,-1),(-1,-1)]
for l in line
	push!(map[l].has,1)
end

=#
