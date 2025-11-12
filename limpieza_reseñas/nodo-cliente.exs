defmodule NodoCliente do
  @nodo_remoto :"nodoservidor@servidor"
  @servicio_remoto {:servicio_limpieza, @nodo_remoto}
  @nombre_servicio_local :servicio_respuesta

  def main() do
    IO.puts("CLIENTE INICIADO")

    Process.register(self(), @nombre_servicio_local)

    case Node.connect(@nodo_remoto) do
      true ->
        IO.puts("Conexión establecida con #{@nodo_remoto}")
        enviar_datos()

      false ->
        IO.puts("No se pudo conectar con el servidor")
    end
  end

  defp enviar_datos() do
    resenias = [
      %{id: "1", texto: "La película fue una experiencia increíble, con actuaciones sobresalientes y una trama envolvente."},
      %{id: "2", texto: "El libro es fascinante, lleno de personajes bien desarrollados y una narrativa cautivadora."},
      %{id: "3", texto: "El restaurante ofrece una comida deliciosa, con un ambiente acogedor y un servicio excepcional."},
      %{id: "4", texto: "El concierto fue espectacular, con una energía vibrante y una actuación inolvidable."},
      %{id: "5", texto: "La serie de televisión tiene una trama intrigante, personajes complejos y giros inesperados."}
    ]

    send(@servicio_remoto, {self(), resenias})
    recibir_respuesta()
    send(@servicio_remoto, {self(), :fin})
  end

  defp recibir_respuesta() do
    receive do
      :fin ->
        IO.puts("Procesamiento de reseñas completado.")

      respuesta when is_list(respuesta) ->
        Enum.each(respuesta, fn %{id: id, texto_limpio: texto} ->
          IO.puts("Reseña #{id}: #{texto}")
        end)

        recibir_respuesta()
    end
  end
end

NodoCliente.main()
