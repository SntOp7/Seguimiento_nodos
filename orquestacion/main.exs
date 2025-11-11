defmodule Main do
  def ejecutar_tarea(tarea) do
    case tarea do
      :reindex ->
        :timer.sleep(2000)
        IO.puts("Reindexación completada.")

      :purge_cache ->
        :timer.sleep(1000)
        IO.puts("Caché purgada.")

      :build_sitemap ->
        :timer.sleep(1500)
        IO.puts("Mapa del sitio construido.")
    end
  end

  def ejecutar_tareas_concurrencia(tareas) do
    inicio = :os.system_time(:millisecond)

     Enum.map(tareas, fn tarea ->
      Task.async(fn -> ejecutar_tarea(tarea) end)
    end)
    |> Enum.each(&Task.await/1)

    fin = :os.system_time(:millisecond)
    duracion = fin - inicio

    IO.puts("Tiempo total concurrente: #{duracion} ms")
    duracion
  end

  def ejecutar_tareas_secuencial(tareas) do
    inicio = :os.system_time(:millisecond)
    Enum.each(tareas, fn tarea -> ejecutar_tarea(tarea) end)
    fin = :os.system_time(:millisecond)
    duracion = fin - inicio
    IO.puts("Duración secuencial: #{duracion} ms")
    duracion
  end

  def run_benchmark(tareas) do
    tiempo_concurrencia = ejecutar_tareas_concurrencia(tareas)
    tiempo_secuencial = ejecutar_tareas_secuencial(tareas)
    speedup = Benchmark.calcular_speedup(tiempo_concurrencia, tiempo_secuencial)
    IO.puts("Speedup: #{inspect(speedup)}")
  end
end

tareas = [:reindex, :purge_cache, :build_sitemap]
Main.ejecutar_tareas_concurrencia(tareas)
Main.ejecutar_tareas_secuencial(tareas)
Main.run_benchmark(tareas)
