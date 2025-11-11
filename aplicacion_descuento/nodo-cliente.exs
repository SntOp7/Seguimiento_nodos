defmodule NodoCliente do
  @nodo_remoto :nodoservidor@servidor
  @servicio_remoto {:servicio_descuentos, @nodo_remoto}
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
    cupon1 = %Cupon{id: "CUPON10", porcentaje: 10}
    cupon2 = %Cupon{id: "CUPON20", porcentaje: 20}
    item1 = %Item{id: "1", nombre: "Item1", precio: 100.0}
    item2 = %Item{id: "2", nombre: "Item2", precio: 200.0}
    item3 = %Item{id: "3", nombre: "Item3", precio: 300.0}
    item4 = %Item{id: "4", nombre: "Item4", precio: 400.0}

    carritos = [
      %Carrito{id: "C1", items: [item1, item2], cupon: cupon1},
      %Carrito{id: "C2", items: [item3, item4], cupon: cupon2}
    ]

    send(@servicio_remoto, {self(), carritos})
    recibir_respuesta()
    send(@servicio_remoto, {self(), :fin})
  end

  defp recibir_respuesta() do
    receive do
      :fin ->
        IO.puts("Procesamiento terminado.")

      respuesta when is_list(respuesta) ->
        Enum.each(respuesta, fn {id, total} ->
          IO.puts("Carrito #{id} => Total: #{total}")
        end)

        recibir_respuesta()
    end
  end
end

NodoCliente.main()
