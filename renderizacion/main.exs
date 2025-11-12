defmodule Main do
  def render_secuencial(plantillas) do
    Enum.map(plantillas, fn p ->
      render(p)
    end)
  end

  def render_concurrente(plantillas) do
    Enum.map(plantillas, fn p ->
      Task.async(fn -> render(p) end)
    end)
    |> Enum.map(&Task.await/1)
  end

  def render(%Plantilla{id: id, nombre: template, vars: vars}) do
    html =
      Enum.reduce(vars, template, fn {key, value}, acc ->
        placeholder = "{{#{key}}}"
        String.replace(acc, placeholder, to_string(value))
      end)
    {id, html}
  end

  def run_benchmark(lista) do
    tiempo_concurrencia =
      Benchmark.determinar_tiempo_ejecucion({__MODULE__, :render_secuencial, [lista]})

    IO.puts("Tiempo concurrencia: #{inspect(tiempo_concurrencia)}")

    tiempo_secuencial =
      Benchmark.determinar_tiempo_ejecucion({__MODULE__, :render_concurrente, [lista]})

    IO.puts("Tiempo secuencial: #{inspect(tiempo_secuencial)}")
    speedup = Benchmark.calcular_speedup(tiempo_concurrencia, tiempo_secuencial)
    IO.puts("Speedup: #{inspect(speedup)}")
  end
end

plantillas = [%Plantilla{id: 1, nombre: "Hola {{nombre}}, tengo {{edad}} años. Bienvenido a {{ciudad}}!", vars: %{nombre: "Alice", edad: 30, ciudad: "Wonderland"}},
              %Plantilla{id: 2, nombre: "Hola {{nombre}}, tengo {{edad}} años. Vivo en {{departamento}}!", vars: %{nombre: "Bob", edad: 25, departamento: "Antioquia"}},
              %Plantilla{id: 3, nombre: "Hola {{nombre}}, tengo {{edad}} años. Bienvenido a {{ciudad}}!", vars: %{nombre: "Diana", edad: 28, ciudad: "Dollland"}},
              %Plantilla{id: 4, nombre: "Hola {{nombre}}, tengo {{edad}} años. Estoy en {{materia}}!", vars: %{nombre: "Charlie", edad: 35, materia: "Matemáticas"}},
              %Plantilla{id: 5, nombre: "Hola {{nombre}}, tengo {{edad}} años. Bienvenido a {{ciudad}}!", vars: %{nombre: "Eve", edad: 22, ciudad: "Eland"}}]

IO.inspect(Main.render_secuencial(plantillas))
IO.inspect(Main.render_concurrente(plantillas))
Main.run_benchmark(plantillas)
