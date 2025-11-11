defmodule NodoServidor do
  @nombre_servicio_local :servicio_reportes

  def main() do
    IO.puts("SERVIDOR ACTIVO - Esperando productos....")
    Process.register(self(), @nombre_servicio_local)
    escuchar()
  end

  defp escuchar() do
    receive do
      {remitente, :fin} ->
        IO.puts("Fin de transmisión.")
        send(remitente, :fin)

      {remitente, sucursales} when is_list(sucursales) ->
        resultado = generar_resumen(sucursales)
        send(remitente, resultado)
        escuchar()
    end
  end

  def generar_resumen(sucursales) do
    Enum.map(sucursales, &generar_resumen_sucursal/1)
  end

  def generar_resumen_sucursal(s) do
    total_ventas = Enum.reduce(s.ventas_diarias, 0, fn venta, acc -> acc + venta.monto end)

    %{
      nombre_sucursal: s.id,
      total_ventas: total_ventas,
      cantidad_ventas: length(s.ventas_diarias)
    }
  end
end

NodoServidor.main()
