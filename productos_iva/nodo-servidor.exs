defmodule NodoServidor do
  @nombre_servicio_local :servicio_precios

  def main() do
    IO.puts("SERVIDOR ACTIVO - Esperando productos...")
    Process.register(self(), @nombre_servicio_local)
    escuchar()
  end

  defp escuchar() do
    receive do
      {remitente, :fin} ->
        IO.puts("Fin de transmisión.")
        send(remitente, :fin)

      {remitente, productos} when is_list(productos) ->
        resultado = Enum.map(productos, &calcular_precio/1)
        send(remitente, resultado)
        escuchar()
    end
  end

  defp calcular_precio(%{nombre: nombre, precio_sin_iva: precio, iva: iva}) do
    %{nombre: nombre, precio_final: precio * (1 + iva)}
  end
end

NodoServidor.main()
