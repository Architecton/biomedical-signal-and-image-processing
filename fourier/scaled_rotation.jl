using MAT

# Perform rotation around unit circle with radial frequency omega.
function rotation(omega, t)
    return exp(-1im*omega*t)
end

# Perform scaled rotation around unit circle with radial frequency omega.
# The rotation is scaled with function of time f.
function scaled_rotation(omega, t, f)
    return f(t)*exp(-1im*omega*t)
end

# Time domain values.
t = collect(0:0.01:10)

# Rotation as a function of time 
res1 = rotation.(2*pi, t)
data1 = hcat(real.(res1), imag.(res1))

res2 = scaled_rotation.(2*pi, t, (t) -> sin(1.9*pi*t))
data2 = hcat(real.(res2), imag.(res2))

f = matopen("rotation_data.mat", "w")
write(f, "data", data2)
close(f)

