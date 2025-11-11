defmodule Main do
  @stopwords ~w(el la los las un una unos unas de del y o en por para con sin se que a al es
  son fue fuea fuean este esta estos estas muy más menos)

  def limpiar_resenia_secuencial(resenias) do
    Enum.map(resenias, fn %{texto: texto} -> limpiar(texto)
    end)
  end

  def limpiar_resenia_concurrencia(resenias) do
    Enum.map(resenias, fn %{texto: texto} ->
      Task.async(fn -> limpiar(texto)
      end)
    end)
    |> Enum.map(&Task.await/1)
  end

  def limpiar(resenia) do
    resenia
    |> String.downcase()
    |> quitar_tiles()
    |> quitar_stopwords()
  end

  def run_benchmark(resenias) do
    tiempo_concurrencia = Benchmark.determinar_tiempo_ejecucion({__MODULE__, :limpiar_resenia_concurrencia, [resenias]})
    IO.puts("Tiempo concurrencia: #{inspect(tiempo_concurrencia)}")
    tiempo_secuencial = Benchmark.determinar_tiempo_ejecucion({__MODULE__, :limpiar_resenia_secuencial, [resenias]})
    IO.puts("Tiempo secuencial: #{inspect(tiempo_secuencial)}")
    speedup = Benchmark.calcular_speedup(tiempo_concurrencia, tiempo_secuencial)
    IO.puts("Speedup: #{inspect(speedup)}")
  end

  def quitar_tiles(resenia) do
    resenia
    |> String.normalize(:nfd)
    |> String.replace(~r/\p{Mn}/u, "")
  end

  def quitar_stopwords(resenia) do
    resenia
    |> String.split()
    |> Enum.reject(&(&1 in @stopwords))
    |> Enum.join(" ")
  end
end

resenias = [%Review{id: "1", texto: "La película fue una experiencia increíble, con actuaciones sobresalientes y una trama envolvente."},
             %Review{id: "2", texto: "El libro es fascinante, lleno de personajes bien desarrollados y una narrativa cautivadora."},
             %Review{id: "3", texto: "El restaurante ofrece una comida deliciosa, con un ambiente acogedor y un servicio excepcional."},
             %Review{id: "4", texto: "El concierto fue espectacular, con una energía vibrante y una actuación inolvidable."},
             %Review{id: "5", texto: "La serie de televisión tiene una trama intrigante, personajes complejos y giros inesperados."}]

Main.limpiar_resenia_secuencial(resenias)
Main.limpiar_resenia_concurrencia(resenias)
Main.run_benchmark(resenias)
