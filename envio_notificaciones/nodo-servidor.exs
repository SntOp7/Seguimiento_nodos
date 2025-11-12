defmodule NodoServidor do
  @nombre_servicio_local :servicio_notificaciones

  def main() do
    IO.puts("SERVIDOR ACTIVO - Esperando notificaciones para enviar...")
    Process.register(self(), @nombre_servicio_local)
    escuchar()
  end

  defp escuchar() do
    receive do
      {remitente, :fin} ->
        IO.puts("Fin de transmisión de notificaciones.")
        send(remitente, :fin)

      {remitente, notificaciones} when is_list(notificaciones) ->
        resultado = Enum.map(notificaciones, &enviar/1)
        send(remitente, resultado)
        escuchar()
    end
  end

  defp enviar(%{canal: canal, usuario: usuario, plantilla: plantilla}) do
    case canal do
      "push" ->
        :timer.sleep(500)
        %{usuario: usuario, estado: "Notificación PUSH enviada (#{plantilla})"}

      "email" ->
        :timer.sleep(1000)
        %{usuario: usuario, estado: "Notificación EMAIL enviada (#{plantilla})"}

      "sms" ->
        :timer.sleep(800)
        %{usuario: usuario, estado: "Notificación SMS enviada (#{plantilla})"}
    end
  end
end

NodoServidor.main()
