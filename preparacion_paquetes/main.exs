defmodule Main do
  def empacar_pedido(paquete) do
    :timer.sleep(10)  # Simula tiempo de ETIQUETAR
    {:ok, "Pedido #{paquete.id} empacado"}
    :timer.sleep(10)  # Simula tiempo de EMPAQUETAR
    {:ok, "Pedido #{paquete.id} empacado"}
    if paquete.fraji? do
      :timer.sleep(10)  # Simula tiempo de EMBALAR un frajil
      {:ok, "Pedido #{paquete.id} embalado"}
    else
      :timer.sleep(5)  # Simula tiempo de EMBALAJE normal
      {:ok, "Pedido #{paquete.id} no requiere embalaje"}
    end
  end

  def empacar_pedidos_concurrencia(paquetes) do
    paquetes
    |> Enum.map(fn paquete ->
      Task.async(fn -> empacar_pedido(paquete) end)
    end)
    |> Enum.map(&Task.await/1)
  end

  def empacar_pedidos_secuencial(paquetes) do
    Enum.map(paquetes, fn paquete ->
      empacar_pedido(paquete)
    end)
  end

  def run_benchmark(paquetes) do
    tiempo_concurrencia = Benchmark.determinar_tiempo_ejecucion({__MODULE__, :empacar_pedidos_concurrencia, [paquetes]})
    IO.puts("Tiempo concurrencia: #{inspect(tiempo_concurrencia)}")
    tiempo_secuencial = Benchmark.determinar_tiempo_ejecucion({__MODULE__, :empacar_pedidos_secuencial, [paquetes]})
    IO.puts("Tiempo secuencial: #{inspect(tiempo_secuencial)}")
    speedup = Benchmark.calcular_speedup(tiempo_concurrencia, tiempo_secuencial)
    IO.puts("Speedup: #{inspect(speedup)}")
  end
end

paquetes = [%Paquete{id: "1", peso: 10, fraji?: false},
            %Paquete{id: "2", peso: 5, fraji?: true},
            %Paquete{id: "3", peso: 20, fraji?: false},
            %Paquete{id: "4", peso: 15, fraji?: true},
            %Paquete{id: "5", peso: 8, fraji?: false}]

Main.empacar_pedidos_secuencial(paquetes)
Main.empacar_pedidos_concurrencia(paquetes)
Main.run_benchmark(paquetes)
