defmodule NodoServidor do
  @nombre_servicio_local :servicio_empacado

  def main() do
    IO.puts("SERVIDOR ACTIVO - Esperando paquetes para procesar...")
    Process.register(self(), @nombre_servicio_local)
    escuchar()
  end

  defp escuchar() do
    receive do
      {remitente, :fin} ->
        IO.puts("Fin de transmisión de paquetes.")
        send(remitente, :fin)

      {remitente, paquetes} when is_list(paquetes) ->
        resultado = Enum.map(paquetes, &procesar_paquete/1)
        send(remitente, resultado)
        escuchar()
    end
  end

  defp procesar_paquete(%{id: id, fraji?: fraji?}) do
    :timer.sleep(10)  # Simula tiempo de etiquetado
    :timer.sleep(10)  # Simula tiempo de empaquetado

    if fraji? do
      :timer.sleep(10) # Embalaje especial
      %{id: id, estado: "Pedido #{id} embalado (frágil)"}
    else
      :timer.sleep(5)  # Embalaje normal
      %{id: id, estado: "Pedido #{id} embalado (normal)"}
    end
  end
end

NodoServidor.main()
