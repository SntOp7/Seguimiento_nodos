defmodule Main do
  def calcular_precio_secuencial(lista) do
    Enum.map(lista, fn p ->
      {p.nombre, calcular_precio(p)}
    end)
  end

  def calcular_precio(%Producto{precio_sin_iva: precio_sin_iva, iva: iva}) do
    precio_sin_iva * (1 + iva)
  end

  def calcular_precio_concurrencia(lista) do
    Enum.map(lista, fn p -> Task.async(fn -> {p.nombre, calcular_precio(p)}
      end)
    end)
    |> Enum.map(&Task.await/1)
  end

  def run_benchmark(lista) do
    tiempo_concurrencia = Benchmark.determinar_tiempo_ejecucion({__MODULE__, :calcular_precio_concurrencia, [lista]})
    IO.puts("Tiempo concurrencia: #{inspect(tiempo_concurrencia)}")
    tiempo_secuencial = Benchmark.determinar_tiempo_ejecucion({__MODULE__, :calcular_precio_secuencial, [lista]})
    IO.puts("Tiempo secuencial: #{inspect(tiempo_secuencial)}")
    speedup = Benchmark.calcular_speedup(tiempo_concurrencia, tiempo_secuencial)
    IO.puts("Speedup: #{inspect(speedup)}")
  end


end

lista =
  for i <- 1..50_000 do
    %Producto{
      nombre: "Producto#{i}",
      stock: 10,
      precio_sin_iva: 1000.0 + i,
      iva: 0.19
    }
  end

Main.calcular_precio_secuencial(lista)
Main.calcular_precio_concurrencia(lista)
Main.run_benchmark(lista)
