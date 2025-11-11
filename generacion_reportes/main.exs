defmodule Main do
  def generar_resumen(sucursales) do
    Enum.map(sucursales, fn sucursal ->
      generar_resumen_sucursal(sucursal)
    end)
  end

  def generar_resumen_sucursal(s) do
    total_ventas = Enum.reduce(s.ventas_diarias, 0, fn venta, acc -> acc + venta.monto end)

    %{
      nombre_sucursal: s.id,
      total_ventas: total_ventas,
      cantidad_ventas: length(s.ventas_diarias)
    }
  end

  def generar_resumen_concurrencia(sucursales) do
    Enum.map(sucursales, fn sucursal ->
      Task.async(fn -> generar_resumen_sucursal(sucursal) end)
    end)
    |> Enum.map(&Task.await/1)
  end

  def run_benchmark(sucursales) do
    tiempo_concurrencia =
      Benchmark.determinar_tiempo_ejecucion(
        {__MODULE__, :generar_resumen_concurrencia, [sucursales]}
      )

    IO.puts("Tiempo concurrencia: #{inspect(tiempo_concurrencia)}")

    tiempo_secuencial =
      Benchmark.determinar_tiempo_ejecucion({__MODULE__, :generar_resumen, [sucursales]})

    IO.puts("Tiempo secuencial: #{inspect(tiempo_secuencial)}")
    speedup = Benchmark.calcular_speedup(tiempo_concurrencia, tiempo_secuencial)
    IO.puts("Speedup: #{inspect(speedup)}")
  end
end

venta1 = %Venta{id: 1, monto: 500}
venta2 = %Venta{id: 2, monto: 750}
venta3 = %Venta{id: 3, monto: 300}
venta4 = %Venta{id: 4, monto: 450}
venta5 = %Venta{id: 5, monto: 600}

sucursales = [
  %Sucursal{
    id: "Sucursal A",
    ventas_diarias: [venta1, venta2]
  },
  %Sucursal{
    id: "Sucursal B",
    ventas_diarias: [venta3]
  },
  %Sucursal{
    id: "Sucursal C",
    ventas_diarias: [venta4, venta5]
  }
]

Main.generar_resumen(sucursales)
Main.generar_resumen_concurrencia(sucursales)
Main.run_benchmark(sucursales)
