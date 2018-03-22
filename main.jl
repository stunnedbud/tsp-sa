include("./run.jl")
using Run

function main()
    if length(ARGS) < 1 
        println("Error: No se especificó el archivo de settings en la linea de comandos. El programa terminará.")
        return 0
    end
    Run.run(ARGS[1])
end

main()
