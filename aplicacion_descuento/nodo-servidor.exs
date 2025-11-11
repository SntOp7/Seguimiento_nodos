defmodule NodoServidor do
  @nombre_servicio_local :servicio_descuentos

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

      {remitente, carritos} when is_list(carritos) ->
        resultado = Enum.map(carritos, &aplicar_descuento/1)
        send(remitente, resultado)
        escuchar()
    end
  end

  def aplicar_descuento(%Carrito{id: id,items: items, cupon: cupon}) do
    total_con_descuento =
      Enum.reduce(items, 0.0, fn %Item{precio: precio}, acc ->
        acc + aplicar_cupon(precio, cupon)
      end)
      {id, total_con_descuento}
  end

  def aplicar_cupon(precio, nil), do: precio
  def aplicar_cupon(precio, %{id: _id, porcentaje: porcentaje}) do
    precio * (1 - porcentaje / 100)
  end
end

NodoServidor.main()
