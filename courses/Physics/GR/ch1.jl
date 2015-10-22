eq1=@equ s^2=Δx^2+Δy^2
eq2=@equ s^2=Δx´^2+Δy´^2
eq3=@equ s^2=-(c*Δt)^2+Δx^2+Δy^2+Δz^2
eq4=@equ s^2=-(c*Δt´)^2+Δx´^2+Δy´^2+Δz´^2
eq5=@equ xμ=Tensor([c*t,x,y,z],μ,0,1)
eq6=@equ c=1
eq7=@equ xi=Tensor([x,y,z],i,0,1)
eq8=@equ ημν=Tensor(diagm([-1,1,1,1]),0,[μ,ν],2)
eq9=@equ s^2=ημν*Δxμ*Δxν
eq10=@equ xμ´=xμ+aμ
eq11=@equ xμ´=Tensor(Λ,μ´,ν,2)*Tensor([c*t,x,y,z],ν,0,1)
eq12=@equ x´=Λ*x
eq13=@equ Transpose(Δx)*η*Δx=Transpose(Δx)*Transpose(Λ)*η*Λ*Δx
eq14=@equ η=Transpose(Λ)*η*Λ
eq15=@equ Tensor(η,0,[ρ,σ],2)=Tensor(Λ,μ´,ρ,2)*Tensor(Λ,ν´,σ,2)*Tensor(η,0,[μ´,ν´],2)
eq16=@equ Tensor(eye(3))=Transpose(R)*Tensor(eye(3))*R
eq17=@equ Tensor(Λ,μ´,ν,2)=Tensor([1 0 0 0;0 cos(θ) sin(θ) 0;0 -sin(θ) cos(θ) 0;0 0 0 1])
eq18=@equ Tensor(Λ,μ´,ν,2)=Tensor([cosh(ϕ) -sinh(ϕ) 0 0;-sinh(ϕ) cosh(ϕ) 0 0;0 0 1 0;0 0 0 1])

