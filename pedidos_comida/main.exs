defmodule Main do
  def preparar_orden_secuencial(ordenes) do
    Enum.map(ordenes, fn o ->
      preparar(o)
    end)
  end

  def preparar(%Orden{prep_ms: prep_ms}) do
    :timer.sleep(prep_ms)
  end

  def preparar_orden_concurrencia(ordenes) do
    Enum.map(ordenes, fn o ->
      Task.async(fn -> preparar(o) end)
    end)
    |> Enum.map(&Task.await/1)
  end

  def run_benchmark(lista) do
    tiempo_concurrencia = Benchmark.determinar_tiempo_ejecucion({__MODULE__, :preparar_orden_concurrencia, [lista]})
    IO.puts("Tiempo concurrencia: #{inspect(tiempo_concurrencia)}")
    tiempo_secuencial = Benchmark.determinar_tiempo_ejecucion({__MODULE__, :preparar_orden_secuencial, [lista]})
    IO.puts("Tiempo secuencial: #{inspect(tiempo_secuencial)}")
    speedup = Benchmark.calcular_speedup(tiempo_concurrencia, tiempo_secuencial)
    IO.puts("Speedup: #{inspect(speedup)}")
  end

end

ordenes = [%Orden{id: 1, item: "Pizza", prep_ms: 2000},
           %Orden{id: 2, item: "Sushi", prep_ms: 1500},
           %Orden{id: 3, item: "Burger", prep_ms: 1000}]

Main.preparar_orden_secuencial(ordenes)
Main.preparar_orden_concurrencia(ordenes)
Main.run_benchmark(ordenes)
