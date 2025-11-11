defmodule NodoServidor do
  @nombre_servicio_local :servicio_validacion

  def main() do
    IO.puts("SERVIDOR ACTIVO - Esperando usuarios...")
    Process.register(self(), @nombre_servicio_local)
    escuchar()
  end

  defp escuchar() do
    receive do
      {remitente, :fin} ->
        IO.puts("Fin de transmisión.")
        send(remitente, :fin)

      {remitente, usuarios} when is_list(usuarios) ->
        resultado = validar_usuarios(usuarios)
        send(remitente, resultado)
        escuchar()
    end
  end

  def validar_usuarios(usuarios) do
    Enum.map(usuarios, &validar_usuario/1)
  end

  def validar_usuario(%User{email: email, edad: edad, nombre: nombre}) do
    if String.contains?(email, "@") and edad >= 0 and nombre != "" do
      {:ok, nombre}
    else
      {:error, nombre}
    end
  end
end

NodoServidor.main()
