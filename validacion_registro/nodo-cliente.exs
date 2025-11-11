defmodule NodoCliente do
  @nodo_remoto :nodoservidor@servidor
  @servicio_remoto {:servicio_validacion, @nodo_remoto}
  @nombre_servicio_local :servicio_respuesta

  def main() do
    IO.puts("CLIENTE INICIADO.")

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
    usuarios = [
      %User{email: "jose@example.com", edad: 30, nombre: "Jose"},
      %User{email: "mariaexample.com", edad: 25, nombre: "Maria"},
      %User{email: "ana@example.com", edad: 28, nombre: "Ana"}
    ]

    send(@servicio_remoto, {self(), usuarios})
    recibir_respuesta()
    send(@servicio_remoto, {self(), :fin})
  end

  defp recibir_respuesta() do
    receive do
      :fin ->
        IO.puts("Procesamiento terminado.")

      respuesta when is_list(respuesta) ->
        Enum.each(respuesta, fn {estado, nombre} ->
          IO.puts("#{estado} => #{nombre}")
        end)

        recibir_respuesta()
    end
  end
end

NodoCliente.main()
