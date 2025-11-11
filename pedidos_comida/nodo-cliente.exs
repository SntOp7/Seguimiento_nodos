defmodule NodoCliente do
  @nodo_remoto :"nodoservidor@servidor"
  @servicioremoto {:servicio_pedidos, @nodo_remoto}
  @nombre_servicio_local :servicio_respuestas

  def main() do
    IO.puts("CLIENTE INICIADO: ")

    Process.register(self(), @nombre_servicio_local)
    case Node.connect(@nodo_remoto) do
      true ->
        IO.puts("Conexion establecida - enviando datos...")
        enviar()
      false ->
        IO.puts("No se pudo conectar con el servidor")
    end
  end

  def enviar() do
    ordenes = [%Orden{id: 1, item: "Pizza", prep_ms: 2000},
              %Orden{id: 2, item: "Sushi", prep_ms: 1500},
              %Orden{id: 3, item: "Burger", prep_ms: 1000}]

    send(@servicioremoto, {self(), ordenes})
    recibir()
    send(@servicioremoto, {self(), :fin})
  end

  def recibir() do
    receive do
      :fin ->
        IO.puts("Proceso terminado")

      respuesta when is_list(respuesta) ->
        Enum.each(respuesta, fn {item, tiempo} ->
          IO.puts("El producto #{item} demora #{tiempo / 1000 |> Float.round(2)} microsegundos")
        end)
        recibir()
    end
  end
end

NodoCliente.main()
