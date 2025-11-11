defmodule Main do
  def aplicar_descuentos_secuencial(carritos) do
    Enum.map(carritos, fn c -> aplicar_descuento(c) end)
  end

  def aplicar_descuentos_concurrencia(carritos) do
    Enum.map(carritos, fn c ->
      Task.async(fn -> aplicar_descuento(c) end)
    end)
    |> Enum.map(&Task.await/1)
  end

  def aplicar_descuento(%Carrito{id: id,items: items, cupon: cupon}) do
    total_con_descuento =
      Enum.reduce(items, 0.0, fn %Item{precio: precio}, acc ->
        acc + aplicar_cupon(precio, cupon)
      end)
      {id, total_con_descuento}
  end

  def aplicar_cupon(precio, nil), do: precio
  def aplicar_cupon(precio, %{id: _id, porcentaje: porcentaje}) do
    precio * (1 - porcentaje / 100)
  end

  def run_benchmark(carritos) do
    tiempo_concurrencia = Benchmark.determinar_tiempo_ejecucion({__MODULE__, :aplicar_descuentos_concurrencia, [carritos]})
    IO.puts("Tiempo concurrencia: #{inspect(tiempo_concurrencia)}")
    tiempo_secuencial = Benchmark.determinar_tiempo_ejecucion({__MODULE__, :aplicar_descuentos_secuencial, [carritos]})
    IO.puts("Tiempo secuencial: #{inspect(tiempo_secuencial)}")
    speedup = Benchmark.calcular_speedup(tiempo_concurrencia, tiempo_secuencial)
    IO.puts("Speedup: #{inspect(speedup)}")
  end
end

cupon1 = %Cupon{id: "CUPON10", porcentaje: 10}
cupon2 = %Cupon{id: "CUPON20", porcentaje: 20}
item1 = %Item{id: "1", nombre: "Item1", precio: 100.0}
item2 = %Item{id: "2", nombre: "Item2", precio: 200.0}
item3 = %Item{id: "3", nombre: "Item3", precio: 300.0}
item4 = %Item{id: "4", nombre: "Item4", precio: 400.0}

carritos = [
  %Carrito{id: "C1", items: [item1, item2], cupon: cupon1},
  %Carrito{id: "C2", items: [item3, item4], cupon: cupon2}
]

Main.aplicar_descuentos_secuencial(carritos)
Main.aplicar_descuentos_concurrencia(carritos)
Main.run_benchmark(carritos)
