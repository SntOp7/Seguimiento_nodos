defmodule NodoCliente do
  @nodo_remoto :"nodoservidor@servidor"
  @servicio_remoto {:servicio_notificaciones, @nodo_remoto}
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
    notificaciones = [
      %{canal: "push", usuario: "usuario1@example.com", plantilla: "plantilla1"},
      %{canal: "email", usuario: "usuario2@example.com", plantilla: "plantilla2"},
      %{canal: "sms", usuario: "usuario3@example.com", plantilla: "plantilla3"}
    ]

    send(@servicio_remoto, {self(), notificaciones})
    recibir_respuesta()
    send(@servicio_remoto, {self(), :fin})
  end

  defp recibir_respuesta() do
    receive do
      :fin ->
        IO.puts("Procesamiento de notificaciones finalizado.")

      respuesta when is_list(respuesta) ->
        Enum.each(respuesta, fn %{usuario: u, estado: e} ->
          IO.puts("#{u}: #{e}")
        end)

        recibir_respuesta()
    end
  end
end

NodoCliente.main()
