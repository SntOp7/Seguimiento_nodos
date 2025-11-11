defmodule Main do
  @palabras_prohibidas ["tonto", "idiota", "spam", "odio"]

  def moderar(%Comentario{id: id, texto: texto}) do
    :timer.sleep(Enum.random(5..12))
    texto = String.downcase(texto)

    cond do
      Enum.any?(@palabras_prohibidas, &String.contains?(texto, &1)) ->
        {id, :rechazado}

      String.length(texto) < 10 ->
        {id, :rechazado}

      String.contains?(texto, ["http", "www"]) ->
        {id, :rechazado}

      true ->
        {id, :aprobado}
    end
  end

  def moderar_concurrente(comentarios) do
    inicio = :os.system_time(:millisecond)

    resultados =
      comentarios
      |> Enum.map(fn c -> Task.async(fn -> moderar(c) end) end)
      |> Enum.map(&Task.await(&1, 100))

    fin = :os.system_time(:millisecond)
    duracion = fin - inicio

    IO.puts("Tiempo concurrente: #{duracion} ms")
    {resultados, duracion}
  end

  def moderar_secuencial(comentarios) do
    inicio = :os.system_time(:millisecond)

    resultados =
      Enum.map(comentarios, fn c -> moderar(c) end)

    fin = :os.system_time(:millisecond)
    duracion = fin - inicio

    IO.puts("Tiempo secuencial: #{duracion} ms")
    {resultados, duracion}
  end

  def run_benchmark(comentarios) do
    {_resultados_concurrentes, duracion_concurrente} = moderar_concurrente(comentarios)
    {_resultados_secuenciales, duracion_secuencial} = moderar_secuencial(comentarios)

    speedup = Benchmark.calcular_speedup(duracion_concurrente, duracion_secuencial)
    IO.puts("Speedup: #{inspect(speedup)}")
  end
end

comentarios = [
  %Comentario{id: 1, texto: "Excelente servicio, muy recomendado!"},
  %Comentario{id: 2, texto: "Odio este producto"},
  %Comentario{id: 3, texto: "Visita mi web http://spam.com"},
  %Comentario{id: 4, texto: "Muy bueno, funciona perfecto"},
  %Comentario{id: 5, texto: "Malo"}
]

Main.moderar_concurrente(comentarios)
Main.moderar_secuencial(comentarios)
Main.run_benchmark(comentarios)
