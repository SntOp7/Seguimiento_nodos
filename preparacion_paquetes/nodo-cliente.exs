defmodule NodoCliente do
  @nodo_remoto :"nodoservidor@servidor"
  @servicio_remoto {:servicio_empacado, @nodo_remoto}
  @nombre_servicio_local :servicio_respuesta

  def main() do
    IO.puts("CLIENTE INICIADO")

    Process.register(self(), @nombre_servicio_local)

    case Node.connect(@nodo_remoto) do
      true ->
        IO.puts("Conexión establecida con #{@nodo_remoto}")
        enviar_paquetes()

      false ->
        IO.puts("No se pudo conectar con el servidor")
    end
  end

  defp enviar_paquetes() do
    paquetes = [
      %{id: "1", peso: 10, fraji?: false},
      %{id: "2", peso: 5, fraji?: true},
      %{id: "3", peso: 20, fraji?: false},
      %{id: "4", peso: 15, fraji?: true},
      %{id: "5", peso: 8, fraji?: false}
    ]

    send(@servicio_remoto, {self(), paquetes})
    recibir_respuesta()
    send(@servicio_remoto, {self(), :fin})
  end

  defp recibir_respuesta() do
    receive do
      :fin ->
        IO.puts("Procesamiento de paquetes completado.")

      respuesta when is_list(respuesta) ->
        Enum.each(respuesta, fn %{id: id, estado: estado} ->
          IO.puts("Paquete #{id}: #{estado}")
        end)

        recibir_respuesta()
    end
  end
end

NodoCliente.main()
