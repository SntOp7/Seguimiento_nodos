defmodule NodoCliente do
  @nodo_remoto :"nodoservidor@servidor"
  @servicio_remoto {:servicio_precios, @nodo_remoto}
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
    productos =
      for i <- 1..5 do
        %{nombre: "Producto#{i}", precio_sin_iva: 1000.0 + i, iva: 0.19}
      end

    send(@servicio_remoto, {self(), productos})
    recibir_respuesta()
    send(@servicio_remoto, {self(), :fin})
  end

  defp recibir_respuesta() do
    receive do
      :fin ->
        IO.puts("Procesamiento terminado.")
      respuesta when is_list(respuesta) ->
        Enum.each(respuesta, fn %{nombre: n, precio_final: p} ->
          IO.puts("#{n} => $#{Float.round(p, 2)}")
        end)
        recibir_respuesta()
    end
  end
end

NodoCliente.main()
