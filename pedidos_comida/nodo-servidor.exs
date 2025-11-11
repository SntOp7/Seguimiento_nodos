defmodule NodoServidor do
  @nombre_servicio_local :servicio_pedidos

  def main() do
    IO.puts("SERVIDOR ACTIVADO - Esperando pedidos...")
    Process.register(self(), @nombre_servicio_local)
    escuchar()
  end

  def escuchar() do
    receive do
      {remitente, :fin} ->
        IO.puts("Fin de la transmision.")
        send(remitente, :fin)

      {remitente, pedidos} when is_list(pedidos) ->
        resultado = Enum.map(pedidos, &preparar/1)
        send(remitente, resultado)
        escuchar()
    end
  end

  def preparar(%Orden{item: item, prep_ms: prep_ms}) do
    {tiempo_microseg, _} = :timer.tc(fn -> :timer.sleep(prep_ms) end)
    {item, tiempo_microseg}
  end
end

NodoServidor.main()
