defmodule NodoServidor do
  @nombre_servicio_local :servicio_limpieza

  def main() do
    IO.puts("SERVIDOR ACTIVO - Esperando reseñas para limpiar...")
    Process.register(self(), @nombre_servicio_local)
    escuchar()
  end

  defp escuchar() do
    receive do
      {remitente, :fin} ->
        IO.puts("Fin de transmisión de reseñas.")
        send(remitente, :fin)

      {remitente, resenias} when is_list(resenias) ->
        resultado = Enum.map(resenias, &limpiar/1)
        send(remitente, resultado)
        escuchar()
    end
  end

  defp limpiar(%{id: id, texto: texto}) do
    texto_limpio =
      texto
      |> String.downcase()
      |> quitar_tildes()
      |> quitar_stopwords()

    %{id: id, texto_limpio: texto_limpio}
  end

  defp quitar_tildes(resenia) do
    resenia
    |> String.normalize(:nfd)
    |> String.replace(~r/\p{Mn}/u, "")
  end

  defp quitar_stopwords(resenia) do
    stopwords = ~w(el la los las un una unos unas de del y o en por para con sin se que a al es son fue fuea fuean este esta estos estas muy más menos)
    resenia
    |> String.split()
    |> Enum.reject(&(&1 in stopwords))
    |> Enum.join(" ")
  end
end

NodoServidor.main()
