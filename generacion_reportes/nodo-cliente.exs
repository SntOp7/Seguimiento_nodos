defmodule NodoCliente do
  @nodo_remoto :nodoservidor@servidor
  @servicio_remoto {:servicio_reportes, @nodo_remoto}
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
    venta1 = %Venta{id: 1, monto: 500}
    venta2 = %Venta{id: 2, monto: 750}
    venta3 = %Venta{id: 3, monto: 300}
    venta4 = %Venta{id: 4, monto: 450}
    venta5 = %Venta{id: 5, monto: 600}

    sucursales = [
      %Sucursal{
        id: "Sucursal A",
        ventas_diarias: [venta1, venta2]
      },
      %Sucursal{
        id: "Sucursal B",
        ventas_diarias: [venta3]
      },
      %Sucursal{
        id: "Sucursal C",
        ventas_diarias: [venta4, venta5]
      }
    ]

    send(@servicio_remoto, {self(), sucursales})
    recibir_respuesta()
    send(@servicio_remoto, {self(), :fin})
  end

  defp recibir_respuesta() do
    receive do
      :fin ->
        IO.puts("Procesamiento terminado.")

      respuesta when is_list(respuesta) ->
        Enum.each(respuesta, fn %{nombre_sucursal: nombre, total_ventas: total_ventas, cantidad_ventas: cantidad} ->
          IO.puts("#{nombre} => total ventas: #{total_ventas}, cantidad: #{cantidad}")
        end)

        recibir_respuesta()
    end
  end
end

NodoCliente.main()
